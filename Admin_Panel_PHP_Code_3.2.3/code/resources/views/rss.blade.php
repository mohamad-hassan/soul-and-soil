@extends('layouts.main')

@section('title')
    {{ __('rss_fees') }}
@endsection

@section('content')
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">{{ __('create_and_manage') . ' ' . __('rss_fees') }}</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item text-dark">
                            <a href="{{ route('home') }}" class="text-dark"><i
                                    class="fas fa-home mr-1"></i>{{ __('dashboard') }}</a>
                        </li>
                        <li class="breadcrumb-item active"><i
                                class="nav-icon fas fa-newspaper mr-1"></i>{{ __('rss_fees') }}
                        </li>
                    </ol>
                </div>
            </div>
        </div>
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                @can('rss-create')
                <div class="col-md-12 d-flex justify-content-end">
                    <button id="toggleButton" class="btn btn-primary mb-3 ml-1"><i
                            class="fas fa-plus-circle mr-2"></i>{{ __('create') . ' ' . __('rss_fees') }}</button>
                </div>
                @endcan
                <div class="col-md-12" id="add_card">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('create') . ' ' . __('rss_fees') }}</h3>
                        </div>
                        <div class="card-body">
                            <form id="create_form" action="{{ url('rss') }}" role="form" method="POST"
                                enctype="multipart/form-data">
                                @csrf
                                <div class="row">
                                    <div class="form-group col-md-4 col-sm-12">
                                        <label class="required">{{ __('language') }}</label>
                                        <select id="language_id" name="language" class="form-control" required>
                                            @if (count($languageList) > 1)
                                                <option value="">{{ __('select') . ' ' . __('language') }}
                                                </option>
                                            @endif
                                            @foreach ($languageList as $row)
                                                <option value="{{ $row->id }}">{{ $row->language }}
                                                </option>
                                            @endforeach
                                        </select>
                                    </div>
                                    @if (is_category_enabled() == 1)
                                        <div class="form-group col-md-4 col-sm-12">
                                            <label class="required">{{ __('category') }}</label>
                                            <select id="category_id" name="category_id" class="form-control" required>
                                                <option value="">{{ __('select') . ' ' . __('category') }}
                                                </option>
                                                @foreach ($categoryList as $row)
                                                    <option value="{{ $row->id }}">{{ $row->category_name }}
                                                    </option>
                                                @endforeach
                                            </select>
                                        </div>
                                        @if (is_subcategory_enabled() == 1)
                                            <div class="form-group col-md-4 col-sm-12">
                                                <label>{{ __('subcategory') }}</label>
                                                <select id="subcategory_id" name="subcategory_id" class="form-control">
                                                    <option value="">{{ __('select') . ' ' . __('subcategory') }}
                                                    </option>
                                                </select>
                                            </div>
                                        @endif
                                    @endif
                                    <div class="form-group col-md-4 col-sm-12">
                                        <label class="required">{{ __('feed_name') }}</label>
                                        <input name="feed_name" required type="text" placeholder="{{ __('feed_name') }}"
                                            class="form-control">
                                    </div>
                                    <div class="form-group col-md-4 col-sm-12">
                                        <label class="required">{{ __('feed_url') }}</label>
                                        <input name="feed_url" required type="url" placeholder="{{ __('feed_url') }}"
                                            class="form-control">
                                    </div>
                                    <div class="form-group col-md-4 col-sm-12">
                                        <label>{{ __('tag') }}</label>
                                        <select id="tag_id" name="tag_id[]" class="form-control select2 select2-multiple"
                                            multiple="multiple">
                                            @foreach ($tagList as $row)
                                                <option value="{{ $row->id }}">{{ $row->tag_name }}
                                                </option>
                                            @endforeach
                                        </select>
                                    </div>
                                </div>
                                <div class="d-flex col-12 justify-content-end p-0">
                                    <button type="submit" class="btn btn-primary">{{ __('submit') }}</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                @can('rss-list')
                <div class="col-md-12">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('rss_fees') . ' ' . __('list') }}</h3>
                        </div>
                        <div class="card-body">
                            <div class="row mb-3">
                                <div class="col-lg-3 col-md-4 col-sm-12">
                                    <label>{{ __('language') }}</label>
                                    <select id="filter_language_id" class="form-control">
                                        <option value="0">{{ __('select') . ' ' . __('language') }}</option>
                                        @foreach ($languageList as $row)
                                            <option value="{{ $row->id }}">{{ $row->language }}</option>
                                        @endforeach
                                    </select>
                                </div>
                                @if (is_category_enabled() == 1)
                                    <div class="col-lg-3 col-md-4 col-sm-12">
                                        <label>{{ __('category') }}</label>
                                        <select id="filter_category_id" class="form-control">
                                            <option value="0">{{ __('select') . ' ' . __('category') }}</option>
                                        </select>
                                    </div>
                                    @if (is_subcategory_enabled() == 1)
                                        <div class="col-lg-3 col-md-4 col-sm-12">
                                            <label>{{ __('subcategory') }}</label>
                                            <select id="filter_subcategory_id" class="form-control">
                                                <option value="0">{{ __('select') . ' ' . __('subcategory') }}
                                                </option>
                                            </select>
                                        </div>
                                    @endif
                                @endif
                            </div>
                            @can('rss-bulk-delete')
                            <div id="toolbar">
                                <button class="btn bg-primary text-white" type="submit"
                                    id="bulk_delete">{{ __('bulk_delete') }}</button>
                            </div>
                            @endcan
                            <table aria-describedby="mydesc" id='table' data-toggle="table"
                                data-url="{{ route('rssList') }}" data-click-to-select="true"
                                data-side-pagination="server" data-pagination="true"
                                data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-unique-id="id"
                                data-show-columns="true" data-show-refresh="true" data-toolbar="#toolbar"
                                data-mobile-responsive="true" data-buttons-class="primary" data-trim-on-search="false"
                                data-sort-name="id" data-sort-order="desc" data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th class="text-center multi-check" data-checkbox="true">
                                        <th scope="col" data-field="id" data-sortable="true">{{ __('id') }}</th>
                                        <th scope="col" data-field="language_id" data-sortable="true"
                                            data-visible="false">{{ __('language_id') }}</th>
                                        <th scope="col" data-field="language_name">{{ __('language') }} </th>
                                        @if (is_category_enabled() == 1)
                                            <th scope="col" data-field="category_id" data-sortable="true"
                                                data-visible="false">{{ __('category_id') }}</th>
                                            <th scope="col" data-field="category_name">{{ __('category') }}</th>
                                        @endif
                                        @if (is_subcategory_enabled() == 1)
                                            <th scope="col" data-field="subcategory_id" data-visible="false">
                                                {{ __('subcategory_id') }}</th>
                                            <th scope="col" data-field="subcategory_name" data-visible="false">
                                                {{ __('subcategory') }}</th>
                                        @endif
                                        <th scope="col" data-field="feed_name" data-sortable="true">{{ __('feed_name') }}</th>
                                        <th scope="col" data-field="feed_url">{{ __('feed_url') }}</th>
                                        <th scope="col" data-field="status_badge">{{ __('status') }}</th>
                                        <th scope="col" data-field="tag_id" data-visible="false">{{ __('tag_id') }}</th>
                                        <th scope="col" data-field="tag_name" data-visible="false">{{ __('tags') }}</th>
                                        <th scope="col" data-field="created_at" data-visible="false">{{ __('created_at') }}</th>
                                        @canany(['rss-edit', 'rss-delete'])
                                        <th scope="col" data-field="operate" data-events="actionEvents">{{ __('operate') }}</th>
                                        @endcanany
                                    </tr>
                                </thead>
                            </table>
                        </div>
                    </div>
                </div>
                @endcan
            </div>
        </div>
        <div class="modal fade" id="editDataModal">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">{{ __('edit') . ' ' . __('rss_fees') }}</h4>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <form id="update_form" action="{{ url('rss') }}" role="form" method="POST"
                        enctype="multipart/form-data">
                        @csrf
                        <input type='hidden' name="edit_id" id="edit_id" value='' />
                        <div class="modal-body">
                            <div class="row">
                                <div class="form-group col-md-4 col-sm-12">
                                    <label class="required">{{ __('language') }}</label>
                                    <select id="edit_language_id" name="language" class="form-control" required>
                                        <option value="">{{ __('select') . ' ' . __('language') }}</option>
                                        @foreach ($languageList as $row)
                                            <option value="{{ $row->id }}">{{ $row->language }}</option>
                                        @endforeach
                                    </select>
                                </div>
                                @if (is_category_enabled() == 1)
                                    <div class="form-group col-md-4 col-sm-12">
                                        <label class="required">{{ __('category') }}</label>
                                        <select id="edit_category_id" name="category_id" class="form-control" required>
                                            <option value="">{{ __('select') . ' ' . __('category') }}</option>
                                        </select>
                                    </div>
                                    @if (is_subcategory_enabled() == 1)
                                        <div class="form-group col-md-4 col-sm-12">
                                            <label>{{ __('subcategory') }}</label>
                                            <select id="edit_subcategory_id" name="subcategory_id" class="form-control">
                                                <option value="">{{ __('select') . ' ' . __('subcategory') }}
                                                </option>
                                            </select>
                                        </div>
                                    @endif
                                @endif
                                <div class="form-group col-md-4 col-sm-12">
                                    <label class="required">{{ __('feed_name') }}</label>
                                    <input id="edit_feed_name" name="feed_name" type="text" class="form-control"
                                        required>
                                </div>
                                <div class="form-group col-md-4 col-sm-12">
                                    <label class="required">{{ __('feed_url') }}</label>
                                    <input id="edit_feed_url" name="feed_url" type="text" class="form-control"
                                        placeholder="{{ __('feed_url') }}" required>
                                </div>
                                <div class="form-group col-md-4 col-sm-12">
                                    <label>{{ __('tag') }}</label>
                                    <select id="edit_tag_id" name="tag_id[]"
                                        class="form-control select2 select2-multiple" multiple="multiple">
                                    </select>
                                </div>
                                <div class="form-group col-md-4 col-sm-12">
                                    <label>{{ __('status') }}</label><br>
                                    <div id="status1" class="btn-group">
                                        <label class="btn btn-success" data-toggle-class="btn-primary"
                                            data-toggle-passive-class="btn-default">
                                            <input type="radio" name="status" value="1"
                                                checked>{{ __('active') }}
                                        </label>
                                        <label class="btn btn-danger" data-toggle-class="btn-primary"
                                            data-toggle-passive-class="btn-default">
                                            <input type="radio" name="status" value="0">{{ __('deactive') }}
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default"
                                data-dismiss="modal">{{ __('close') }}</button>
                            <button type="submit" class="btn btn-primary">{{ __('submit') }}</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </section>
