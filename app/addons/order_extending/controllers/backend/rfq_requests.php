<?php

use Tygh\Enum\Addons\OrderExtending\RequestStatuses;
use Tygh\Registry;

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if ($mode == 'update_status') {
        $params = [
            'status'     => (string) $_REQUEST['rfq_request']['status'],
            'request_id' => $_REQUEST['rfq_request']['request_id'],
        ];
        fn_tools_update_status([
            'table'             => 'rfq_requests',
            'status'            => $params['status'],
            'id_name'           => 'request_id',
            'id'                => $params['request_id'],
            'show_error_notice' => false
        ]);

        return [CONTROLLER_STATUS_OK, 'rfq_requests.details?request_id=' . $params['request_id']];
    }
    if (
        $mode === 'm_update_statuses'
        && !empty($_REQUEST['rfq_request_ids'])
        && is_array($_REQUEST['rfq_request_ids'])
        && !empty($_REQUEST['status'])
    ) {
        $status_to = (string) $_REQUEST['status'];

        foreach ($_REQUEST['rfq_request_ids'] as $rfq_request_id) {
            fn_tools_update_status([
                'table'             => 'rfq_requests',
                'status'            => $status_to,
                'id_name'           => 'request_id',
                'id'                => $rfq_request_id,
                'show_error_notice' => false
            ]);
        }

        if (defined('AJAX_REQUEST')) {
            $redirect_url = fn_url('rfq_requests.manage');
            if (isset($_REQUEST['redirect_url'])) {
                $redirect_url = $_REQUEST['redirect_url'];
            }
            Tygh::$app['ajax']->assign('force_redirection', $redirect_url);
            Tygh::$app['ajax']->assign('non_ajax_notifications', true);
            return [CONTROLLER_STATUS_NO_CONTENT];
        }
    }

    if ($mode == 'delete' && !empty($_REQUEST['rfq_request_ids']) && is_array($_REQUEST['rfq_request_ids'])) {
        $rqf_request_ids = implode(',', $_REQUEST['rfq_request_ids']);

        fn_order_extending_delete_requests($rqf_request_ids);

        return [CONTROLLER_STATUS_OK, 'rfq_request_ids.manage'];
    }
}

$params = $_REQUEST;

if ($mode == 'details') {
    if (empty($params['request_id'])) {
        return array(CONTROLLER_STATUS_NO_PAGE);
    }

    [$rfq_requests, $search] = fn_order_extending_get_requests($params, Registry::get('settings.Appearance.admin_elements_per_page'));

    if (!empty($rfq_requests)) {
        $rfq_request = array_pop($rfq_requests);
    } else {
        $rfq_request = [];
    }

    $request_vendors = fn_order_extending_get_vendors_name_by_ids($rfq_request['vendors_ids']);

    Tygh::$app['view']->assign('rfq_request', $rfq_request);
    Tygh::$app['view']->assign('request_vendors', $request_vendors);
}

if ($mode == 'manage') {
    [$rfq_requests, $search] = fn_order_extending_get_requests($params, Registry::get('settings.Appearance.admin_elements_per_page'));

    Tygh::$app['view']->assign('rfq_requests', $rfq_requests);
    Tygh::$app['view']->assign('search', $search);
}

Tygh::$app['view']->assign('request_statuses', RequestStatuses::getAll());

if ($mode == 'getfile') {
    if (!empty($_REQUEST['request_id'])) {
        fn_order_extending_get_request_file($_REQUEST['request_id'], $_REQUEST['filename']);
    }
    exit;
}
