{if $auth.user_id}
    <form action="{"rfq_request.send_request"|fn_url}"
          method="post"
          class="cm-form-dialog-closer ty-product-review-new-product-review__form"
          name="rfq_request_form"
          enctype="multipart/form-data"
          id="rfq_request_form"
    >
        <div class="ty-product-review-new-product-review__body">
            <input name="return_url" type="hidden" value="{$smarty.request.return_url|default:$config.current_url}">
            <input name="section" type="hidden" value="{$section}">
            <input name="rfq_request[user_id]" type="hidden" value="{$auth.user_id}">
            <p>{__('rfq_request_form_title')}</p>
            <div class="ty-control-group">
                <label for="rfq_request_categories" class="ty-control-group__title">{__("category")}</label>
                {assign var='categories' value=fn_get_categories_tree()}
                {assign var='flat_categories' value=$categories|fn_order_extending_flatten_categories}

                <select name="rfq_request[category]" id="rfq_request_categories" required>
                    <option value="">-- Выберите категорию --</option>
                    {foreach $flat_categories as $cat}
                        <option value="{$cat.category_id}">{$cat.category_name}</option>
                    {/foreach}
                </select>
            </div>

            <div class="ty-control-group">
                <label class="ty-control-group__title">{__("vendors")}</label>
                <div id="vendors" class="ty-input-checkbox-group">
                    <div>
                        <label><input type="checkbox" id="select_all_vendors"> {__("select_all")}</label>
                    </div>

                    <div id="vendors_select_wrapper_{$section}">
                        {foreach $vendors as $vendor_id => $vendor}
                            <div class="ty-input-checkbox-item">
                                <label>
                                    <input type="checkbox" name="rfq_request[vendors][]" value="{$vendor_id}" checked>
                                    {$vendor.company}
                                </label>
                            </div>
                        {/foreach}
                        <p><span id="vendors_selected_count_{$section}">{__("selected")}: {if !empty($vendors)}{count($vendors)}{else}0{/if}</span></p>
                        <!--vendors_select_wrapper_{$section}--></div>
                </div>

            </div>

            <div class="ty-control-group">
                <label for="rfq_request_task_description" class="ty-control-group__title">{__("description")}<span class="cm-required">*</span></label>
                <textarea id="rfq_request_task_description" name="rfq_request[task_description]" class="ty-input-textarea" rows="5" required></textarea>
            </div>

            <div class="ty-control-group">
                <label class="ty-control-group__title">{__("upload_files")}</label>
                <div class="ty-product-options__fileuploader">
                    {include file="common/fileuploader.tpl"
                        var_name="rfq_files_{$section}[0]"
                        allowed_ext="pdf,docx,xlsx,csv,jpg,png,zip"
                        multiupload=true
                        max_upload_filesize='100M'
                    }
                </div>
            </div>

            <div class="ty-control-group">
                <label for="rfq_request_comparison_criteria" class="cm-check-comparison-criteria ty-control-group__title">{__("comparison_criteria")}</label>
                <textarea id="rfq_request_comparison_criteria"
                          name="rfq_request[comparison_criteria]"
                          class="ty-input-textarea"
                          rows="6"
                ></textarea>
                <div class="ty-help-block">
                    <i class="ty-icon-help-circle"></i>
                    {__("each_criterion_becomes_column", ["example" => "материал, точность, допуски…"])}
                </div>
            </div>

            <div class="ty-control-group">
                <label for="deadline" class="ty-control-group__title">{__("deadline")} <span class="cm-required">*</span></label>
                <select name="rfq_request[deadline]" id="rfq_request_deadline" class="ty-input-text" required>
                    {section name=day start=1 loop=15}
                        <option value="{$smarty.section.day.index}" {if $smarty.section.day.index == 3}selected{/if}>
                            {$smarty.section.day.index}
                        </option>
                    {/section}
                </select>
            </div>

            <div class="ty-control-group">
                <label>
                    <input type="checkbox" name="consent" required>
                    {__("i_consent_data_transfer")}
                    <span class="cm-required">*</span></label>
            </div>

            <div class="buttons-container ty-mt-s">
                {include file="buttons/button.tpl"
                but_text=__("place_order")
                but_role="submit"
                but_meta="ty-btn__primary ty-btn cm-submit"}
            </div>
        </div>
    </form>

    <style>
        #rfq_request_form [id^="rfq_request_"] {
            width: 100%;
        }
    </style>

    <script>
        (function(_, $) {
            $.ceEvent('on', 'ce.commoninit', function(context) {
                $('#rfq_request_categories').on('change', function() {
                    var categoryId = $(this).val();
                    if (!categoryId) {
                        $('#vendors_list').empty();
                        $('#vendors_selected_count').text('{__("selected")|escape:javascript}: 0');
                        return;
                    }
                    $.ceAjax('request', fn_url('rfq_request.get_vendors_by_category?category_id=' + categoryId + '&section={$section}'), {
                        hidden: false,
                        result_ids: 'vendors_select_wrapper_{$section}'
                    });
                });

                $('#vendors').on('change', '#select_all_vendors', function() {
                    var checked = $(this).is(':checked');
                    $('#vendors_select_wrapper_{$section} input[type="checkbox"][name="rfq_request[vendors][]"]').prop('checked', checked);

                    var count = checked ? $('#vendors_select_wrapper_{$section} input[type="checkbox"][name="rfq_request[vendors][]"]').length : 0;
                    $('#vendors_selected_count_{$section}').text('{__("selected")|escape:javascript}: ' + count);
                });

                $('#vendors').on('change', 'input[type="checkbox"][name="rfq_request[vendors][]"]', function() {
                    var total = $('#vendors_select_wrapper_{$section} input[type="checkbox"][name="rfq_request[vendors][]"]').length;
                    var checked = $('#vendors_select_wrapper_{$section} input[type="checkbox"][name="rfq_request[vendors][]"]:checked').length;

                    $('#vendors_selected_count_{$section}').text('{__("selected")|escape:javascript}: ' + checked);
                    $('#select_all_vendors').prop('checked', total === checked && total > 0);
                });
            });
        }(Tygh, Tygh.$));
    </script>
{else}
    {include file="views/auth/popup_login_form.tpl" title=__("authorize_before_order")}
{/if}