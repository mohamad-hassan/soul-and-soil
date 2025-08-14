@extends('layouts.main')

@section('title')
    {{ __('category') }}
@endsection

@section('content')
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">{{ __('create_and_manage') . ' ' . __('category') }}</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item text-dark">
                            <a href="{{ route('home') }}" class="text-dark"><i
                                    class="fas fa-home mr-1"></i>{{ __('dashboard') }}</a>
                        </li>
                        <li class="breadcrumb-item active"><i class="nav-icon fas fa-cube mr-1"></i>{{ __('category') }}
                        </li>
                    </ol>
                </div>
            </div>
        </div>
    </section>

    <section class="content">
        <div class="container-fluid">
            <div class="row">
                @can('category-create')
                <div class="col-md-12 d-flex justify-content-end">
                    <button id="toggleButton" class="btn btn-primary mb-3 ml-1"><i
                            class="fas fa-plus-circle mr-2"></i>{{ __('create') . ' ' . __('category') }}</button>
                </div>
                @endcan
                <div class="col-md-12" id="add_card">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('create') . ' ' . __('category') }}</h3>
                        </div>
                        <form id="create_form" action="{{ route('category.store') }}" role="form" method="POST"
                            enctype="multipart/form-data">
                            @csrf
                            <div class="card-body">
                                <div class="row">
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="required">{{ __('language') }}</label>
                                        <select id="language_id" name="language" class="form-control" required>
                                            @if (count($languageList) > 1)
                                                <option value="">{{ __('select') . ' ' . __('language') }}</option>
                                            @endif
                                            @foreach ($languageList as $item)
                                                <option value="{{ $item->id }}">{{ $item->language }}</option>
                                            @endforeach
                                        </select>
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="required">{{ __('name') }}</label>
                                        <input id="name" name="name" required placeholder="{{ __('name') }}"
                                            type="text" class="form-control">
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="required">{{ __('slug') }}</label>
                                        <input type="text" id="slug" name="slug" class="form-control"
                                            placeholder="{{ __('slug') }}" required>
                                        <span class="text-danger">{{ __('avoid_special_characters') }}</span>
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="mr-2">{{ __('schema_markup') }}</label>
                                        <i data-content="Schema markup, also known as structured data, is the language search engines use to read and understand the content
                                            on your pages. By language, we mean a semantic vocabulary (code) that helps search engines characterize and categorize the content of web pages.
                                            Learn more about schema markup and generate it for your website using the .<a href='https://www.rankranger.com/schema-markup-generator' target='_blank'>Rank Ranger Schema Markup Generator</a>".
                                            class="fa fa-question-circle"></i>
                                        <input type="text" name="schema_markup" class="form-control"
                                            placeholder="{{ __('schema_markup') }}">
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label>{{ __('meta_keywords') }}</label>
                                        <input id="meta_tags" name="meta_keyword" class="w-100" type="text"
                                            placeholder="{{ __('press_enter_add_keywords') }}">
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label>{{ __('meta_title') }}</label>
                                        <input id="meta_title" type="text" name="meta_title" class="form-control"
                                            placeholder="{{ __('meta_title') }}"
                                            oninput="getWordCount('meta_title','meta_title_count','19.9px arial')">
                                        <h6 id="meta_title_count">0</h6>
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label>{{ __('meta_description') }}</label>
                                        <textarea id="meta_description" name="meta_description" class="form-control"
                                            oninput="getWordCount('meta_description','meta_description_count','12.9px arial')"></textarea>
                                        <h6 id="meta_description_count">0</h6>
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="required">{{ __('image') }} </label>
                                        <input name="file" type="file" class="filepond" required>
                                    </div>
                                </div>
                                <button type="submit" class="btn btn-primary float-right">{{ __('submit') }}</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <div class="row">
                @can('category-list')
                <div class="col-lg-8 col-md-12 col-sm-12">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('category') . ' ' . __('list') }}</h3>
                        </div>
                        <div class="card-body">
                            <div id="toolbar">
                                <select id="filter_language_id" name="language" class="form-control">
                                    <option value="0">{{ __('select') . ' ' . __('language') }}</option>
                                    @foreach ($languageList as $item)
                                        <option value="{{ $item->id }}">{{ $item->language }}</option>
                                    @endforeach
                                </select>
                            </div>
                            <table aria-describedby="mydesc" id='table' data-toggle="table"
                                data-url="{{ route('categoryList') }}" data-click-to-select="true"
                                data-side-pagination="server" data-pagination="true"
                                data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true"
                                data-show-refresh="true" data-toolbar="#toolbar" data-mobile-responsive="true"
                                data-buttons-class="primary" data-trim-on-search="false" data-sort-name="row_order"
                                data-sort-order="asc" data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th scope="col" data-field="id" data-sortable="true">{{ __('id') }}</th>
                                        <th scope="col" data-field="language_name">{{ __('language') }}</th>
                                        <th scope="col" data-field="image">{{ __('image') }}</th>
                                        <th scope="col" data-field="category_name">{{ __('name') }}</th>
                                        <th scope="col" data-field="slug" data-sortable="false">{{ __('slug') }}
                                        </th>
                                        <th scope="col" data-field="row_order">{{ __('row_order') }}</th>
                                        <th scope="col" data-field="meta_keyword" data-visible="false">
                                            {{ __('meta_keywords') }}</th>
                                        <th scope="col" data-field="meta_title" data-visible="false">
                                            {{ __('meta_title') }}</th>
                                        <th scope="col" data-field="schema_markup" data-visible="false">
                                            {{ __('schema_markup') }}</th>
                                        <th scope="col" data-field="description" data-visible="false">
                                            {{ __('meta_description') }}</th>
                                        @canany(['category-edit', 'category-delete'])
                                        <th scope="col" data-field="operate" data-events="actionEvents">
                                            {{ __('operate') }}</th>
                                        @endcanany
                                    </tr>
                                </thead>
                            </table>
                        </div>
                    </div>
                </div>
                @endcan
                @can('category-order-create')
                <div class="col-lg-4 col-md-12 col-sm-12">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('category') . ' ' . __('order') }}</h3>
                        </div>
                        <div class="card-body">
                            <form id="order_form" action="{{ route('update_category_order') }}" method="post"
                                onsubmit="return saveOrder()">
                                @csrf
                                <div class="form-group col-md-12 col-sm-12">
                                    <select id="order_language_id" class="form-control">
                                        <option value="0">{{ __('select') . ' ' . __('language') }}</option>
                                        @foreach ($languageList as $item)
                                            <option value="{{ $item->id }}">{{ $item->language }}</option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="col-md-12 col-sm-12">
                                    <input id="row_order" name="row_order" type="hidden">
                                    <ol id="sortable-row">
                                        @foreach ($categoryList as $row)
                                            <li id="{{ $row->id }}">{{ $row->category_name }}</li>
                                        @endforeach
                                    </ol>
                                </div>
                                <button id="order_btn" type="submit" {{ count($categoryList) == 0 ? 'disabled' : '' }}
                                    class="btn btn-primary float-right">{{ __('submit') }}</button>
                            </form>
                        </div>
                    </div>
                </div>
                @endcan
            </div>
        </div>
        <div class="modal fade" id="editDataModal">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">{{ __('edit') . ' ' . __('category') }}</h4>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <form id="update_form" action="{{ url('category') }}" role="form" method="POST"
                        enctype="multipart/form-data">
                        @csrf
                        <input type='hidden' name="edit_id" id="edit_id" value='' />
                        <input type='hidden' name="image_url" id="image_url" value='' />
                        <div class="modal-body">
                            <div class="row">
                                <div class="form-group col-md-6 col-sm-12">
                                    <label class="required">{{ __('language') }}</label>
                                    <select id="edit_language_id" name="language" class="form-control" required>
                                        <option value="">{{ __('select') . ' ' . __('language') }}</option>
                                        @foreach ($languageList as $item)
                                            <option value="{{ $item->id }}">{{ $item->language }}</option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label class="required">{{ __('name') }}</label>
                                    <input id="edit_name" name="name" required placeholder="{{ __('name') }}"
                                        type="text" class="form-control">
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label class="required">{{ __('slug') }}</label>
                                    <input type="text" name="slug" id="edit_slug" class="form-control"
                                        placeholder="{{ __('slug') }}" required>
                                    <span class="text-danger">{{ __('avoid_special_characters') }}</span>
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label>{{ __('meta_title') }}</label>
                                    <input id="edit_meta_title" name="meta_title" type="text" class="form-control"
                                        oninput="getWordCount('edit_meta_title','edit_meta_title_count','19.9px arial')"
                                        placeholder="{{ __('meta_title') }}">
                                    <h6 id="edit_meta_title_count">0</h6>
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label>{{ __('meta_keywords') }}</label>
                                    <input id="edit_meta_tags" style="border-radius: 0.25rem" class="w-100"
                                        type="text" name="meta_keyword"
                                        placeholder="{{ __('press_enter_add_keywords') }}">
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label class="mr-2">{{ __('schema_markup') }}</label>
                                    <i data-content="Schema markup, also known as structured data, is the language search engines use to read and understand the content
                                        on your pages. By language, we mean a semantic vocabulary (code) that helps search engines characterize and categorize the content of web pages.
                                        Learn more about schema markup and generate it for your website using the .<a href='https://www.rankranger.com/schema-markup-generator' target='_blank'>Rank Ranger Schema Markup Generator</a>".
                                        class="fa fa-question-circle"></i>
                                    <input type="text" name="schema_markup" class="form-control"
                                        id="edit_schema_markup" placeholder="{{ __('schema_markup') }}">
                                </div>

                                <div class="form-group col-md-6 col-sm-12">
                                    <label>{{ __('image') }} </label>
                                    <input name="file" type="file" class="filepond">
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label>{{ __('meta_description') }} </label>
                                    <textarea id="edit_meta_description" name="meta_description" class="form-control"
                                        oninput="getWordCount('edit_meta_description','edit_meta_description_count','12.9px arial')"></textarea>
                                    <h6 id="edit_meta_description_count">0</h6>
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
        $(function() {
            $("#sortable-row").sortable();
        });

        function saveOrder() {
            var selectedLanguage = new Array();
            $('ol#sortable-row li').each(function() {
                selectedLanguage.push($(this).attr("id"));
            });
            document.getElementById("row_order").value = selectedLanguage;
        }

        $('#order_language_id').on('change', function(e) {
            var language_id = $('#order_language_id').val();
            $.ajax({
                url: '{{ route('get_category_by_language') }}',
                type: "POST",
                data: {
                    language_id: language_id,
                    sortable: 1
                },
                beforeSend: function() {
                    $('#sortable-row').html("Please wait..");
                },
                success: function(result) {
                    $('#sortable-row').html(result);
                    if ($('#sortable-row').html()) {
                        $('#order_btn').prop('disabled', false);
                    } else {
                        $('#order_btn').prop('disabled', true);
                    }
                },
                error: function(errors) {
                    console.log(errors);
                },
            });
        });

        $("#filter_language_id").on("change", function() {
            $('#table').bootstrapTable('refresh');
        });
    </script>

    <script type="text/javascript">
        function getSlug(data, title, slug) {
            var title1 = $(title).val();
            if (title1) {
                data['table'] = 'tbl_category';
                data['_token'] = "{{ csrf_token() }}";
                $.ajax({
                    url: '{{ route('get-slug') }}',
                    type: "POST",
                    data: data,
                    success: function(result) {
                        if (result) {
                            $(slug).val(result);
                        }
                    },
                    error: function(errors) {
                        console.log(errors);
                    },
                });
            } else {
                $(slug).val('');
            }
        }
        $(document).on('keyup', '#name', function(e) {
            var data = {
                'name': $('#name').val(),
            };
            getSlug(data, '#name', '#slug');
        });

        $(document).on('keyup', '#edit_name', function(e) {
            var data = {
                'name': $('#edit_name').val(),
                'id': $('#edit_id').val(),
            };
            getSlug(data, '#edit_name', '#edit_slug');
        });
    </script>

    <script type="text/javascript">
        window.actionEvents = {
            'click .edit-data': function(e, value, row, index) {
                $('#edit_id').val(row.id);
                $('#edit_name').val(row.category_name);
                $('#edit_language_id').val(row.language_id).trigger('change');
                $("#image_url").val(row.image_url);
                $('#edit_slug').val(row.slug);
                $('#edit_meta_tags').val(row.meta_keyword);
                $('#edit_schema_markup').val(row.schema_markup);
                $('#edit_meta_title').val(row.meta_title);
                $('#edit_meta_description').val(row.description)
                getWordCount('edit_meta_description', 'edit_meta_description_count', '12.9px arial');
                getWordCount('edit_meta_title', 'edit_meta_title_count', '19.9px arial');
            }
        }
    </script>
    <script type="text/javascript">
        function queryParams(p) {
            return {
                sort: p.sort,
                order: p.order,
                limit: p.limit,
                offset: p.offset,
                search: p.search,
                language_id: $('#filter_language_id').val(),
            };
        }
    </script>
@endsection
