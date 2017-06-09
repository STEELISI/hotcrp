<?php
$ConfSitePATH = preg_replace(',/batch/[^/]+,', '', __FILE__);

require_once("$ConfSitePATH/lib/getopt.php");
$arg = getopt_rest($argv, "hn:qr", ["help", "name:", "quiet", "disable", "disable-users",
                                    "reviews", "match-title", "ignore-pid", "ignore-errors"]);
if (isset($arg["h"]) || isset($arg["help"])
    || count($arg["_"]) > 1
    || (count($arg["_"]) && $arg["_"][0] !== "-" && $arg["_"][0][0] === "-")) {
    fwrite(STDOUT, "Usage: php batch/savepapers.php [-n CONFID] [OPTIONS] FILE

Options include:
  --quiet          Don't print progress information.
  --ignore-errors  Do not exit after first error.
  --disable-users  Newly created users are disabled.
  --match-title    Match papers by title if no `pid`.
  --ignore-pid     Ignore `pid` elements in JSON.
  --reviews        Save JSON reviews.\n");
    exit(0);
}

require_once("$ConfSitePATH/src/init.php");

$file = count($arg["_"]) ? $arg["_"][0] : "-";
$quiet = isset($arg["q"]) || isset($arg["quiet"]);
$disable_users = isset($arg["disable"]) || isset($arg["disable-users"]);
$reviews = isset($arg["r"]) || isset($arg["reviews"]);
$match_title = isset($arg["match-title"]);
$ignore_pid = isset($arg["ignore-pid"]);
$ignore_errors = isset($arg["ignore-errors"]);
$site_contact = $Conf->site_contact();

if ($file === "-") {
    $content = stream_get_contents(STDIN);
    $filepfx = "";
} else {
    $content = file_get_contents($file);
    $filepfx = "$file: ";
}
if ($content === false) {
    fwrite(STDERR, "{$filepfx}Read error\n");
    exit(1);
}

// allow uploading a whole zip archive
global $ziparchive;
$ziparchive = null;
if (str_starts_with($content, "\x50\x4B\x03\x04")) {
    if (!($tmpdir = tempdir())) {
        fwrite(STDERR, "Cannot create temporary directory\n");
        exit(1);
    } else if (file_put_contents("$tmpdir/data.zip", $content) !== strlen($content)) {
        fwrite(STDERR, "$tmpdir/data.zip: Cannot write file\n");
        exit(1);
    }

    $ziparchive = new ZipArchive;
    if ($ziparchive->open("$tmpdir/data.zip") !== true) {
        fwrite(STDERR, "{$filepfx}Invalid zip\n");
        exit(1);
    } else if ($ziparchive->numFiles == 0) {
        fwrite(STDERR, "{$filepfx}Empty zipfile\n");
        exit(1);
    }
    // find common directory prefix
    $slashpos = strpos($ziparchive->getNameIndex(0), "/");
    if ($slashpos === false || $slashpos === 0)
        $dirprefix = "";
    else {
        $dirprefix = substr($ziparchive->getNameIndex(0), 0, $slashpos + 1);
        for ($i = 1; $i < $ziparchive->numFiles; ++$i)
            if (!str_starts_with($ziparchive->getNameIndex($i), $dirprefix))
                $dirprefix = "";
    }
    // find "*-data.json" file
    $data_filename = [];
    for ($i = 0; $i < $ziparchive->numFiles; ++$i) {
        $filename = $ziparchive->getNameIndex($i);
        if (str_starts_with($filename, $dirprefix)) {
            $dirname = substr($filename, strlen($dirprefix));
            if (preg_match(',\A[^/]*(?:\A|[-_])data\.json\z,', $dirname))
                $data_filename[] = $filename;
        }
    }
    if (count($data_filename) !== 1) {
        fwrite(STDERR, "{$filepfx}Should contain exactly one `*-data.json` file\n");
        exit(1);
    }
    $data_filename = $data_filename[0];
    $content = $ziparchive->getFromName($data_filename);
    $filepfx = ($filepfx ? $file : "<stdin>") . "/" . $data_filename . ": ";
    if ($content === false) {
        fwrite(STDERR, "{$filepfx}Could not read\n");
        exit(1);
    }
}

if (($jp = json_decode($content)) === null) {
    Json::decode($content); // our JSON decoder provides error positions
    fwrite(STDERR, "{$filepfx}invalid JSON: " . Json::last_error_msg() . "\n");
    exit(1);
} else if (!is_object($jp) && !is_array($jp)) {
    fwrite(STDERR, "{$filepfx}invalid JSON, expected array of objects\n");
    exit(1);
}

function on_document_import($docj, PaperOption $o, PaperStatus $pstatus) {
    global $ziparchive;
    if (isset($docj->content_file)
        && is_string($docj->content_file)
        && $ziparchive) {
        $content = $ziparchive->getFromName($docj->content_file);
        if ($content === false) {
            $pstatus->error_at_option($o, "{$docj->content_file}: Could not read");
            return false;
        }
        $docj->content = $content;
    }
}

if (is_object($jp))
    $jp = array($jp);
$index = 0;
$nerrors = 0;
$nsuccesses = 0;
foreach ($jp as &$j) {
    ++$index;
    if ($ignore_pid)
        unset($j->pid, $j->id);
    if (!isset($j->pid) && !isset($j->id) && isset($j->title) && is_string($j->title)) {
        $pids = Dbl::fetch_first_columns("select paperId from Paper where title=?", simplify_whitespace($j->title));
        if (count($pids) == 1)
            $j->pid = (int) $pids[0];
    }
    if (isset($j->pid) && is_int($j->pid) && $j->pid > 0)
        $pidtext = "#$j->pid";
    else if (!isset($j->pid) && isset($j->id) && is_int($j->id) && $j->id > 0)
        $pidtext = "#$j->id";
    else if (!isset($j->pid) && !isset($j->id))
        $pidtext = "new paper @$index";
    else {
        fwrite(STDERR, "paper @$index: bad pid\n");
        ++$nerrors;
        if (!$ignore_errors)
            break;
        else
            continue;
    }

    if (!$quiet) {
        if (isset($j->title) && is_string($j->title))
            fwrite(STDERR, $pidtext . " (" . UnicodeHelper::utf8_abbreviate($j->title, 40) . "): ");
        else
            fwrite(STDERR, $pidtext . ": ");
    }
    $ps = new PaperStatus($Conf, null, ["no_email" => true,
                                        "disable_users" => $disable_users,
                                        "allow_error" => ["topics", "options"]]);
    $ps->on_document_import("on_document_import");
    $pid = $ps->save_paper_json($j);
    if ($pid && str_starts_with($pidtext, "new")) {
        fwrite(STDERR, "-> #" . $pid . ": ");
        $pidtext = "#$pid";
    }
    if (!$quiet)
        fwrite(STDERR, $pid ? "saved\n" : "failed\n");
    $prefix = $pidtext . ": ";
    foreach ($ps->messages() as $msg)
        fwrite(STDERR, $prefix . htmlspecialchars_decode($msg) . "\n");
    if ($pid)
        ++$nsuccesses;
    else {
        ++$nerrors;
        if (!$ignore_errors)
            break;
    }

    // XXX more validation here
    if ($pid && isset($j->reviews) && is_array($j->reviews) && $reviews) {
        $rform = $Conf->review_form();
        $tf = $rform->blank_text_form();
        foreach ($j->reviews as $reviewindex => $reviewj)
            if (($rreq = $rform->parse_json($reviewj))
                && isset($rreq["reviewerEmail"])
                && validate_email($rreq["reviewerEmail"])) {
                $rreq["paperId"] = $pid;
                $user_req = Text::analyze_name(["name" => get($rreq, "reviewerName"), "email" => $rreq["reviewerEmail"], "affiliation" => get($rreq, "reviewerAffiliation")]);
                $user = Contact::create($Conf, $user_req);
                $rform->check_save_review($site_contact, $rreq, $tf, $user);
            } else
                $tf["err"][] = "invalid review @$reviewindex";
        foreach ($tf["err"] as $te)
            fwrite(STDERR, $prefix . htmlspecialchars_decode($te) . "\n");
    }

    // clean up memory, hopefully
    $ps = $j = null;
}

if ($nerrors)
    exit($ignore_errors && $nsuccesses ? 2 : 1);
else
    exit(0);
