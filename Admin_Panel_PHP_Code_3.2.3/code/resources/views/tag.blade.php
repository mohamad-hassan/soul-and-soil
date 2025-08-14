@extends('layouts.main')

@section('title')
    {{ __('tag') }}
@endsection

@section('content')
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">{{ __('create_and_manage') . ' ' . __('tag') }}</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item text-dark">
                            <a href="{{ route('home') }}" class="text-dark"><i
                                    class="fas fa-home mr-1"></i>{{ __('dashboard') }}</a>
                        </li>
                        <li class="breadcrumb-item active"><i class="nav-icon fas fa-tag mr-1"></i>{{ __('tag') }}</li>
                    </ol>
                </div>
            </div>
        </div>
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                @can('tag-create')
                <div class="col-md-12 d-flex justify-content-end">
                    <button id="toggleButton" class="btn btn-primary mb-3 ml-1"><i
                            class="fas fa-plus-circle mr-2"></i>{{ __('create') . ' ' . __('tag') }}</button>
                </div>
                @endcan
                <div class="col-md-12" id="add_card">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('create') . ' ' . __('tag') }}</h3>
                        </div>
                        <form id="create_form" action="{{ url('tag') }}" role="form" method="POST"
                            enctype="multipart/form-data">
                            @csrf
                            <div class="card-body">
                                <div class="row">
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="required">{{ __('language') }}</label>
                                        <select id="language" name="language" class="form-control" required>
                                            @if (count($languageList) > 1)
                                                <option value="">{{ __('select') . ' ' . __('language') }}</option>
                                            @endif
                                            @foreach ($languageList as $item)
                                                <option value="{{ $item->id }}">{{ $item->language }}
                                                </option>
                                            @endforeach
                                        </select>
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="required">{{ __('name') }}</label>
                                        <input id="name" name="name" required type="text"
                                            placeholder="{{ __('name') }}" class="form-control">
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="required">{{ __('slug') }}</label>
                                        <input id="slug" name="slug" required type="text"
                                            placeholder="{{ __('slug') }}" class="form-control">
                                        <span class="text-danger">{{ __('avoid_special_characters') }}</span>
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label class="mr-2">{{ __('schema_markup') }}</label>
                                        <i data-content="Schema markup, also known as structured data, is the language search engines use to read and understand the content
                                            on your pages. By language, we mean a semantic vocabulary (code) that helps search engines characterize and categorize the content of web pages.
                                            Learn more about schema markup and generate it for your website using the .<a href='https://www.rankranger.com/schema-markup-generator' target='_blank'>Rank Ranger Schema Markup Generator</a>".
                                            class="fa fa-question-circle"></i>
                                        <input type="text" name="schema_markup" class="form-control" id="schema_markup"
                                            placeholder="{{ __('schema_markup') }}">
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label>{{ __('meta_keywords') }}</label>
                                        <input id="meta_tags" style="border-radius: 0.25rem" class="w-100" type="text"
                                            name="meta_keyword" placeholder="{{ __('press_enter_add_keywords') }}">
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label>{{ __('meta_title') }}</label>
                                        <input type="text" name="meta_title" class="form-control" id="meta_title"
                                            oninput="getWordCount('meta_title','meta_title_count','19.9px arial')"
                                            placeholder="{{ __('meta_title') }}">
                                        <h6 id="meta_title_count">0</h6>
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label>{{ __('meta_description') }}</label>
                                        <textarea id="meta_description" name="meta_description" class="form-control"
                                            oninput="getWordCount('meta_description','meta_description_count','12.9px arial')"></textarea>
                                        <h6 id="meta_description_count">0</h6>
                                    </div>
                                    <div class="form-group col-md-3 col-sm-12">
                                        <label>{{ __('og_image') }} </label>
                                        <input name="file" type="file" class="filepond">
                                    </div>
                                </div>
                            </div>
                            <div class="card-footer">
                                <button type="submit" class="btn btn-primary">{{ __('submit') }}</button>
                            </div>
                        </form>
                    </div>
                </div>
                @can('tag-list')
                <div class="col-md-12">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('tag') . ' ' . __('list') }}</h3>
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
                                data-url="{{ route('tagList') }}" data-click-to-select="true"
                                data-side-pagination="server" data-pagination="true"
                                data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true"
                                data-show-refresh="true" data-toolbar="#toolbar" data-mobile-responsive="true"
                                data-buttons-class="primary" data-trim-on-search="false" data-sort-name="id"
                                data-sort-order="desc" data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th scope="col" data-field="id" data-sortable="true">{{ __('id') }}</th>
                                        <th scope="col" data-field="language_id" data-visible="false">
                                            {{ __('language_id') }}</th>
                                        <th scope="col" data-field="language">{{ __('language') }}</th>
                                        <th scope="col" data-field="tag_name">{{ __('name') }}</th>
                                        <th scope="col" data-field="slug">{{ __('slug') }}</th>
                                        <th scope="col" data-field="og_image">{{ __('og_image') }}</th>
                                        <th scope="col" data-field="schema_markup" data-visible="false">
                                            {{ __('schema_markup') }}</th>
                                        <th scope="col" data-field="meta_keyword" data-visible="false">
                                            {{ __('meta_keywords') }}</th>
                                        <th scope="col" data-field="description" data-visible="false">
                                            {{ __('meta_description') }}</th>
                                        <th scope="col" data-field="meta_title" data-visible="false">
                                            {{ __('meta_title') }}</th>
                                        @canany(['tag-edit', 'tag-delete'])
                                        <th scope="col" data-field="operate" data-sortable="false"
                                            data-events="actionEvents">{{ __('operate') }}</th>
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
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">{{ __('edit') . ' ' . __('tag') }}</h4>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <form id="update_form" action="{{ url('tag') }}" role="form" method="POST"
                        enctype="multipart/form-data">
                        @csrf
                        <input type='hidden' name="edit_id" id="edit_id" value='' />
                        <div class="modal-body">
                            <div class="row">
                                <div class="form-group col-md-6 col-sm-12">
                                    <label class="required">{{ __('language') }}</label>
                                    <select id="edit_language" name="language" class="form-control" required>
                                        <option value="">{{ __('select') . ' ' . __('language') }}</option>
                                        @foreach ($languageList as $item)
                                            <option value="{{ $item->id }}">{{ $item->language }}
                                            </option>
                                        @endforeach
                                    </select>
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label class="required">{{ __('name') }}</label>
                                    <input name="name" id="edit_name" required type="text" class="form-control">
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group col-md-6 col-sm-12">
                                    <label class="required">{{ __('slug') }}</label>
                                    <input id="edit_slug" name="slug" required type="text" class="form-control">
                                    <span class="text-danger">{{ __('avoid_special_characters') }}</span>
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label>{{ __('meta_title') }}</label>
                                    <input type="text" name="meta_title" class="form-control" id="edit_meta_title"
                                        oninput="getWordCount('edit_meta_title','edit_meta_title_count','19.9px arial')"
                                        placeholder="{{ __('meta_title') }}">
                                    <h6 id="edit_meta_title_count">0</h6>
                                </div>
                            </div>
                            <div class="row">
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
                                    <label>{{ __('meta_keywords') }}</label>
                                    <input id="edit_meta_tags" style="border-radius: 0.25rem" class="w-100"
                                        type="text" name="meta_keyword"
                                        placeholder="{{ __('press_enter_add_keywords') }}">
                                </div>
                            </div>
                            <div class="row">
                                <div class="form-group col-md-6 col-sm-12">
                                    <label>{{ __('meta_description') }}</label>
                                    <textarea id="edit_meta_description" name="meta_description" class="form-control"
                                        oninput="getWordCount('edit_meta_description','edit_meta_description_count','12.9px arial')"></textarea>
                                    <h6 id="edit_meta_description_count">0</h6>
                                </div>
                                <div class="form-group col-md-6 col-sm-12">
                                    <label>{{ __('og_image') }} </label>
                                    <input name="file" type="file" class="filepond">
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
        function getSlug(data, title, slug) {
            var title1 = $(title).val();
            if (title1) {
                data['table'] = 'tbl_tag';
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
                $("#edit_name").val(row.tag_name);
                $("#edit_language").val(row.language_id).trigger('change');
                $('#edit_slug').val(row.slug);
                $('#edit_meta_tags').val(row.meta_keyword);
                $('#edit_schema_markup').val(row.schema_markup);
                $('#edit_meta_description').val(row.description);
                $('#edit_meta_title').val(row.meta_title);
                getWordCount('edit_meta_description', 'edit_meta_description_count', '12.9px arial');
                getWordCount('edit_meta_title', 'edit_meta_title_count', '19.9px arial');
            }
        };
    </script>

    <script type="text/javascript">
        $("#filter_language_id").on("change", function() {
            $('#table').bootstrapTable('refresh');
        });

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
