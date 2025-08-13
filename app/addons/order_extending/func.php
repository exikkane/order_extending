<?php

use Tygh\Storage;

/**
 * Собирает массив дерева категорий разделяя каждую подкатегорию с помощью строки
 *
 * @param array $categories
 * @param int $level
 * @param array $result
 * @return array
 */
function fn_order_extending_flatten_categories(array $categories, int $level = 0, array &$result = []): array
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

/**
 * Получаем всех продавцов в переданной категории и ее подкатегориях если такие имеются
 *
 * @param int $category_id
 * @return array
 */
function fn_order_extending_get_vendors_by_category(int $category_id): array
{
    $category_tree = fn_get_plain_categories_tree($category_id);

    $category_tree = array_column($category_tree, 'category_id');
    $category_tree[] = $category_id;

    return db_get_hash_array('
    SELECT DISTINCT p.company_id, c.company 
    FROM ?:products p 
    INNER JOIN ?:products_categories pc ON pc.product_id = p.product_id
    LEFT JOIN ?:companies c ON p.company_id = c.company_id
    WHERE pc.category_id IN (?n)',
        'company_id',
        array_unique($category_tree)
    );
}

/**
 * Обрабатывает загруженные файлы запроса
 *
 * @param int $request_id
 * @param array $params
 * @return void
 */
function fn_order_extending_process_request_files(int $request_id, array $params)
{
    if (empty($params['section'])) {
        return;
    }

    $upload_var_name = 'rfq_files_' . $params['section'];
    $attached = fn_filter_uploaded_data($upload_var_name);

    foreach ($attached as $file) {
        $_file_path = fn_order_extending_get_file_path($request_id, $file['name']);

        Storage::instance('custom_files')->put($_file_path, [
            'file' => $file['path'],
        ]);

        db_replace_into('rfq_requests_files', [
            'request_id' => $request_id,
            'filename' => $file['name'],
        ]);
    }
}

/**
 * Отправляет почтовое уведомление для администратора и покупателя
 *
 * @param int $request_id
 * @param int $user_id
 * @return bool
 */
function fn_order_extending_send_notification(int $request_id, int $user_id): bool
{
    $user_email = db_get_field('SELECT email FROM ?:users WHERE user_id = ?i', $user_id);

    if (empty($user_email)) {
        return false;
    }

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

    return true;
}

/**
 * Создает запрос на основе переданных параметров
 *
 * @param array $params
 * @return int
 */
function fn_order_extending_send_request(array $params): int
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

    $request_id = db_replace_into('rfq_requests', $data);

    fn_order_extending_process_request_files($request_id, $params);
    fn_order_extending_send_notification($request_id, $request_params['user_id']);

    return $request_id;
}

/**
 * Удаляет запрос
 *
 * @param $request_ids
 * @return bool
 */
function fn_order_extending_delete_requests($request_ids): bool
{
    $result = false;

    if (!empty($request_ids)) {
        $result = db_query('DELETE FROM ?:rfq_requests WHERE request_id IN (?n)', $request_ids);
        $stored_files = db_get_array('SELECT request_id, filename FROM ?:rfq_requests_files WHERE request_id IN (?n)', $request_ids);

        foreach ($stored_files as $file) {
            $_file_path = fn_order_extending_get_file_path($file['request_id'], $file['filename']);

            Storage::instance('custom_files')->delete($_file_path);
        }

        db_query('DELETE FROM ?:rfq_requests_files WHERE request_id IN (?n)', $request_ids);
    }

    return $result;
}

/**
 * Извлекает запросы из базы данных на основе переданных параметров
 *
 * @param array $params
 * @param int $items_per_page
 * @return array
 */
function fn_order_extending_get_requests(array $params, int $items_per_page = 10): array
{
    $default_params = [
        'page' => 1,
        'items_per_page' => $items_per_page,
    ];

    $params = array_merge($default_params, $params);
    $condition = '';
    $fields_list = [
        'r.request_id',
        'r.user_id',
        'r.category_id',
        'r.vendors_ids',
        'r.task_description',
        'GROUP_CONCAT(rf.filename) AS filenames',
        'r.comparison_criteria',
        'r.response_deadline_days',
        'r.created_at',
        'r.status',
    ];

    $sorting = db_sort($params, ['id' => 'r.request_id'], 'id', 'desc');

    if (!empty($params['request_id'])) {
        $condition .= db_quote(' AND r.request_id = ?i', $params['request_id']);
    }
    if (!empty($params['user_id'])) {
        $condition .= db_quote(' AND r.user_id = ?i', $params['user_id']);
    }
    if (!empty($params['category_id'])) {
        $condition .= db_quote(' AND r.category_id = ?i', $params['category_id']);
    }
    if (!empty($params['vendor_id'])) {
        $condition .= db_quote(' AND FIND_IN_SET(?i, vendors_ids)', $params['vendor_id']);
    }
    if (!empty($params['status'])) {
        $condition .= db_quote(' AND r.status = ?s', $params['status']);
    }

    $limit = '';
    if (!empty($params['items_per_page'])) {
        $params['total_items'] = db_get_field("SELECT COUNT(DISTINCT(r.request_id)) FROM ?:rfq_requests r WHERE 1 $condition");
        $limit = db_paginate($params['page'], $params['items_per_page'], $params['total_items']);
    }

    $fields_list = implode(', ', $fields_list);

    $rfq_requests = db_get_array("
    SELECT $fields_list FROM ?:rfq_requests r
    LEFT JOIN ?:rfq_requests_files rf ON rf.request_id = r.request_id
    WHERE 1=1
        $condition
    GROUP BY r.request_id
        $sorting
        $limit
    ");

    return [$rfq_requests, $params];
}

/**
 * Извлекает файл с сервера
 *
 * @param int $request_id
 * @param string $filename
 * @return false|void
 */
function fn_order_extending_get_request_file(int $request_id, string $filename)
{
    $data = db_get_row('SELECT request_id, filename FROM ?:rfq_requests_files WHERE request_id = ?i AND filename = ?s', $request_id, $filename);

    if (empty($data)) {
        return false;
    }

    $request_storage = Storage::instance('custom_files');
    $filename = fn_order_extending_get_file_path($request_id, $filename);

    if (!$request_storage->isExist($filename)) {
        return false;
    }

    $request_storage->get($filename);
    exit;
}

/**
 * Получаем имена продавцов на основе переданных ID
 *
 * @param string $vendors_ids
 * @return array
 */
function fn_order_extending_get_vendors_name_by_ids(string $vendors_ids): array
{
    $ids = array_map('intval', array_map('trim', explode(',', $vendors_ids)));
    if (empty($ids)) return [];

    $companies = db_get_hash_array(
        'SELECT company_id, company FROM ?:companies WHERE company_id IN (?n)',
        'company_id',
        $ids
    );

    return array_values(array_column($companies, 'company'));
}

/**
 * Получаем имя файла
 *
 * @param int $request_id
 * @param string $filename
 * @return string
 */
function fn_order_extending_get_file_path(int $request_id, string $filename): string
{
    return "rfq_request_data/{$request_id}/{$filename}";
}
