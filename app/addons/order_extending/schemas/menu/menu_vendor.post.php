<?php

defined('BOOTSTRAP') or die('Access denied');

/** @var array $schema */

$schema['central']['orders']['items']['rfq_requests'] = [
    'attrs'    => [
        'class' => 'is-addon',
    ],
    'href'     => 'rfq_requests.manage',
    'position' => 220,
];

return $schema;
