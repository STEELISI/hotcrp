<?php
// pages/p_offline.php -- HotCRP offline review management page
// Copyright (c) 2006-2023 Eddie Kohler; see LICENSE.

class StartVm_Page {
    /** @var Conf */
    public $conf;
    /** @var Contact */
    public $user;
    /** @var Qrequest */
    public $qreq;
    /** @var MessageSet */
    private $ms;

    function __construct(Contact $user, Qrequest $qreq) {
        $this->conf = $user->conf;
        $this->user = $user;
        $this->qreq = $qreq;
        $this->ms = new MessageSet;
	$this->pid = $_GET['pid'];
    }

    function get_log($file){

    echo '<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>';
    echo '<script type="text/javascript" src="scripts/test.js"></script>';

    echo '<script>
     var a;
     a=setInterval(fun("'  . $_GET['createhash'] . '"), 3000);
    </script>';

    }

    // this is useful for post stuff
    function handle_post_request() {
        if ($this->qreq->action == 'create' ) {
            $this->call_vm_action($this->user, $this->qreq, $this->qreq->vmid, $this->qreq->action);
        } elseif ($this->qreq->action == 'stop' ) {
            $this->call_vm_action($this->user, $this->qreq, $this->qreq->vmid, $this->qreq->action);
        } elseif ($this->qreq->action == 'reset' ) {
            $this->call_vm_action($this->user, $this->qreq, $this->qreq->vmid, $this->qreq->action);
        } elseif ($this->qreq->action == 'console' ) {
            $this->call_vm_action($this->user, $this->qreq, $this->qreq->vmid, $this->qreq->action);
        };
    }

    function print() {
        $conf = $this->conf;
        $this->qreq->print_header("Create VM", "createvm");

        echo '<p>Use this page to download review forms, or to upload review forms you’ve already filled out.</p>';
        if (!$this->user->can_clickthrough("review")) {
            echo '<div class="js-clickthrough-container">';
            echo '</div>';
        }


        $this->qreq->print_footer();
    }
    
    function create_vm(Contact $user, Qrequest $qreq) {

    	$createhash=$_GET['createhash'];
	$vmtype=$_GET['vm-types'];
	
	
        if (!($db = $user->conf->contactdb())) {
            $db = $user->conf->dblink;
        }
      	      include_once('src/pve_api/pve_functions.php');
            $qreq->print_header("Creating a New VM", "createvm");

	    $people=[];
	    $result = Dbl::qe($db, "select authorInformation from Paper WHERE paperID = ?;", $this->pid);
	    
	    while (($row = $result->fetch_row())) {
	    $strings = preg_split('/\s+/',$row[0]);
	    foreach ($strings as $s)
	    {
		if (str_contains($s, "@"))
		{
			 $resulti = Dbl::qe($db, "select contactId from ContactInfo WHERE email = ?;", $s);
			 while (($rowi = $resulti->fetch_row())) {
			   $id = $rowi[0];
		    	   array_push($people, $id);
		          }
		}
	     }
	   }
	    $result = Dbl::qe($db, "select contactId from PaperReview WHERE paperID = ?;", $this->pid);

            while (($row = $result->fetch_row())) {

	    	  $id = $row[0];
		  array_push($people, $id);
	    }
	    $cmd = "bash firestartvm " . $this->pid . " " . $vmtype . " " . $createhash . " ";
	    foreach ($people as $p)
	    {
		$cmd = $cmd . " " . $p;
       	    }
	    echo $cmd;

	    echo '<p><textarea id="startvm_log" name="startvm_log" rows="40" cols="100"></textarea><p>';
	    echo '<p><input type="submit" value="Close" id="closeButton" style="display: none;" onclick="window.close();">';
	    $_SESSION["filename"] = $_GET['createhash'];

	    // count the lines exist in the file
	    $file = 'data/'. $_SESSION["filename"];
	    $result=exec("touch " . $file);
	    $cmd = $cmd . " 2>&1 >> " . $file;
	    $cmd = "echo \"" . $cmd . "\" | at -m now";
	    $this->get_log($file);
	    $output = shell_exec($cmd);
	    
    }

    function stop_vm(Contact $user, Qrequest $qreq, $vmid) {
        $createhash=$_GET['createhash'];	
	$vmtype=$_GET['type'];
	
        if (!($db = $user->conf->contactdb())) {
            $db = $user->conf->dblink;
        }
        $result = Dbl::qe($db, "SELECT * FROM VMaccess WHERE contactId = ? and vmId = ?;", $user->contactId, $vmid);
        if (!$result->fetch_assoc()) {
            $qreq->print_header("Access Denied", "createvm");

            echo '<p>You do not have access to this VM.</p>';

            $qreq->print_footer();
        } else {
            include_once('src/pve_api/pve_functions.php');

            $qreq->print_header("Stopping the VM", "stopvm");

	    $cmd = "bash firestopvm " . $this->pid . " " . $vmtype;
	    echo $cmd;
	    echo '<p><textarea id="startvm_log" name="startvm_log" rows="40" cols="100"></textarea><p>';
	    echo '<p><input type="submit" value="Close" id="closeButton" style="display: none;" onclick="window.close();">';
	    $_SESSION["filename"] = $_GET['createhash'];

	    // count the lines exist in the file
	    $file = 'data/'. $_SESSION["filename"];
	    $result=exec("touch " . $file);
	    $cmd = $cmd . " 2>&1 >> " . $file;
	    $cmd = "echo \"" . $cmd . "\" | at -m now";
	    $this->get_log($file);
	    $output = shell_exec($cmd);
    }
    }
    
