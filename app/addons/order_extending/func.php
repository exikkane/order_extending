<?php

use Tygh\Navigation\LastView;
use Tygh\Storage;

function fn_order_extending_flatten_categories(array $categories, int $level = 0, array &$result = [])
{
    foreach ($categories as $cat) {
        $prefix = str_repeat('--', $level);
        $result[] = [
            'category_id' => $cat['category_id'],
            'category_name' => $prefix . ' ' . $cat['category'],
        ];
        if (!empty($cat['subcategories'])) {
            fn_order_extending_flatten_categories($cat['subcategories'], $level + 1, $result);
        }
    }
    return $result;
}

function fn_order_extending_get_vendors_by_category($category_id)
{
    $category_tree = fn_get_plain_categories_tree($category_id);

    if (empty($category_tree)) {
        return sql_req($category_id);
    }
    $category_tree = array_column($category_tree, 'category_id');
    $category_tree[] = $category_id;

    return sql_req($category_tree);
}

function sql_req($cat_ids) {
    return db_get_hash_array('
    SELECT DISTINCT p.company_id, c.company 
    FROM ?:products p 
    INNER JOIN ?:products_categories pc ON pc.product_id = p.product_id
    LEFT JOIN ?:companies c ON p.company_id = c.company_id
    WHERE pc.category_id IN (?n)',
        'company_id',
        $cat_ids
    );
}

function fn_send_request($params)
{
    $request_params = $params['rfq_request'];

    if (empty($request_params)) {
        return 0;
    }

    $data = [
        'user_id' => $request_params['user_id'],
        'category_id' => $request_params['category'],
        'vendors_ids' => implode(',', $request_params['vendors']),
        'task_description' => trim($request_params['task_description']),
        'comparison_criteria' => trim($request_params['comparison_criteria']),
        'response_deadline_days' => $request_params['deadline'],
    ];

    if (!empty($params['file_rfq_files'])) {
        $attached = fn_filter_uploaded_data('rfq_files');

        foreach ($attached as $file) {
            $_file_path = 'rfq_request_data/' . $data['user_id'] . '/' . $data['category_id'] . '/' . $file['name'];

            Storage::instance('custom_files')->put($_file_path, [
                'file' => $file['path'],
            ]);

            $data['filename'] = $file['name'];
        }
    }

    $request_id = db_replace_into('rfq_requests', $data);
    $user_email = db_get_field('SELECT email FROM ?:users WHERE user_id = ?i', $request_params['user_id']);

    $mailer = Tygh::$app['mailer'];

    foreach (['C', 'A'] as $type) {
        $mailer->send([
            'to' => $user_email,
            'from' => 'default_company_users_department',
            'data' => ['rfq_request_id' => $request_id],
            'template_code' => 'rfq_requests_created',
            'company_id' => 0,
        ], $type, CART_LANGUAGE);
    }
    return $request_id;
}

function fn_delete_requests($request_ids)
{
    $result = false;

    if (!empty($request_ids)) {
        $result = db_query('DELETE FROM ?:rfq_requests WHERE request_id IN (?n)', $request_ids);
    }

    return $result;
}

function fn_order_extending_get_requests($params, $items_per_page) {
    $default_params = [
        'page' => 1,
        'items_per_page' => $items_per_page,
    ];

    $params = array_merge($default_params, $params);
    $condition = '';
    $fields_list = [
        '?:rfq_requests.request_id',
        '?:rfq_requests.user_id',
        '?:rfq_requests.category_id',
        '?:rfq_requests.vendors_ids',
        '?:rfq_requests.task_description',
        '?:rfq_requests.filename',
        '?:rfq_requests.comparison_criteria',
        '?:rfq_requests.response_deadline_days',
        '?:rfq_requests.created_at',
        '?:rfq_requests.status',
    ];

    $sorting = db_sort($params, ['id' => '?:rfq_requests.request_id'], 'id', 'desc');

    if (!empty($params['request_id'])) {
        $condition .= db_quote(' AND ?:rfq_requests.request_id = ?i', $params['request_id']);
    }
    if (!empty($params['user_id'])) {
        $condition .= db_quote(' AND ?:rfq_requests.user_id = ?i', $params['user_id']);
    }
    if (!empty($params['category_id'])) {
        $condition .= db_quote(' AND ?:rfq_requests.category_id = ?i', $params['category_id']);
    }
    if (!empty($params['vendor_id'])) {
        $condition .= db_quote(' AND FIND_IN_SET(?n, vendors_ids)', $params['vendor_id']);
    }
    if (!empty($params['status'])) {
        $condition .= db_quote(' AND ?:rfq_requests.status = ?s', $params['status']);
    }

    $limit = '';
    if (!empty($params['items_per_page'])) {
        $params['total_items'] = db_get_field("SELECT COUNT(DISTINCT(?:rfq_requests.request_id)) FROM ?:rfq_requests WHERE 1 $condition");
        $limit = db_paginate($params['page'], $params['items_per_page'], $params['total_items']);
    }

    $fields_list =  implode(', ', $fields_list);

    $rfq_requests = db_get_array("SELECT $fields_list FROM ?:rfq_requests WHERE 1 $condition $sorting $limit");

    return [$rfq_requests, $params];
}

function fn_get_request_file($request_id)
{
    $data = db_get_row('SELECT user_id, category_id, filename FROM ?:rfq_requests WHERE request_id  = ?i', $request_id);

    if (empty($data)) {
        return false;
    }

    $request_storage = Storage::instance('custom_files');
    $filename = 'rfq_request_data/' . $data['user_id'] . '/' . $data['category_id'] . '/' . $data['filename'];

    if (!$request_storage->isExist($filename)) {
        return false;
    }

    $request_storage->get($filename);
    exit;
}