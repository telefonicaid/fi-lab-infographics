function changeJiraEnvironmentFun() { 
  var environmentId = $("#customfield_10108").val();
  if(environmentId == "10100")//Fi-Lab
  {
    $("#regionNone").hide();
    $("#customfield_10109").show();
  }
  else
  {
    $("#customfield_10109").hide();
    $("#regionNone").show();
  }						  
};

function isValidEmailAddress(emailAddress) {
  var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
  return pattern.test(emailAddress);
};
		  
function submitJiraFun() { 
  
  if($("input#summary").val() == "" || $("input#customfield_10302").val() == "" || $("input#customfield_10301").val() == "")
  {
      alert("Please fill all fields marked with *");
  }
  else if(!isValidEmailAddress($("input#customfield_10301").val()))
  {
      alert("Please enter a valid email address");
  }
  else 
  {
      var regionId = $("#customfield_10109").val();
      var environmentId = $("#customfield_10108").val();
//       var type = $("#type").val();
      var priority = $("#priority").val();
      var summary = $("input#summary").val();
      var description = $("textarea#description").val();
      var name = $("input#customfield_10302").val();
      var email = $("input#customfield_10301").val();
  
      $.ajax({ 
	type: 'POST', 
	url: "../api/v1/jira/issue",
	data: {
	    'region_id' : regionId,
	    'environment_id' : environmentId,
// 	    'type':type,
	    'priority':priority,
	    'summary':summary,
	    'description':description,
	    'name':name,
	    'email':email
	},
	dataType: "json",
	cache: false, 
	success: function(data){
	  
	  if(data["errors"] != null)
	    alert("An error occurred during sending: JIRA issue");
	  else
	  {
	    $("input#summary").val('');
	    $("textarea#description").val('');
	    $("input#customfield_10302").val('');
	    $("input#customfield_10301").val('');
	    
	    alert("New issue created: "+data["key"]+"\nURL: "+data["self"]);
  // 									
	    $('#atlScriptlet').dialog('close');
	  }
// 									$(this).dialog('close');
// alert("");
	},
	error: function(xhr, textStatus, errorThrown){
	  var errore = "retry later";
	  if(errorThrown != null && errorThrown != "" && errorThrown != "null")
	    errore = errorThrown;
	  alert("An error occurred during sending: "+errore);
	}
      });

      
  }
};