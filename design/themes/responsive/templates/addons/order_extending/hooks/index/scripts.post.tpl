<script>
    $(function() {
        $('#rfq_request_categories').on('change', function() {
            var categoryId = $(this).val();
            if (!categoryId) {
                $('#vendors_list').empty();
                $('#vendors_selected_count').text('{__("selected")|escape:javascript}: 0');
                return;
            }
            $.ceAjax('request', fn_url('rfq_request.get_vendors_by_category?category_id=' + categoryId), {
                hidden: false,
                result_ids: 'vendors_select_wrapper'
            });
        });

        $('#vendors').on('change', '#select_all_vendors', function() {
            var checked = $(this).is(':checked');
            $('#vendors_select_wrapper input[type="checkbox"][name="rfq_request[vendors][]"]').prop('checked', checked);

            var count = checked ? $('#vendors_select_wrapper input[type="checkbox"][name="rfq_request[vendors][]"]').length : 0;
            $('#vendors_selected_count').text('{__("selected")|escape:javascript}: ' + count);
        });

        $('#vendors').on('change', 'input[type="checkbox"][name="rfq_request[vendors][]"]', function() {
            var total = $('#vendors_select_wrapper input[type="checkbox"][name="rfq_request[vendors][]"]').length;
            var checked = $('#vendors_select_wrapper input[type="checkbox"][name="rfq_request[vendors][]"]:checked').length;

            $('#vendors_selected_count').text('{__("selected")|escape:javascript}: ' + checked);
            $('#select_all_vendors').prop('checked', total === checked && total > 0);
        });
    });

    (function(_, $) {
        $.ceFormValidator('registerValidator', {
            class_name: 'cm-check-comparison-criteria',
            message: '{__("comparison-criteria_alert")|escape:javascript}',
            func: function(id) {
                let value = ($('#' + id).val());
                let items = value
                    .split(',')
                    .map(function(item) {
                        return $.trim(item);
                    })
                    .filter(function(item) {
                        return item.length > 0;
                    });

                return items.length < 20;
            }
        });
    }(Tygh, Tygh.$));
</script>