@endsection

@section('script')
    <script type="text/javascript">
        window.actionEvents = {
            'click .edit-data': function(e, value, row, index) {
                $('#edit_id').val(row.id);
                $('#edit_slug').val(row.slug);
                $("#edit_feed_name").val(row.feed_name);
                $("#edit_feed_url").val(row.feed_url);
                if (row.status == '0') {
                    $("input[name=status][value=0]").prop('checked', true);
                } else {
                    $("input[name=status][value=1]").prop('checked', true);
                }

                $("#edit_language_id").val(row.language_id).trigger('change', [row.language_id, row.category_id, row
                    .subcategory_id, row.tag_id
                ]);
            }
        };

        function queryParams(p) {
            return {
                sort: p.sort,
                order: p.order,
                limit: p.limit,
                offset: p.offset,
                search: p.search,
                language_id: $('#filter_language_id').val(),
                category_id: $('#filter_category_id').val(),
                subcategory_id: $('#filter_subcategory_id').val(),
                location_id: $('#filter_location_id').val(),
                user_id: $('#filter_user_id').val(),
                status: $('#filter_status').val(),
            };
        }
    </script>

    <script type="text/javascript">
        $(document).on('change', '#language_id', function(e) {
            var data = {
                language_id: $('#language_id').val(),
            };
            var url = '{{ route('get_category_by_language') }}';
            fetchList(url, data, '#category_id');

            var url1 = '{{ route('get_tag_by_language') }}';
            fetchList(url1, data, '#tag_id');
        });

        $(document).on('change', '#category_id', function(e) {
            var data = {
                category_id: $('#category_id').val(),
            };
            var url = '{{ route('get_subcategory_by_category') }}';
            fetchList(url, data, '#subcategory_id');
        });

        $(document).on('change', '#edit_language_id', function(e, row_language_id, row_category_id, row_subcategory_id,
            row_tag_id) {
            var language_id = $('#edit_language_id').val();
            $.ajax({
                url: '{{ route('get_category_by_language') }}',
                type: "POST",
                data: {
                    language_id: language_id,
                },
                beforeSend: function() {
                    $('#edit_category_id').html("Please wait..");
                },
                success: function(result) {
                    $('#edit_category_id').html(result);
                    if (language_id == row_language_id && row_category_id != 0) {
                        $('#edit_category_id').val(row_category_id).trigger('change', [row_category_id,
                            row_subcategory_id
                        ]);
                    }
                },
                error: function(errors) {
                    console.log(errors);
                },
            });

            $.ajax({
                url: '{{ route('get_tag_by_language') }}',
                type: "POST",
                data: {
                    language_id: language_id,
                },
                beforeSend: function() {
                    $('#edit_tag_id').html("Please wait..");
                },
                success: function(result) {
                    $('#edit_tag_id').html(result).trigger("change");
                    if (language_id == row_language_id && row_tag_id != '') {
                        var valueArray = row_tag_id;
                        var arrayArea = valueArray.split(',');
                        $("#edit_tag_id").val(arrayArea).trigger("change");
                    }
                },
                error: function(errors) {
                    console.log(errors);
                },
            });
        });

        $(document).on('change', '#edit_category_id', function(e, row_category_id, row_subcategory_id) {
            var category_id = $('#edit_category_id').val();
            $.ajax({
                url: '{{ route('get_subcategory_by_category') }}',
                type: "POST",
                data: {
                    category_id: category_id,
                },
                beforeSend: function() {
                    $('#edit_subcategory_id').html("Please wait..");
                },
                success: function(result) {
                    $('#edit_subcategory_id').html(result);
                    if (category_id == row_category_id && row_subcategory_id != 0) {
                        $('#edit_subcategory_id').val(row_subcategory_id);
                    }
                },
                error: function(errors) {
                    console.log(errors);
                },
            });
        });
    </script>

    <script type="text/javascript">
        $(document).on('change', '#filter_language_id', function() {
            $('#table').bootstrapTable('refresh');
            var data = {
                language_id: $('#filter_language_id').val(),
            };
            var url = '{{ route('get_category_by_language') }}';
            fetchList(url, data, '#filter_category_id');
        });
        $(document).on('change', '#filter_category_id', function() {
            $('#table').bootstrapTable('refresh');
            var data = {
                category_id: $('#filter_category_id').val(),
            };
            var url = '{{ route('get_subcategory_by_category') }}';
            fetchList(url, data, '#filter_subcategory_id');
        });
        $(document).on('change', '#filter_subcategory_id', function() {
            $('#table').bootstrapTable('refresh');
        });
    </script>

    <script type="text/javascript">
        $('#bulk_delete').click(function() {
            var request_ids = [];
            selected = $('#table').bootstrapTable('getSelections');
            var arr = Object.values(selected);
            var i;
            var final_selection = [];
            var request_ids = arr.map(({
                id
            }) => id);
            if (request_ids.length) {
                Swal.fire({
                    title: '{{ __('are_you_sure') }}',
                    text: 'You won\'t be able to revert this!',
                    icon: 'error',
                    showCancelButton: true,
                    confirmButtonText: 'Yes, proceed'
                }).then((result) => {
                    if (result.value) {
                        $.ajaxSetup({
                            headers: {
                                'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                            }
                        });
                        $.ajax({
                            type: 'POST',
                            url: '{{ url('bulk_rss_delete') }}',
                            data: {
                                request_ids: request_ids
                            },
                            success: function(response) {
                                if (response.error == false) {
                                    showSuccessToast(response.message);
                                    $('#table').bootstrapTable('refresh');
                                } else {
                                    showErrorToast(response.message);
                                }
                            },
                            error: function(response) {
                                return showToastMessage(response.message, "error");
                            }
                        });
                    }
                });
            } else {
                var message = '{{ __('select_data_to_delete') }}';
                showErrorToast(message);
            }
        });

        function dateFormate(value, row) {
            if (value && value !== '0000-00-00') {
                var date = new Date(value);
                var yy = date.getFullYear();
                var mm = date.getMonth() + 1; // getMonth() is zero-based
                var dd = date.getDate();
                return dd.toString().padStart(2, '0') + '-' + mm.toString().padStart(2, '0') + '-' + yy;
            }
            return '00-00-0000';
        }
    </script>
@endsection
