<?php

namespace Tygh\Enum\Addons\OrderExtending;

class RequestStatuses
{
    const NOT_PROCESSED = 'N';
    const PROCESSED = 'P';
    const IN_PROGRESS = 'I';
    const COMPLETED = 'C';

    public static function getAll(): array
    {
        return [
            self::NOT_PROCESSED => __('rfq_statuses.not_processed'),
            self::PROCESSED     => __('rfq_statuses.processed'),
            self::IN_PROGRESS   => __('rfq_statuses.in_progress'),
            self::COMPLETED     => __('rfq_statuses.completed'),
        ];
    }
}