    function reset_vm(Contact $user, Qrequest $qreq, $vmid) {
        $createhash=$_GET['createhash'];	
	$vmtype=$_GET['type'];
	
        if (!($db = $user->conf->contactdb())) {
            $db = $user->conf->dblink;
        }
        $result = Dbl::qe($db, "SELECT * FROM VMaccess WHERE contactId = ? and vmId = ?;", $user->contactId, $vmid);
        if (!$result->fetch_assoc()) {
            $qreq->print_header("Access Denied", "createvm");

            echo '<p>You do not have access to this VM.</p>';

            $qreq->print_footer();
        } else {
            include_once('src/pve_api/pve_functions.php');

            $qreq->print_header("Resetting the VM", "resetvm");

	    $people=[];
	    $result = Dbl::qe($db, "select authorInformation from Paper WHERE paperID = ?;", $this->pid);
	    
	    while (($row = $result->fetch_row())) {
	    $strings = preg_split('/\s+/',$row[0]);
	    foreach ($strings as $s)
	    {
		if (str_contains($s, "@"))
		{
			 $resulti = Dbl::qe($db, "select contactId from ContactInfo WHERE email = ?;", $s);
			 while (($rowi = $resulti->fetch_row())) {
			   $id = $rowi[0];
		    	   array_push($people, $id);
		          }
		}
	     }
	   }
	    $result = Dbl::qe($db, "select contactId from PaperReview WHERE paperID = ?;", $this->pid);

            while (($row = $result->fetch_row())) {

	    	  $id = $row[0];
		  array_push($people, $id);
	    }
	    $cmd = "bash fireresetvm " . $this->pid . " " . $vmtype . " " . $createhash . " ";
	    foreach ($people as $p)
	    {
		$cmd = $cmd . " " . $p;
       	    }
	    echo $cmd;
	    echo '<p><textarea id="startvm_log" name="startvm_log" rows="40" cols="100"></textarea><p>';
	    echo '<p><input type="submit" value="Close" id="closeButton" style="display: none;" onclick="window.close();">';
	    $_SESSION["filename"] = $_GET['createhash'];

	    // count the lines exist in the file
	    $file = 'data/'. $_SESSION["filename"];
	    $result=exec("touch " . $file);
	    $cmd = $cmd . " 2>&1 >> " . $file;
	    $cmd = "echo \"" . $cmd . "\" | at -m now";
	    $this->get_log($file);
	    $output = shell_exec($cmd);
    }
}

    function console_vm(Contact $user, Qrequest $qreq, $vmid) {
        $createhash=$_GET['createhash'];	
	$vmtype=$_GET['type'];
	
        if (!($db = $user->conf->contactdb())) {
            $db = $user->conf->dblink;
        }
        $result = Dbl::qe($db, "SELECT * FROM VMaccess vma left join VMs vm on vma.vmid=vm.vmid WHERE contactId = ? and vm.vmId = ?;", $user->contactId, $vmid);
        if (!$result->fetch_assoc()) {
            $qreq->print_header("Access Denied", "createvm");

            echo '<p>You do not have access to this VM.</p>';

            $qreq->print_footer();
        } else {
            include_once('src/pve_api/pve_functions.php');

	    $cmd = "bash fireconsolevm " . $this->pid . " " . $vmtype . " " . $user->contactId;
	    echo $cmd;
	    
	    $_SESSION["filename"] = $_GET['createhash'];

	    $vncpass = "";			  
            foreach ($result as $vm){
                    $vncpass = $vm['VNCpass'];
		    echo "VNCpass " . $vncpass;
	     }

           
	    // count the lines exist in the file
	    $file = 'data/'. $_SESSION["filename"];
	    $result=exec("touch " . $file);
	    $cmd = $cmd . " 2>&1 >> " . $file;
	    $output = shell_exec($cmd);
	    $vncport = 6080 + $user->contactId + 50*$this->pid;
	    $consoleurl = "http://" . $_SERVER['HTTP_HOST'] . ":" . $vncport . "/vnc.html?autoconnect=true&password=" . $vncpass;
	    echo "<script> child=window.open('" . $consoleurl . "'); child.onunload = function(){ console.log('Child window closed'); };</script>";
       	    exit;	 
    }
   
   }
    
    static function go(Contact $user, Qrequest $qreq) {
        if (!$user->email) {
            $user->escape();

        //} else if (!$user->is_reviewer() || !$user->is_vm_user()) {
        //} else if (!$user->is_reviewer() || !$user->is_user()) {
        //    Multiconference::fail($qreq, 403, ["title" => "Create VM"], "<0>You are not allowed to start a VM for this conference!");
        }

        if ($qreq->post && $qreq->post_empty()) {
            $user->conf->post_missing_msg();
        }
        $op = new StartVm_Page($user, $qreq);

        if ($qreq->post && $qreq->valid_post()) {
            $op->handle_post_request();
        } elseif (array_key_exists('action', $_GET)) {
            if ($_GET['action'] == 'create' && array_key_exists('createhash', $_GET)) {
                $op->create_vm($user, $qreq);
            } elseif ($_GET['action'] == 'reset' && array_key_exists('vmid', $_GET)) {
                $op->reset_vm($user, $qreq, $_GET['vmid']);
	    } elseif ($_GET['action'] == 'console' && array_key_exists('vmid', $_GET)) {
                $op->console_vm($user, $qreq, $_GET['vmid']);
	    } elseif ($_GET['action'] == 'stop' && array_key_exists('vmid', $_GET)) {
                $op->stop_vm($user, $qreq, $_GET['vmid']);
            };
        };
    }
}
