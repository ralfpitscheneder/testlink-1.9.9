{* 
TestLink Open Source Project - http://testlink.sourceforge.net/
$Id: tcNew.tpl,v 1.18.2.3 2011/01/14 14:39:04 asimon83 Exp $
Purpose: smarty template - create new testcase
*}

{assign var="cfg_section" value=$smarty.template|basename|replace:".tpl":""}
{config_load file="input_dimensions.conf" section=$cfg_section}

{lang_get var='labels' s='btn_create,cancel,warning,title_new_tc,
                          warning_empty_tc_title,warning_unsaved,stay_here_tc'}

{*{include file="inc_head.tpl" openHead='yes' jsValidate="yes"}*}
{*{include file="inc_del_onclick.tpl"}*}
<script language="JavaScript" src="gui/javascript/OptionTransfer.js" type="text/javascript"></script>
<script language="JavaScript" src="gui/javascript/expandAndCollapseFunctions.js" type="text/javascript"></script>
<script language="javascript" src="gui/javascript/tcase_utils.js" type="text/javascript"></script>

{assign var="opt_cfg" value=$gui->opt_cfg}
<script language="JavaScript" type="text/javascript">
var {$opt_cfg->js_ot_name} = new OptionTransfer("{$opt_cfg->from->name}","{$opt_cfg->to->name}");
{$opt_cfg->js_ot_name}.saveRemovedLeftOptions("{$opt_cfg->js_ot_name}_removedLeft");
{$opt_cfg->js_ot_name}.saveRemovedRightOptions("{$opt_cfg->js_ot_name}_removedRight");
{$opt_cfg->js_ot_name}.saveAddedLeftOptions("{$opt_cfg->js_ot_name}_addedLeft");
{$opt_cfg->js_ot_name}.saveAddedRightOptions("{$opt_cfg->js_ot_name}_addedRight");
{$opt_cfg->js_ot_name}.saveNewLeftOptions("{$opt_cfg->js_ot_name}_newLeft");
{$opt_cfg->js_ot_name}.saveNewRightOptions("{$opt_cfg->js_ot_name}_newRight");
</script>

{literal}
<script type="text/javascript">
{/literal}
//BUGID 3943: Escape all messages (string)
var alert_box_title = "{$labels.warning|escape:'javascript'}";
var warning_empty_testcase_name = "{$labels.warning_empty_tc_title|escape:'javascript'}";
{literal}
function validateForm(f)
{
  // get the div that contains the custom fields, accession by id
 	var cf_designTime = document.getElementById('cfields_design_time');
  if (isWhitespace(f.testcase_name.value)) 
  {
      alert_message(alert_box_title,warning_empty_testcase_name);
      selectField(f, 'testcase_name');
      return false;
  }
  
  /* BUGID 3874 - custom fields type validation */
  /* Validation of a limited type of custom fields */
	if (cf_designTime)
 	{
 		var cfields_container = cf_designTime.getElementsByTagName('input');
 		var cfieldsChecks = validateCustomFields(cfields_container);
		if(!cfieldsChecks.status_ok)
	  {
	    	var warning_msg = cfMessages[cfieldsChecks.msg_id];
	      alert_message(alert_box_title,warning_msg.replace(/%s/, cfieldsChecks.cfield_label));
	      return false;
		}

 		cfields_container = cf_designTime.getElementsByTagName('textarea');
 		cfieldsChecks = validateCustomFields(cfields_container);
		if(!cfieldsChecks.status_ok)
	  {
	    	var warning_msg = cfMessages[cfieldsChecks.msg_id];
	      alert_message(alert_box_title,warning_msg.replace(/%s/, cfieldsChecks.cfield_label));
	      return false;
		}
	}

  return true;
}
{/literal}
</script>

{if $tlCfg->gui->checkNotSaved}
  <script type="text/javascript">
  var unload_msg = "{$labels.warning_unsaved|escape:'javascript'}";
  var tc_editor = "{$editorType}";
  $(document).ready(function(){
    $('.ui-button').click(function(){
            if (CKEDITOR.instances['details']) {
                CKEDITOR.remove(CKEDITOR.instances['details']);
            }
            if (CKEDITOR.instances['summary']) {
                CKEDITOR.remove(CKEDITOR.instances['summary']);
            }
            if (CKEDITOR.instances['preconditions']) {
                CKEDITOR.remove(CKEDITOR.instances['preconditions']);
            }
        });
    })
  </script>
  
  <script src="gui/javascript/checkmodified.js" type="text/javascript"></script>
{/if}

</head>

<body onLoad="{$opt_cfg->js_ot_name}.init(document.forms[0]);focusInputField('testcase_name')">

<h1 class="title">{$gui->main_descr|escape}</h1>
<div class="workBack">

{* BUGID 4067 *}
{include file="inc_update.tpl" result=$gui->sqlResult item="testcase" name=$gui->name user_feedback=$gui->user_feedback refresh=$smarty.session.setting_refresh_tree_on_action}

<form method="post" action="lib/testcases/tcEdit.php?containerID={$gui->containerID}"
      name="tc_new" id="tc_new"
      onSubmit="javascript:return validateForm(this);">
      <input type="hidden" name="testcase_id" id="testcase_id" value=0>
      <input type="hidden" name="testsuite_id" id="testsuite_id" value="{$gui->containerID}">

  {if $gui->steps != ''}
  <table class="simple">
  	<tr>
  		<th width="{$tableColspan}">{$labels.step_number}</th>
  		<th>{$labels.step_details}</th>
  		<th>{$labels.expected_results}</th>
  		<th width="25">{$labels.execution_type_short_descr}</th>
  	</tr>
  
   	{foreach from=$gui->steps item=step_info}
  	<tr>
  		<td style="text-align:righ;">{$step_info.step_number}</td>
  		<td >{$step_info.actions}</td>
  		<td >{$step_info.expected_results}</td>
  		<td>{$gui->execution_types[$step_info.execution_type]}</td>
  	</tr>
    {/foreach}	
  </table>	
  <p>
  <hr>
  {/if}



	<div class="groupBtn">
           
			<input type="hidden" id="do_create"  name="do_create" value="do_create" />
			<input type="submit" id="do_create_button"  name="do_create_button" value="{$labels.btn_create}" 
			       onclick="show_modified_warning=false;" style="display:none" />
			<input style="display:none" type="button" name="go_back" value="{$labels.cancel}" 
			       onclick="javascript: show_modified_warning=false; history.back();" style="display:none"/>

                        <input type="checkbox" id="stay_here"  style="display:none" name="stay_here" 
         {if $gui->stay_here} checked="checked" {/if}/> {$labels.stay_here_tc}


	</div>

	{include file="testcases/tcEdit_New_viewer.tpl"}

	<div class="groupBtn">
			<input type="hidden" id="do_create_2"  name="do_create" value="do_create" />
			<input type="submit" id="do_create_button_2"  name="do_create_button" value="{$labels.btn_create}" 
			       onclick="show_modified_warning=false;" />
			<input style="display:none" type="button" name="go_back" value="{$labels.cancel}" 
			       onclick="javascript: show_modified_warning=false; history.back();"/>
	</div>	
  
</form>
</div>

{* BUGID 4067 *}
{if $gui->sqlResult eq 'ok'}
	{if isset($gui->refreshTree) && $gui->refreshTree}
		{include file="inc_refreshTreeWithFilters.tpl"}
	{/if}
{/if}

</body>
</html>