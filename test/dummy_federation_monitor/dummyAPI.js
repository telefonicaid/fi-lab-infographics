var http = require('http');
var url  = require('url');
var path = require('path');
var port = 1339;

var server = http.createServer(function (req, res) {
var url_parts = url.parse(req.url, true);
dirtUrl=url_parts.pathname
slpitUrl=dirtUrl.split(path.sep)
slpitUrl = slpitUrl.filter(function(n){return n});

if(slpitUrl.length==2 && slpitUrl[0]=="monitoring" && slpitUrl[1]=="regions"){
  //all Region 
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end('{"_links":{"self":{"href":"/monitoring/regions/"}},"_embedded":{"regions":[{"_links":{"self":{"href":"/monitoring/regions/Trento/"}},"id":"Trento"},{"_links":{"self":{"href":"/monitoring/regions/Berlin/"}},"id":"Berlin"}]},"total_nb_users":20,"total_nb_cores":10,"total_nb_ram":14,"total_nb_disk":18,"total_nb_vm":4}');
}
else if(slpitUrl.length==3 && slpitUrl[0]=="monitoring" && slpitUrl[1]=="regions"){
  res.writeHead(200, {'Content-Type': 'application/json'});
if(slpitUrl[2]=="Trento"){res.end('{"_links":{"self":{"href":"/monitoring/regions/Trento"},"hosts":{"href":"/monitoring/regions/Trento/hosts"}},"id":"Trento","name":"Trento","nb_cores":5,"nb_vm":2,"nb_disk":9,"nb_ram":7,"nb_users":10,"country":"IT","latitude":46.06787,"longitude":11.12108}');}
if(slpitUrl[2]=="Berlin"){res.end('{"_links":{"self":{"href":"/monitoring/regions/Berlin"},"hosts":{"href":"/monitoring/regions/Berlin/hosts"}},"id":"Berlin","name":"Berlin","nb_cores":5,"nb_vm":2,"nb_disk":9,"nb_ram":7,"nb_users":10,"country":"DE","latitude":52.30,"longitude":13.25}');}


}

else{
  //Error
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end('{"error":error}');

}


})
 
server.listen(port);
 
console.log('Server running at http://127.0.0.1:'+port+'/');

