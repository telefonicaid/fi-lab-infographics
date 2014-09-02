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
		  
function submitJiraFun(successMsg) { 
  
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
  
      $("input.submit-button").attr('disabled', 'disabled');
      $( "#jic-collector-form" ).addClass("disabled");
      $( "#img-loading" ).show();
    
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
	success: /*function(n,l,p,m){
	  var o=AJS.$('<div class="msg-container"></div>');
	  var k;
	  if(n.errors!==undefined){
	    
	    return
	    
	  }
	  if(n.url!==undefined){
	   var q='<a class="issue-key" target="_blank" href="'+n.url+'">'+n.key+"</a>";
	   k="<p>"+AJS.format("Your feedback has been recorded in {0}. This window will automatically close in 5 seconds.",q)+"</p>"
	    
	  }
	  else{
	    k="<p>"+"Thanks for providing your feedback! This window will automatically close in 5 seconds."+"</p>"
	    
	  }
	  AJS.messages.success(o,{title:"Thank you for your feedback!",body:k,closeable:false});
	  m.prepend(o);
	  setTimeout(function(){window.top.postMessage("cancelFeedbackDialog","*")},5000)
	  
	},
	error:function(l,k,m){
	  d(l.status===400?JSON.parse(l.responseText):{})
	  
	}
	
      });*/
      function(data){
	  $("#img-loading").hide();
	  if(data["errors"] != null)
	  {
	    $( ".content-body" ).before('<div class="msg-container" id="error_message"><div class="aui-message error  shadowed "><p class="title"><span class="aui-icon icon-error"></span><strong>Warning!</strong></p><p>An error occurred during sending: JIRA issue. This window will automatically close in 5 seconds.</p><!-- .aui-message --></div></div>');
	    
	    $("#error_message").delay(5000).queue(function(next){
		$("#jic-collector-form").removeClass("disabled");
		$("input.submit-button").removeAttr('disabled');
		$("#error_message").hide(400,function(){$("#error_message").remove();});	      
		next();
	    });
	    
// 	    alert("An error occurred during sending: JIRA issue");
	  }
	  else
	  {
	    $( ".content-body" ).before('<div class="msg-container" id="success_message"><div class="aui-message success  shadowed "><p class="title"><span class="aui-icon icon-success"></span><strong>'+successMsg+'</strong></p><p>The issue can be tracked online at this link: <a href="http://jira.fi-ware.org/browse/'+data["key"]+'" target="_blank" class="issue-key">http://jira.fi-ware.org/browse/'+data["key"]+'</a>. This window will automatically close in 5 seconds.</p><!-- .aui-message --></div></div>');
	    
// 	    $("#success_message").delay(5000).hide(400);
	    $("#success_message").delay(5000).queue(function(next){
		$("#jic-collector-form").removeClass("disabled");
		$("input.submit-button").removeAttr('disabled');
		$("input#summary").val('');
		$("textarea#description").val('');
		$("input#customfield_10302").val('');
		$("input#customfield_10301").val('');
		$("#success_message").hide(400,function(){
		  $('#atlScriptlet').dialog('close');
		  $("#success_message").remove();
		  
		});	      
		next();
	    });

	    
// 	    $( "#success_message" ).remove();
	    
// 	    $( "#jic-collector-form" ).removeClass("disabled");
// 	    $("input.submit-button").removeAttr('disabled');
	    
	    
	    

	
// 	    alert("New issue created: "+data["key"]+"\nURL: "+ "http://jira.fi-ware.org/browse/"+data["key"]);
  // 									
	    
	  }
// 									$(this).dialog('close');
// alert("");
	},
	error: function(xhr, textStatus, errorThrown){
	  $("#img-loading").hide();
	  var errore = "retry later";
	  if(errorThrown != null && errorThrown != "" && errorThrown != "null")
	    errore = errorThrown;
// 	  alert("An error occurred during sending: "+errore);
	  
	  $( ".content-body" ).before('<div class="msg-container" id="error_message"><div class="aui-message error  shadowed "><p class="title"><span class="aui-icon icon-error"></span><strong>Warning!</strong></p><p>An error occurred during sending: '+errore+'. This window will automatically close in 5 seconds.</p><!-- .aui-message --></div></div>');
	    
	  $("#error_message").delay(5000).queue(function(next){
	      $("#jic-collector-form").removeClass("disabled");
	      $("input.submit-button").removeAttr('disabled');
	      $("#error_message").hide(400,function(){$("#error_message").remove();});	      
	      next();
// 	      .clearQueue();
	  });
	    
// 	    alert("An error occurred during sending: JIRA issue");
	  
	}
      });

      
  }
};