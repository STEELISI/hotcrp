function closeport(port, vncpass)
{
    const xhttp = new XMLHttpRequest();
    window.opener.console.log("Should close " + port + " pass " + vncpass);
    var url = "closeport.php?vncpass=" + vncpass + "&port=" + port + "&t=" + Math.random();
    window.opener.console.log(url);
    xhttp.open("GET", url, true);
    xhttp.send(null);
}

var myclose = false;

