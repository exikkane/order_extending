<?php

if ($mode == 'send_request') {
    $params = $_REQUEST;

    if ($request_id = fn_order_extending_send_request($params)) {
        fn_set_notification('N', __('notice'), __('order_extending_request_sent_successfully', ['id' => $request_id]));

        return [CONTROLLER_STATUS_REDIRECT, fn_url($params['return_url'])];
    }
}

if ($mode == 'get_vendors_by_category') {
    if (defined('AJAX_REQUEST')) {
        $vendors = fn_order_extending_get_vendors_by_category($_REQUEST['category_id']);

        Tygh::$app['view']->assign('vendors', $vendors);
        Tygh::$app['view']->display('addons/order_extending/components/request_form.tpl');
        exit;
    }
}