<!DOCTYPE html>
<html>
  <head>
    <link rel="stylesheet" href="stylesheets/style.css">
    <title>
        VNC console
    </title>
</head>
 
  <body style="margin:0px;padding:0px;overflow:hidden">
    <script src="scripts/utils.js"></script>
    <?php
     $vncport = $_GET['port'];
     $offset = $_GET['offset'];
     $vncpass = $_GET['pass'];
     $consoleurl = "http://" . $_SERVER['HTTP_HOST'] . ":" . $vncport . "/vnc.html";



     echo "<script type='text/javascript'>
        window.addEventListener('beforeunload', function (e) {
            //e.preventDefault();
            //e.returnValue = '';
	    window.opener.console.log('closing now');
	    closeport(" . $offset . ",'" . $vncpass . "');
        });
</script>";
    echo "<div><iframe src=\"" . $consoleurl . "\" frameborder=\"0\" style=\"overflow:hidden;overflow-x:hidden;overflow-y:hidden;height:100%;width:100%;position:absolute;top:0px;left:0px;right:0px;bottom:0px\" height=\"100%\" width=\"100%\"></iframe></div>";

?>
</body>
</html>
