<!-- jQuery -->
<script src="{{ url('assets/plugins/jquery/jquery.min.js') }}"></script>
<!-- jQuery UI 1.11.4 -->
<script src="{{ url('assets/plugins/jquery-ui/jquery-ui.min.js') }}"></script>
<!-- Resolve conflict in jQuery UI tooltip with Bootstrap tooltip -->
<script type="text/javascript">
    $.widget.bridge('uibutton', $.ui.button)
</script>
<!-- Bootstrap 4 -->
<script src="{{ url('assets/plugins/bootstrap/js/bootstrap.bundle.min.js') }}"></script>

<script src="{{ url('assets/plugins/bootstrap-switch/js/bootstrap-switch.js') }}"></script>
<script src="{{ url('assets/plugins/bootstrap-switch/js/bootstrap-switch.min.js') }}"></script>


<script src="{{ url('assets/plugins/moment/moment.min.js') }}"></script>
<!-- overlayScrollbars -->
<script src="{{ url('assets/plugins/overlayScrollbars/js/jquery.overlayScrollbars.min.js') }}"></script>
<!-- AdminLTE App -->
<script src="{{ url('assets/dist/js/adminlte.js') }}"></script>
<!-- AdminLTE for demo purposes -->
<script src="{{ url('assets/dist/js/demo.js') }}"></script>
<!-- AdminLTE dashboard demo (This is only for demo purposes) -->

<script src="{{ url('assets/custom/js/sweetalert2.all.min.js') }}"></script>
<!-- Select2 -->
<script src="{{ url('assets/plugins/select2/js/select2.min.js') }}"></script>

<script src="{{ url('assets/plugins/ekko-lightbox/ekko-lightbox.min.js') }}"></script>

<script src="{{ url('assets/plugins/bootstrap-table/dist/bootstrap-table.min.js') }}"></script>
<script src="{{ url('assets/plugins/bootstrap-table/extensions/fixed-columns/bootstrap-table-fixed-columns.min.js') }}"></script>
<script src="{{ url('assets/plugins/bootstrap-table/extensions/mobile/bootstrap-table-mobile.min.js') }}"></script>
<script src="{{ url('assets/plugins/bootstrap-table/extensions/resizable/bootstrap-table-resizable.min.js') }}"></script>

<!-- start :: include FilePond library -->
<script src="{{ url('assets/plugins/filepond/js/filepond.min.js') }}"></script>
<script src="{{ url('assets/plugins/filepond/js/filepond-plugin-image-preview.min.js') }}"></script>
<script src="{{ url('assets/plugins/filepond/js/filepond-plugin-image-validate-size.min.js') }}"></script>
<script src="{{ url('assets/plugins/filepond/js/filepond-plugin-media-preview.min.js') }}"></script>
<script src="{{ url('assets/plugins/filepond/js/filepond-plugin-file-validate-size.min.js') }}"></script>
<script src="{{ url('assets/plugins/filepond/js/filepond-plugin-file-validate-type.min.js') }}"></script>
<script src="{{ url('assets/plugins/filepond/js/filepond-plugin-pdf-preview.min.js') }}"></script>
<script src="{{ url('assets/plugins/filepond/js/filepond.jquery.js') }}"></script>
<!-- end :: include FilePond library -->

<!-- Ekko Lightbox -->
<script src="{{ url('assets/plugins/ekko-lightbox/ekko-lightbox.min.js') }}"></script>

<script src="{{ url('assets/custom/js/switchery.min.js') }}"></script>
<script src="{{ url('assets/plugins/tagify/tagify.min.js') }}"></script>

<script src="{{ url('assets/plugins/tinymce/tinymce.min.js') }}"></script>

<script src="{{ url('assets/plugins/jquery-validation/jquery.validate.min.js') }}"></script>
<script src="{{ url('assets/plugins/jquery-validation/additional-methods.min.js') }}"></script>

<script src="{{ url('assets/custom/js/custom.js') }}"></script>

<script type="text/javascript">
    var baseUrl = "{{ URL::to('/') }}";
</script>

<script type="text/javascript">
    $(function() {
        $(document).on('click', '[data-toggle="lightbox"]', function(event) {
            event.preventDefault();
            $(this).ekkoLightbox({
                alwaysShowClose: true
            });
        });
        if (document.getElementById("meta_tags") != null) {
            var input = document.querySelector('input[id=meta_tags]');
            new Tagify(input);
        }

        if (document.getElementById("edit_meta_tags") != null) {
            var input1 = document.querySelector('input[id=edit_meta_tags]');
            new Tagify(input1);
        }
    });


    $('#create_form').validate({
        rules: {},
        errorElement: 'span',
        errorPlacement: function(error, element) {
            error.addClass('invalid-feedback');
            element.closest('.form-group').append(error);
        },
        highlight: function(element, errorClass, validClass) {
            $(element).addClass('is-invalid');
        },
        unhighlight: function(element, errorClass, validClass) {
            $(element).removeClass('is-invalid');
        }
    });

    $('#update_form').validate({
        rules: {},
        errorElement: 'span',
        errorPlacement: function(error, element) {
            error.addClass('invalid-feedback');
            element.closest('.form-group').append(error);
        },
        highlight: function(element, errorClass, validClass) {
            $(element).addClass('is-invalid');
        },
        unhighlight: function(element, errorClass, validClass) {
            $(element).removeClass('is-invalid');
        }
    });
</script>
@if (Session::has('error'))
    <script type='text/javascript'>
        showErrorToast('{{ Session::get('error') }}');
    </script>
@endif
@if (Session::has('success'))
    <script type='text/javascript'>
        showSuccessToast('{{ Session::get('success') }}');
    </script>
@endif
