{if $auth.user_id}
    {capture name="rfq_request_popup"}
        {include file="addons/order_extending/components/request_form.tpl" section='category'}
    {/capture}

    {include file="common/popupbox.tpl"
    link_text="{__("place_rfq_request")}"
    title="{__("place_rfq_request")}"
    id="rfq_request_popup"
    content=$smarty.capture.rfq_request_popup
    link_meta="ty-btn__primary ty-btn__big ty-btn ty-float-right"
    }
{/if}
