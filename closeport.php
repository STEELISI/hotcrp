<?php

  $port =  $_GET['port'];
  $vncpass =  $_GET['vncpass'];
  $cmd = "perl closeport " . $port . " " . $vncpass . " 2>&1 >> data/log";
  print "Command $cmd\n";
  $output = shell_exec($cmd);
  
?>