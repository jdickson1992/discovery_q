/* initialise variable */
var ws, syms = document.getElementById("selectSyms"),
    discovery = document.getElementById("tblDiscovery");


function connect() {
        if("WebSocket" in window){  // check if WebSockets supported
            connInput = document.getElementById("hostport").value;
            // open a WebSocket
            ws = new WebSocket("ws://" + connInput);
            ws.onopen = function(){
            // called upon successful WebSocket connection
                document.getElementById("connectionStatus").innerHTML = " Connected";
                document.getElementById("connectionStatus").style.color = "magenta";
            ws.send(".master.loadPage[]");
            };

        ws.onmessage = function(e) {
            /*parse message from JSON String into Object*/
            var d = JSON.parse(e.data);

            /*depending on the messages func value, pass the result
            to the appropriate handler function*/
            switch(d.func){
            	case 'getSyms'   : setSyms(d.result); break;
                case 'getDiscovery' : setDiscovery(d.result);
            }

        };

        ws.onclose = function(){
                document.getElementById("connectionStatus").innerHTML = " Disconnected";
                document.getElementById("connectionStatus").style.color = "red" };

    } else alert("WebSockets not supported on your browser.");
}

var disconnect = function(){
    ws.close();
}

function highlightDiscovery(){
    var rows = document.getElementById("tblDiscovery").children[0].children;
    for(var x=0; x < rows.length; x++){
        var row = rows[x];
        var activeCell = row.children[7];
        var warnCell = row.children[8];
        var errorCell = row.children[9];
        if((activeCell.innerHTML == "true") && (warnCell.innerHTML == "false") && (errorCell.innerHTML == "false"))
            row.style.background = "PaleGreen"
    }
}

function highlightWarning(){
    var rows = document.getElementById("tblDiscovery").children[0].children;
    for(var x=0; x < rows.length; x++){
        var row = rows[x];
        var warnCell = row.children[8];
        if(warnCell.innerHTML == "true")
            row.style.background = "Orange"
    }
}

function highlightError(){
    var rows = document.getElementById("tblDiscovery").children[0].children;
    for(var x=0; x < rows.length; x++){
        var row = rows[x];
        var errorCell = row.children[9];
        if(errorCell.innerHTML == "true")
            row.style.background = "Red"
    }
}


function filterSyms() {
    /* get the values of checkboxes that are ticked and
    convert into an array of strings */
    var t = [], s = syms.children;
    for (var i = 0; i < s.length; i++) {
        if (s[i].checked) {
            t.push(s[i].value);
        };
    };
    t = t.join("`");
    /*call the filterSyms function over the WebSocket*/
    ws.send('.master.filterSyms[`'+ t +']');
}

function setSyms(data) {
    /* parse an array of strings into checkboxes */
    syms.innerHTML = '';
    for (var i = 0; i < data.length; i++) {
        syms.innerHTML += '<input type="checkbox" name="sym" value="' +
            data[i] + '">' + data[i] + '</input>';
    };
}

function setDiscovery(data) { discovery.innerHTML = generateTableHTML(data); highlightDiscovery(); highlightWarning(); highlightError() }

function generateTableHTML(data){
    /* we will iterate through the object wrapping it in the HTML table tags */
    var tableHTML = '<table border="1"><tr>';
    for (var x in data[0]) {
        /* loop through the keys to create the table headers */
        tableHTML += '<th>' + x + '</th>';
    }
    tableHTML += '</tr>';

    for (var i = 0; i < data.length; i++) {
        /* loop through the rows, putting tags around each col value */
        tableHTML += '<tr>';
        for (var x in data[0]) {
            /* Instead of pumping out the raw data to the table, lets
            format it depending on if its a date, number or string*/
            var cellData;
            if("time" === x)
                cellData = data[i][x].substring(2,10);
            else if("number" == typeof data[i][x])
                cellData = data[i][x].toFixed(0);
            else cellData = data[i][x];
            tableHTML += '<td>' + cellData + '</td>';
        }
        tableHTML += '</tr>';

    }

    tableHTML += '</table>';

    return tableHTML;
}