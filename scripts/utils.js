function closeport(port, vncpass)
{
    const xhttp = new XMLHttpRequest();
    console.log("Should close " + port + " pass " + vncpass);
    var url = "closeport.php?vncpass=" + vncpass + "&port=" + port;
    console.log(url);
    //xhttp.open("GET", url);
    //xhttp.send(null);
}

