{capture name="mainbox"}

    <form action="{""|fn_url}" method="post" id="shipments_form" name="manage_shipments_form">

        {include file="common/pagination.tpl" save_current_page=true save_current_url=true}

        {$c_url = $config.current_url|fn_query_remove:"sort_by":"sort_order"}

        {if $rfq_requests}

            <div id="rfq_requests_content">
                {capture name="rfq_requests_table"}
                    <div class="table-responsive-wrapper longtap-selection">
                        <table width="100%" class="table table-middle table--relative table-responsive">
                            <thead class="thead--overflow-hidden" data-ca-bulkedit-default-object="true">
                            <tr>
                                <th class="center mobile-hide table__check-items-column">
                                    {include file="common/check_items.tpl"
                                    check_statuses=$request_statuses
                                    meta="table__check-items"
                                    }

                                    <input type="checkbox"
                                           class="bulkedit-toggler hide"
                                           data-ca-bulkedit-disable="[data-ca-bulkedit-default-object=true]"
                                           data-ca-bulkedit-enable="[data-ca-bulkedit-expanded-object=true]"
                                    />
                                </th>
                                <th width="1%">
                                    {include file="common/table_col_head.tpl" type="id" text=__("request_id")}
                                </th>
                                <th width="12%">
                                    {include file="common/table_col_head.tpl" type="user_id"}
                                </th>
                                <th width="14%">
                                    {include file="common/table_col_head.tpl" type="category"}
                                </th>
                                <th width="14%">
                                    {include file="common/table_col_head.tpl" type="created_at"}
                                </th>
                                <th width="22%">
                                    {include file="common/table_col_head.tpl" type="deadline"}
                                </th>
                                <th width="8%">&nbsp;</th>
                                <th width="10%" class="right">
                                    {include file="common/table_col_head.tpl" type="status"}
                                </th>
                            </tr>
                            </thead>
                            {foreach from=$rfq_requests item=rqf_request}
                                <tr class="cm-longtap-target cm-row-status-{$rqf_request.status|lower}"
                                    data-ca-longtap-action="setCheckBox"
                                    data-ca-longtap-target="input.cm-item"
                                    data-ca-id="{$rqf_request.request_id}"
                                    data-ca-bulkedit-dispatch-parameter="rfq_request_ids[]"
                                >
                                    <td class="center mobile-hide table__check-items-cell">
                                        <input type="checkbox" name="rfq_request_ids[]" value="{$rqf_request.request_id}" class="cm-item cm-item-status-{$rqf_request.status|lower} hide" />
                                    </td>
                                    <td width="20%" data-th="{__("request_id")}" class="table__first-column">
                                        <a class="underlined link--monochrome" href="{"rfq_requests.details&request_id=`$rqf_request.request_id`"|fn_url}"><span>#{$rqf_request.request_id}</span></a>
                                    </td>
                                    <td width="12%" data-th="{__("user_id")}">
                                        <a class="underlined link--monochrome" href="{"profiles.update&user_id=`$rqf_request.user_id`"|fn_url}"><span>{$rqf_request.user_id}</span></a>
                                    </td>
                                    <td width="14%" data-th="{__("category")}">
                                        <a class="underlined link--monochrome" href="{"categories.update&category_id=`$rqf_request.category_id`"|fn_url}"><span>{$rqf_request.category_id|fn_get_category_name}</span></a>
                                    </td>

                                    <td width="24%" data-th="{__("created_at")}">
                                        <p>{$rqf_request.created_at}</p>
                                    </td>

                                    <td width="24%" data-th="{__("deadline")}">
                                        <p>{$rqf_request.response_deadline_days}</p>
                                    </td>

                                    <td width="8%" class="nowrap" data-th="{__("tools")}">
                                        <div class="hidden-tools">
                                            {assign var="return_current_url" value=$config.current_url|escape:url}
                                            {capture name="tools_list"}
                                                {hook name="shipments:list_extra_links"}
                                                    <li>{btn type="list" text=__("view") href="rqf_requests.details?request_id=`$rqf_request.request_id`"}</li>
                                                    <li>{btn type="list" text=__("delete") class="cm-confirm" href="rqf_requests.delete?rfq_request_ids[]=`$rqf_request.request_id`&redirect_url=`$return_current_url`" method="POST"}</li>
                                                {/hook}
                                            {/capture}
                                            {dropdown content=$smarty.capture.tools_list}
                                        </div>

                                    </td>
                                    <td width="10%" class="right" data-th="{__("status")}">
                                        {include file="common/select_popup.tpl" type="rqf_request" id=$rqf_request.request_id status=$rqf_request.status items_status=$request_statuses table="rfq_requests" object_id_name="request_id" popup_additional_class="dropleft"}
                                    </td>

                                </tr>
                            {/foreach}
                        </table>
                    </div>
                {/capture}

                {include file="common/context_menu_wrapper.tpl"
                form="manage_shipments_form"
                object="rfq_requests"
                items=$smarty.capture.rfq_requests_table
                }
                <!--rfq_requests_content--></div>
        {else}
            <p class="no-items">{__("no_data")}</p>
        {/if}

        {include file="common/pagination.tpl"}
    </form>
{/capture}

{capture name="buttons"}
    {capture name="tools_list"}

    {/capture}
    {if $smarty.capture.tools_list|trim}
        {dropdown content=$smarty.capture.tools_list}
    {/if}
{/capture}

{capture name="sidebar"}
    {include file="common/saved_search.tpl" dispatch="rfq_requests.manage" view_type="rfq_requests"}
    {include file="views/shipments/components/shipments_search_form.tpl" dispatch="shipments.manage"}
{/capture}

{capture name="title"}
    {strip}
        {__("rfq_requests")}
    {/strip}
{/capture}
{include file="common/mainbox.tpl" title=$smarty.capture.title content=$smarty.capture.mainbox sidebar=$smarty.capture.sidebar buttons=$smarty.capture.buttons}
