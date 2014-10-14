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

function setLoadingJiraDialogFun(){
  $("input.submit-button").attr('disabled', 'disabled');
  $( "#jic-collector-form" ).addClass("disabled");
  $( "#img-loading" ).show();
}

function setActiveJiraDialogFun(){
  $("#img-loading").hide();
  $("#jic-collector-form").removeClass("disabled");
  $("input.submit-button").removeAttr('disabled');
}

function resetFormElement(e) {
  e.wrap('<form>').closest('form').get(0).reset();
  e.unwrap();
}

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
      
      //data to be sent to server        
      var m_data = new FormData(); 
      m_data.append( 'region_id', regionId);
      m_data.append( 'environment_id', environmentId);
      m_data.append( 'priority', priority);
      m_data.append( 'summary', summary);
      m_data.append( 'description', description);
      m_data.append( 'name', name);
      m_data.append( 'email', email);
      m_data.append( 'file_attach', $('input#screenshot')[0].files[0]);
  
      setLoadingJiraDialogFun();
    
      $.ajax({ 
	type: 'POST', 
	url: "http://status.lab.fi-ware.org/api/v1/jira/issue",
	processData: false,
        contentType: false,
	data: m_data/*{
	    'region_id' : regionId,
//	    'environment_id' : environmentId,
// 	    'type':type,
	    'priority':priority,
	    'summary':summary,
	    'description':description,
	    'name':name,
	    'email':email
	}*/,
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
	    $( ".content-body" ).before('<div class="msg-container" id="error_message"><div class="aui-message error  shadowed "><p class="title"><span class="aui-icon icon-error"></span><strong>Warning!</strong></p><p>An error occurred during sending: JIRA issue. Please conctact the email <a href="mailto:fiware-lab-help@lists.fi-ware.org">helpdesk</a>.  This window will automatically close in 5 seconds.</p><!-- .aui-message --></div></div>');
	    
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
	    $( ".content-body" ).before('<div class="msg-container" id="success_message"><div class="aui-message success  shadowed "><p class="title"><span class="aui-icon icon-success"></span><strong>'+$("input#successMsg").val()+'</strong></p><p>The issue can be tracked online at this link: <a href="http://jira.fi-ware.org/browse/'+data["key"]+'" target="_blank" class="issue-key">http://jira.fi-ware.org/browse/'+data["key"]+'</a>. This window will automatically close in 5 seconds.</p><!-- .aui-message --></div></div>');
	    
// 	    $("#success_message").delay(5000).hide(400);
	    $("#success_message").delay(5000).queue(function(next){
		$("#jic-collector-form").removeClass("disabled");
		$("input.submit-button").removeAttr('disabled');
		$("input#summary").val('');
		$("textarea#description").val('');
		$("input#customfield_10302").val('');
		$("input#customfield_10301").val('');
		resetFormElement($('#screenshot'));
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
	  
	  $( ".content-body" ).before('<div class="msg-container" id="error_message"><div class="aui-message error  shadowed "><p class="title"><span class="aui-icon icon-error"></span><strong>Warning!</strong></p><p>An error occurred during sending: '+errore+'. Please contact the email <a href="mailto:fiware-lab-help@lists.fi-ware.org">helpdesk</a>. This window will automatically close in 5 seconds.</p><!-- .aui-message --></div></div>');
	    
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

$(document).ready(function() {
  // some code here

if (!document.getElementById('batch'))
{
    var head  = document.getElementsByTagName('head')[0];
    var link  = document.createElement('link');
    link.id   = 'batch';
    link.rel  = 'stylesheet';
    link.type = 'text/css';
    link.href = 'http://status.lab.fi-ware.org/assets/batch.css';
    link.media = 'all';
    head.appendChild(link);
}
if (!document.getElementById('com.atlassian.auiplugin:aui-experimental-labels'))
{
    var head  = document.getElementsByTagName('head')[0];
    var link  = document.createElement('link');
    link.id   = 'batch';
    link.rel  = 'stylesheet';
    link.type = 'text/css';
    link.href = 'http://status.lab.fi-ware.org/assets/com.atlassian.auiplugin:aui-experimental-labels.css';
    link.media = 'all';
    head.appendChild(link);
}
if (!document.getElementById('com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:form-collector'))
{
    var head  = document.getElementsByTagName('head')[0];
    var link  = document.createElement('link');
    link.id   = 'batch';
    link.rel  = 'stylesheet';
    link.type = 'text/css';
    link.href = 'http://status.lab.fi-ware.org/assets/com.atlassian.jira.collector.plugin.jira-issue-collector-plugin:form-collector.css';
    link.media = 'all';
    head.appendChild(link);
}
if (!document.getElementById('jira.webresources:autocomplete'))
{
    var head  = document.getElementsByTagName('head')[0];
    var link  = document.createElement('link');
    link.id   = 'batch';
    link.rel  = 'stylesheet';
    link.type = 'text/css';
    link.href = 'http://status.lab.fi-ware.org/assets/jira.webresources:autocomplete.css';
    link.media = 'all';
    head.appendChild(link);
}
if (!document.getElementById('jira.webresources:global-static'))
{
    var head  = document.getElementsByTagName('head')[0];
    var link  = document.createElement('link');
    link.id   = 'batch';
    link.rel  = 'stylesheet';
    link.type = 'text/css';
    link.href = 'http://status.lab.fi-ware.org/assets/jira.webresources:global-static.css';
    link.media = 'all';
    head.appendChild(link);
}
if (!document.getElementById('xifi'))
{
    var head  = document.getElementsByTagName('head')[0];
    var link  = document.createElement('link');
    link.id   = 'batch';
    link.rel  = 'stylesheet';
    link.type = 'text/css';
    link.href = 'http://status.lab.fi-ware.org/assets/xifi.css';
    link.media = 'all';
    head.appendChild(link);
}

if(!jQuery.contains(document, $('#atlScriptlet')))
{
  var dialogHtmlStructure = '<!-- ------------------------------------------- -->'+
'<div id="atlwdg-container" class="atlwdg-popup atlwdg-box-shadow atlwdg-hidden" style="width: 810px; margin-top: -271px; margin-left: -405px; display: block;">'+
    '<!--<img src="http://jira.fi-ware.org/images/throbber/loading_barber_pole_horz.gif" style="display: none;" class="atlwdg-loading">-->'+
    '<div id="atlScriptlet" class="aui-dialog collector-dialog custom-collector" style="display:none;">'+
        '<h2 class="dialog-title">Report Issue</h2>'+
        '<form id="jic-collector-form" class="aui " action="http://jira.fi-ware.org/rest/collectors/1.0/template/custom/c3404461" method="POST">'+
	    '<img id="img-loading" src="http://status.lab.fi-ware.org/assets/infographic/jira/loading_barber_pole_horz.gif" style="display: none;margin: 25% 35%;position: absolute;z-index: 1000000;" class="atlwdg-loading">'+
            '<div class="content-body">'+
                '<div class="event-shield-wrapper">'+
                    '<div class="event-shield"></div>'+
                    '<div class="aui-message info custom-msg">'+
                        '<span class="aui-icon icon-info"></span>'+
			'<p>Please provide details in this form. Thanks!!</p>'+
		    '</div>'+
                    '<fieldset class="hidden parameters">'+
                        '<input title="projectKey" value="XIFI" type="hidden">'+
                        '<input title="issueType" value="1" type="hidden">'+
                        '<input title="customTemplate" value="true" type="hidden">'+
                        '<input title="customLabels" value="{&quot;name-group&quot;:&quot;&quot;,&quot;email-group&quot;:&quot;&quot;,&quot;customfield_10301&quot;:&quot;Email&quot;,&quot;customfield_10302&quot;:&quot;Name&quot;}" type="hidden">'+
                        '<input title="fields" value="[&quot;summary&quot;,&quot;customfield_10108&quot;,&quot;description&quot;,&quot;versions&quot;,&quot;priority&quot;,&quot;screenshots&quot;,&quot;customfield_10302&quot;,&quot;customfield_10301&quot;]" type="hidden">'+
                    '</fieldset>'+
                    '<input name="atl_token" value="BE6O-ZUVS-TB0B-H8VQ|6b881b8cb180bc0620bedbed29193fde2d49b14a|lin" type="hidden">'+
                    '<input name="pid" value="10700" type="hidden">'+
                    '<div class="custom-fields-container">'+
		        '<div class="field-group">'+
                            '<label for="summary">Summary<span class="aui-icon icon-required">Required</span></label>'+
			    '<input class="text long-field" id="summary" name="summary" value="" type="text">'+
                        '</div>'+
                        '<div class="field-group">'+
                            '<label for="customfield_10108">FI-WARE Environment</label>'+
			    '<select class="select cf-select" name="customfield_10108" id="customfield_10108" onChange="changeJiraEnvironmentFun();">'+
			        '<!--<option value="-1">None</option>-->'+
				'<option selected="selected" value="10100">FI-LAB</option>'+
                                '<option value="10101">Test-bed</option>'+
                                '<!--<option value="10102">Other</option>-->'+
			    '</select>'+
			'</div>'+
			'<div class="field-group">'+
			    '<label>Region</label><div id="regionNone">None</div>'+
			    '<select class="select cf-select" name="region" id="customfield_10109">'+
			    '<option selected="selected" value="0">None</option>'+
					    '<option value="1">Berlin</option>'+
						'<option value="2">Trento</option>'+
						'<option value="3">Prague</option>'+
			    '</select>'+
                        '</div>'+
                        '<div class="field-group">'+
                            '<label for="description">Description</label>'+
			    '<div class="wiki-edit">'+
			        '<div id="description-wiki-edit" class="wiki-edit-content">'+
                                    '<textarea style="overflow-y: auto; height: 200px;" class="textarea long-field wiki-textfield long-field mentionable" id="description" name="description" rows="12" wrap="virtual" data-projectkey="XIFI"></textarea>'+
				    '<div class="content-inner">'+            
				    '</div>'+
				'</div>'+
			    '</div>'+
			    '<div class="field-tools">'+
			    '<!--<a class="fullscreen" href="#" id="description-preview_link" title="preview"><span class="aui-icon wiki-renderer-icon"></span></a>-->'+
			        '<a class="help-lnk" id="viewHelp" href="http://jira.fi-ware.org/secure/WikiRendererHelpAction.jspa?section=texteffects" title="Get local help about wiki markup help" data-helplink="local" target="_blank">'+
			            '<span class="aui-icon aui-icon-small aui-iconfont-help"></span>'+
			        '</a>'+
			    '</div>'+
			 '</div>'+
			 '<div class="field-group">'+
                             '<label for="priority">Priority</label>'+
			      '<!--<div class="aui-ss aui-ss-has-entity-icon" id="priority-single-select"><input id="priority-field" class="text aui-ss-field ajs-dirty-warning-exempt" autocomplete="off" value="Critical"><div class="aui-list" id="priority-suggestions" tabindex="-1"></div><span class="icon aui-ss-icon noloading drop-menu"><span>More</span></span><img class="aui-ss-entity-icon" src="/assets/infographic/jira/critical.png" alt=""></div>-->'+
			     '<select id="priority" name="priority">'+
			         '<option class="imagebacked" data-icon="/assets/infographic/jira/blocker.png" value="1">Blocker</option>'+
				'<option class="imagebacked" data-icon="/assets/infographic/jira/critical.png" value="2">Critical</option>'+
				'<option class="imagebacked" selected="selected" data-icon="/assets/infographic/jira/major.png" value="3">Major</option>'+
				'<option class="imagebacked" data-icon="/assets/infographic/jira/minor.png" value="4">Minor</option>'+
				'<option class="imagebacked" data-icon="/assets/infographic/jira/trivial.png" value="5">Trivial</option>'+
			     '</select>'+
			    '<!--<select multiple="multiple" style="display: none;" class="select aui-ss-select" id="priority" name="priority">'+
					    '<option class="imagebacked" data-icon="/assets/infographic/jira/blocker.png" value="1">'+
						'Blocker'+
					    '</option>'+
					    '<option class="imagebacked" data-icon="/assets/infographic/jira/critical.png" value="2">'+
						'Critical'+
					    '</option>'+
					    '<option class="imagebacked" selected="selected" data-icon="/assets/infographic/jira/major.png" value="3">'+
						'Major'+
					    '</option>'+
					    '<option class="imagebacked" data-icon="/assets/infographic/jira/minor.png" value="4">'+
						'Minor'+
					    '</option>'+
					    '<option class="imagebacked" data-icon="/assets/infographic/jira/trivial.png" value="5">'+
						'Trivial'+
					    '</option>'+
				'</select>-->'+
			     '<a class="help-lnk" href="http://jira.fi-ware.org/secure/ShowConstantsHelp.jspa?decorator=popup#PriorityLevels" title="Get local help about Priority" data-helplink="local" target="_blank">'+
			         '<span class="aui-icon aui-icon-small aui-iconfont-help"></span>'+
			     '</a>'+
			 '</div>'+
			 '<div id="screenshot-group" class="field-group">'+
			     '<label><span>Attach file</span></label>'+
			     '<input multiple="multiple" name="screenshot" class="file" id="screenshot" type="file">'+
			 '</div>'+
			 '<div class="field-group">'+
                             '<label for="customfield_10302">Name<span class="aui-icon icon-required">Required</span></label>'+
			     '<input class="textfield text long-field" id="customfield_10302" name="customfield_10302" maxlength="254" value="" type="text">'+
			     '<!--<div class="description">This custom field it used to input from collectors and similar, the name of the external user.</div>-->'+
			 '</div>'+
			 '<div class="field-group">'+
                             '<label for="customfield_10301">Email<span class="aui-icon icon-required">Required</span></label>'+
			     '<input class="textfield text long-field" id="customfield_10301" name="customfield_10301" maxlength="254" value="" type="text">'+
		         '</div>'+
		     '</div>'+

		     '<fieldset class="hidden parameters">'+
		         '<input id="successMsg" title="successMsg" value="" type="hidden">'+
			 '<input title="collectorId" value="c3404461" type="hidden">'+
			 '<input name="pid" value="10700" type="hidden">'+
			 '<input name="atl_token" value="BE6O-ZUVS-TB0B-H8VQ|6b881b8cb180bc0620bedbed29193fde2d49b14a|lin" type="hidden">'+
			 '<div id="attach-max-size" class="hidden">10485760</div>'+
			     '<input multiple="multiple" class="hidden" name="_tricky_" type="file">'+
		     '</fieldset>'+
		    '<!--<div class="aui-message info login-msg"><span class="aui-icon icon-info"></span>'+
			    'We\'ve currently got you logged in as <a href="http://jira.fi-ware.org/secure/ViewProfile.jspa?name=dimeo"'+ 'target="_blank">Katarzyna Di Meo </a>. This feedback will be created using this user unless this is <a href="#" id="not-you-lnk">not you.</a>'+
		    '</div>-->'+


		    '<!--<div id="name-group" class="contact-form-fields field-group hidden">'+
			'<label for="fullname">Name</label>'+
			'<input name="fullname" class="text" id="fullname" type="text">'+
		    '</div>'+

		    '<div id="email-group" class="contact-form-fields field-group hidden">'+
			'<label for="email">Email</label>'+
			'<input name="email" class="text" id="email" type="text">'+
		    '</div>-->'+

		     '<input name="webInfo" id="webInfo" value="" type="hidden">'+
		'</div>'+
	    '</div>'+
	    '<div class="dialog-button-panel">'+
		'<input class="button button-panel-button submit-button" value="Submit" type="button" onclick="submitJiraFun();">'+
		'<div class="cancel" onclick="$(\'input#summary\').val(\'\');$(\'textarea#description\').val(\'\');resetFormElement($(\'#screenshot\'));$(\'#atlScriptlet\').dialog(\'close\');">Close</div>'+
	    '</div>'+
	'</form>'+
    '</div>'+
'</div>'+
'<!-- ------------------------------------------- -->'+

'<div class="clear"></div>';
  $( "body" ).append(dialogHtmlStructure);
}

$('#atlScriptlet').dialog({
  closeOnEscape: true,
  resizable: false,
  modal: true,
  width: '810', 
  height: '562',
  fluid: true,					      
  autoOpen: false,
  autoResize: true,
  show: 'fade',
  hide: 'fade',
  buttons: {
  // 						    'Close': function() {
  // 								$("input#summary").val('');
  // 								$("textarea#description").val('');
  // 								$(this).dialog('close');
  // 							      },
  // 						    'Submit': function() {
  // 			  // 				      $('#mainForm input#target').val( $(this).find('#widgetName').val() );
  // 								if($("input#summary").val() == "" || $("input#email").val() == "")
  // 								{
  // 								    alert("Please fill all fields marked with *");
  // 								}
  // 								else if(!isValidEmailAddress($("input#email").val()))
  // 								{
  // 								    alert("Please enter a valid email address");
  // 								}
  // 								else 
  // 								{
  // 								    var regionId = $("#customfield_10108").val();
  // 								    var type = $("#type").val();
  // 								    var priority = $("#priority").val();
  // 								    var summary = $("input#summary").val();
  // 								    var description = $("textarea#description").val();
  // 								    var email = $("input#email").val();
  // 								
  // 								    $.ajax({ 
  // 								      type: 'POST', 
  // 								      url: "../api/v1/jira/issue",
  // 								      data: {
  // 									  'region_id' : regionId,
  // 									  'type':type,
  // 									  'priority':priority,
  // 									  'summary':summary,
  // 									  'description':description,
  // 									  'email':email
  // 								      },
  // 								      dataType: "json",
  // 								      cache: false, 
  // 								      success: function(data){
  // 									$("input#summary").val('');
  // 									$("textarea#description").val('');
  // // 									
  // 									$('#atlScriptlet').dialog('close');
  // // 									$(this).dialog('close');
  // // alert("");
  // 								      },
  // 								      error: function(xhr, textStatus, errorThrown){
  // 									var errore = "retry later";
  // 									if(errorThrown != null && errorThrown != "" && errorThrown != "null")
  // 									  errore = errorThrown;
  // 									alert("An error occurred during sending: "+errore);
  // 								      }
  // 								    });
  // 
  // 								    
  // 								}
  // 							      }
      },
  open: function (event, ui) {
    $(this).css("zIndex", "1000");
  // 						  $(this).css("overflow-y", "auto");
  // 						  $(this).css("overflow-x", "hidden");
      changeJiraEnvironmentFun();
      
      $(".ui-dialog-titlebar-close").hide();
      setLoadingJiraDialogFun();						    
  // 						  var allNodes = JSON.parse(decodeURIComponent($('#atlScriptlet').data('allNodes')));
  // 						  var nodeSelected = allNodes["selected"]["name"];

      $.ajax (
      {
	    type: "GET",
	    url: "http://status.lab.fi-ware.org/api/v1/region/list",
	    contentType: "application/json; charset=utf-8",
	    data: {},
	    dataType: "json",
	    cache: false,
	    success: function(json){

		var htmlOptions = "<option value='none'>None</option>";
      
		$.each(json["list"], function( index, value ) {
		    var selected = "";
		    if($('#atlScriptlet').data('regionSelected') != null && 
			value == $('#atlScriptlet').data('regionSelected')) 
		    {
		      selected = "selected='selected'";
		    }
		    htmlOptions = htmlOptions + "<option "+selected+" value='"+value+"'>"+value+"</option>";
		});
		
		$("#customfield_10109").html(htmlOptions);
		$("input#successMsg").val(json["successMsg"]);
		setActiveJiraDialogFun();
	    },
	    error: function(xhr, textStatus, errorThrown){
		$("#img-loading").hide();
		var errore = "db error";
		if(errorThrown != null && errorThrown != "" && errorThrown != "null")
		  errore = errorThrown;
      // 	  alert("An error occurred during sending: "+errore);
		
		$( ".content-body" ).before('<div class="msg-container" id="error_message"><div class="aui-message error  shadowed "><p class="title"><span class="aui-icon icon-error"></span><strong>Warning!</strong></p><p>An error occurred: '+errore+'. This window will automatically close in 5 seconds.</p><!-- .aui-message --></div></div>');
		  
		$("#error_message").delay(5000).queue(function(next){
		    $("#jic-collector-form").removeClass("disabled");
		    $("input.submit-button").removeAttr('disabled');
		    $("#error_message").hide(400,function(){
			$('#atlScriptlet').dialog('close');
			$("#error_message").remove();
		    });	      
		    next();
      // 	      .clearQueue();
		});
  // 							    var errore = "<%= FiLabInfographics.nodata %>";
  // 							    if(xhr.responseText != null && xhr.responseText != "" && xhr.responseText != "null")
  // 								    errore = xhr.responseText;
  // 							    $('#tableHeaderContent').html("<DIV CLASS='field field-header'>"+errore+"</DIV>");
  //     				alert('request failed->'+textStatus);
  //     				console.log(xhr.status + ' çççç'+xhr.body+'òòòò' + textStatus + ' ' + errorThrown);
	    } 
      });
      
      
  // 						  $(this).parents(".ui-dialog:first").css('background-color','#ffffff');
  // 						  $(this).parents(".ui-dialog:first").css('color','gray');
  // 						  $(this).parents(".ui-dialog:first").css('padding','15px');
  // 						  $(this).parents(".ui-dialog:first").css('text-align','left');
      }
  });
});
