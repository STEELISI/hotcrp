var logfile=null;
var refreshed=false;

function fun(file) {
    logfile=file;
}


function closeport(port)
{
    console.log("Should close " + port);
}

function greet()
{
    const xhttp = new XMLHttpRequest();

    xhttp.onload = function() {
    if (xhttp.status == 200)
        {
	    document.getElementById("startvm_log").value = xhttp.responseText;
	    if (xhttp.responseText.includes("DONE") && document.getElementById("closeButton").style.display == "none")
	    {
		//alert("Done");
		document.getElementById("closeButton").style.display = "block";
		refreshed=false;
	    }
	    
	}
    } 
    time=new Date().getTime()    
    xhttp.open("GET", "data/" + logfile +"?" + time, true);
    xhttp.send(null);
    if (window.opener) {
	if(document.getElementById('closeButton').style.display == "block" && !refreshed)
	{
	    window.opener.location.reload();
	    refreshed=true;
	}
    }
}

var a;
a=setInterval(greet, 1000);
