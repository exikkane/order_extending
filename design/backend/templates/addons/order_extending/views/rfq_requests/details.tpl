{capture name="mainbox"}
    <form action="{""|fn_url}" method="post" enctype="multipart/form-data" name="rfq_request_form" class="form-horizontal form-edit">

        <input type="hidden" name="rfq_request[request_id]" value="{$rfq_request.request_id}" />

        <div class="control-group">
            <label class="control-label">{__("user")}</label>
            <div class="controls">
                <div class="text-type">{$rfq_request.user_id}</div>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">{__("vendors")}</label>
            <div class="controls">
                <div class="text-type">{$rfq_request.vendors_ids}</div>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">{__("task_description")}</label>
            <div class="controls">
                <div class="text-type">{$rfq_request.task_description}</div>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label ">{__("file")}</label>
            <div class="controls">
                {if $rfq_request.filename}
                    <div class="text-type-value">
                        <a href="{"rfq_requests.getfile?request_id=`$rfq_request.request_id`"|fn_url}">{$rfq_request.filename}</a>
                    </div>
                {/if}
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">{__("comparison_criteria")}</label>
            <div class="controls">
                <div class="text-type">{$rfq_request.comparison_criteria}</div>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label">{__("deadline")}</label>
            <div class="controls">
                <div class="text-type">{$rfq_request.response_deadline_days}</div>
            </div>
        </div>

        {include file="common/select_status.tpl" input_name="rfq_request[status]" id="elm_rfq_request_form_status" obj=$rfq_request items_status=$request_statuses}

    </form>
{/capture}

{capture name="buttons"}
    {include file="buttons/save.tpl" but_name="dispatch[rfq_requests.update_status]" but_role="submit-link" but_target_form="rfq_request_form"}
{/capture}

{include file="common/mainbox.tpl"
title=$rfq_request.request_id
content=$smarty.capture.mainbox
select_languages=true
buttons=$smarty.capture.buttons
sidebar=$smarty.capture.sidebar
}
