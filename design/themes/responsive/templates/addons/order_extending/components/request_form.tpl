<form action="{""|fn_url}"
      method="post"
      class="cm-ajax cm-form-dialog-closer ty-product-review-new-product-review__form"
      name="rfq_request_form"
      enctype="multipart/form-data"
      id="rfq_request_form"
>
    <div class="ty-product-review-new-product-review__body" id="new_post_{$product_id}">
    <input name="return_url" type="hidden" value="{$smarty.request.return_url|default:$config.current_url}">

    <p> Мы соберем предложения от выбранных поставщиков и пришлём
        вам конкурентную карту для сравнения</p>

    <div class="ty-control-group">
        <label for="rfq_request_categories" class="ty-control-group__title">{__("category")}</label>
        <select name="rfq_request[category]" id="rfq_request_categories" class="ty-input-text">
            {foreach $categories as $cat}
                <option value="{$cat}">{$cat}</option>
            {/foreach}
        </select>
    </div>

    <div class="ty-control-group">
        <label class="ty-control-group__title">{__("vendors")}</label>
        <div id="vendors" class="ty-input-checkbox-group">
            <div>
                <label><input type="checkbox" id="select_all_vendors"> {__("select_all")}</label>
            </div>
            {foreach $vendors as $vendor}
                <div class="ty-input-checkbox-item">
                    <label>
                        <input type="checkbox" name="rfq_request[vendors][]" value="{$vendor.vendor_id}" checked>
                        {$vendor.name}
                    </label>
                </div>
            {/foreach}
        </div>
        <p><span id="vendors_selected_count">{__("selected")}: 0}</span></p>
    </div>

    <div class="ty-control-group">
        <label for="rfq_request_task_description" class="ty-control-group__title">{__("description")}</label>
        <textarea id="rfq_request_task_description" name="rfq_request[task_description]" class="ty-input-textarea" rows="5" required></textarea>
    </div>

    <div class="ty-control-group">
        <label class="ty-control-group__title">{__("upload_files")}</label>
        <div class="ty-product-options__fileuploader">
            {include file="common/fileuploader.tpl"
            var_name="rfq_files"
            multiupload=true
            max_uploads=10
            allowed_ext="pdf,docx,xlsx,csv,jpg,png,zip"
            max_filesize=31457280
            }
        </div>
    </div>

    <div class="ty-control-group">
        <label for="rfq_request_comparison_criteria" class="ty-control-group__title">{__("comparison_criteria")}</label>
        <textarea id="rfq_request_comparison_criteria"
                  name="rfq_request[comparison_criteria]"
                  class="ty-input-textarea"
                  rows="6"
                  placeholder="{__("one_per_line")} (max. 20)">
        </textarea>
        <div class="ty-help-block">
            <i class="ty-icon-help-circle"></i>
            {__("each_criterion_becomes_column", ["example" => "материал, точность, допуски…"])}
        </div>
    </div>

    <div class="ty-control-group">
        <label for="deadline" class="ty-control-group__title">{__("deadline")} <span class="cm-required">*</span></label>
        <select name="deadline" id="deadline" class="ty-input-text" required>
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
        </label>
    </div>

    <div class="buttons-container ty-mt-s">
        {include file="buttons/button.tpl"
        but_text=__("place_order")
        but_role="submit"
        but_meta="ty-btn__primary ty-btn cm-submit"}
    </div>
    </div>
</form>

{literal}
    <script>
        const selectAll = document.getElementById('select_all_vendors');
        const checkboxes = document.querySelectorAll('input[name="rfq_request[vendors][]"]');
        const counter = document.getElementById('vendors_selected_count');

        function updateSelectedCount() {
            const count = [...checkboxes].filter(ch => ch.checked).length;
            counter.innerText = `Выбрано: ${count}`;
        }

        selectAll.addEventListener('click', () => {
            const checked = selectAll.checked;
            checkboxes.forEach(ch => ch.checked = checked);
            updateSelectedCount();
        });

        checkboxes.forEach(ch => ch.addEventListener('change', updateSelectedCount));

        updateSelectedCount();
    </script>
{/literal}

<style>
    #rfq_request_form [id^="rfq_request_"] {
        width: 100%;
    }
</style>