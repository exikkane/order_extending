<script>
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