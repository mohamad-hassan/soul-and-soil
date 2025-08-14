@extends('layouts.main')

@section('title')
    {{ __('featured_section') }}
@endsection

@section('content')
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0">{{ __('create_and_manage') . ' ' . __('featured_section') }}</h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item text-dark">
                            <a href="{{ route('home') }}" class="text-dark"><i
                                    class="fas fa-home mr-1"></i>{{ __('dashboard') }}</a>
                        </li>
                        <li class="breadcrumb-item active"><i
                                class="nav-icon fas fa-layer-group mr-1"></i>{{ __('featured_section') }}</li>
                    </ol>
                </div>
            </div>
        </div>
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="row">
                @can('featured-section-create')
                <div class="col-md-12 d-flex justify-content-end">
                    <button id="toggleButton" class="btn btn-primary mb-3 ml-1"><i
                            class="fas fa-plus-circle mr-2"></i>{{ __('create') . ' ' . __('featured_section') }}</button>
                </div>
                @endcan
                <div class="col-md-12" id="add_card">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('create') . ' ' . __('featured_section') }}</h3>
                        </div>
                        <form id="create_form" action="{{ route('featured_sections.store') }}" role="form" method="POST"
                            enctype="multipart/form-data">
                            @csrf
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-4 col-sm-12">
                                        <div class="form-group">
                                            <label class="required">{{ __('language') }}</label>
                                            <select id="language_id" name="language_id" class="form-control" required>
                                                @if (count($languageList) > 1)
                                                    <option value="">{{ __('select') . ' ' . __('language') }}
                                                    </option>
                                                @endif
                                                @foreach ($languageList as $item)
                                                    <option value="{{ $item->id }}">{{ $item->language }}</option>
                                                @endforeach
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label class="required">{{ __('title') }}</label>
                                            <input id="title" name="title" required placeholder="{{ __('title') }}"
                                                type="text" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label class="required">{{ __('slug') }}</label>
                                            <input id="slug" name="slug" required placeholder="{{ __('slug') }}"
                                                type="text" class="form-control">
                                            <span class="text-danger">{{ __('avoid_special_characters') }}</span>
                                        </div>
                                        <div class="form-group">
                                            <label class="mr-2">{{ __('schema_markup') }}</label><i
                                                data-content="Schema markup, also known as structured data, is the language search engines use to read and understand the content
                                                on your pages. By language, we mean a semantic vocabulary (code) that helps search engines characterize and categorize the content of web pages.
                                                Learn more about schema markup and generate it for your website using the .<a href='https://www.rankranger.com/schema-markup-generator' target='_blank'>Rank Ranger Schema Markup Generator</a>".
                                                class="fa fa-question-circle"></i>
                                            <input type="text" name="schema_markup" class="form-control"
                                                id="schema_markup" placeholder="{{ __('schema_markup') }}">
                                        </div>
                                        <div class="form-group">
                                            <label>{{ __('display_news_based_user_preference') }}</label>
                                            <div>
                                                <input type="checkbox" id="is_based_on_user_choice"
                                                    name="is_based_on_user_choice" class="status-switch">
                                                <input type="hidden" id="based_on_user_choice_mode"
                                                    class="based_on_user_choice_mode" name="based_on_user_choice_mode"
                                                    value="0">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div id="filter_section">
                                            <div class="form-group">
                                                <label class="required">{{ __('news_type') }}</label>
                                                <select id="news_type" name="news_type" class="form-control news_type"
                                                    required>
                                                    <option value="">{{ __('select') . ' ' . __('news_type') }}
                                                    </option>
                                                    <option value="news">{{ __('news') }}</option>
                                                    @if (is_breaking_news_enabled() == 1)
                                                        <option value="breaking_news">{{ __('breaking_news') }}</option>
                                                    @endif
                                                    <option value="videos">{{ __('videos') }}</option>
                                                </select>
                                            </div>
                                            <div class="form-group" id="videos_option" style="display: none">
                                                <label class="required">{{ __('which_videos_want_show') }}</label>
                                                <select id="videos_type" name="videos_type" class="form-control">
                                                    <option value=""> {{ __('select_option') }}</option>
                                                    <option value="news">{{ __('news') }}</option>
                                                    @if (is_breaking_news_enabled() == 1)
                                                        <option value="breaking_news">{{ __('breaking_news') }}</option>
                                                    @endif
                                                </select>
                                            </div>
                                            <div class="form-group">
                                                <label class="required">{{ __('type_of_filter') }}</label>
                                                <select id="filter_type" name="filter_type" class="form-control filter_type"
                                                    required>
                                                    <option value="">{{ __('select_option') }}</option>
                                                    <option value="most_commented" class="most_commented">
                                                        {{ __('most_commented') }}</option>
                                                    <option value="recently_added">{{ __('recently_added') }}</option>
                                                    <option value="most_viewed">{{ __('most_viewed') }}</option>
                                                    <option value="most_favorite" class="most_favorite">
                                                        {{ __('most_favorite') }}</option>
                                                    <option value="most_like" class="most_like">{{ __('most_like') }}
                                                    </option>
                                                    <option value="custom">{{ __('custom') }}</option>
                                                </select>
                                            </div>
                                            @if (is_category_enabled() == 1)
                                                <div id="filter_news" class="form-group">
                                                    <label class="required">{{ __('category') }}</label>
                                                    <select id="category_ids" name="category_ids[]" class="form-control"
                                                        with="100%" multiple="multiple">
                                                        <option value="0" disabled>
                                                            {{ __('select') . ' ' . __('category') }}</option>
                                                        @foreach ($categoryList as $row)
                                                            <option value="cat-{{ $row->id }}">{{ $row->category_name }}</option>
                                                            @if (is_subcategory_enabled() == 1)
                                                                @foreach ($row->sub_categories as $row1)
                                                                    <option value="subcat-{{ $row1->id }}">--{{ $row1->subcategory_name }}</option>
                                                                @endforeach
                                                            @endif
                                                        @endforeach
                                                    </select>
                                                </div>
                                            @endif
                                            <div class="form-group" id="custom" style="display: none">
                                                <label class="required">{{ __('news') }}</label>
                                                <select id="news_ids" name="news_ids[]" class=" form-control"
                                                    multiple="multiple">
                                                </select>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label>{{ __('meta_description') }}</label>
                                            <textarea id="meta_description" name="meta_description" class="form-control"
                                                oninput="getWordCount('meta_description','meta_description_count','12.9px arial')"></textarea>
                                            <h6 id="meta_description_count">0</h6>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label class="required">{{ __('short_description') }}</label>
                                            <input type="text" name="short_description" class="form-control"
                                                placeholder="{{ __('short_description') }}" required>
                                        </div>
                                        <div class="form-group">
                                            <label>{{ __('meta_keywords') }}</label>
                                            <input id="meta_tags" style="border-radius: 0.25rem" class="w-100"
                                                type="text" name="meta_keyword"
                                                placeholder="{{ __('press_enter_add_keywords') }}">
                                        </div>
                                        <div class="form-group">
                                            <label>{{ __('meta_title') }}</label>
                                            <input type="text" name="meta_title" class="form-control" id="meta_title"
                                                oninput="getWordCount('meta_title','meta_title_count','19.9px arial')"
                                                placeholder="{{ __('meta_title') }}">
                                            <h6 id="meta_title_count">0</h6>
                                        </div>
                                        <div class="form-group">
                                            <label>{{ __('og_image') }} </label>
                                            <input name="file" type="file" class="filepond">
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group row">
                                            <div class="col-md-12 col-sm-12">
                                                <label class="required">{{ __('select_style_for_app_section') }}</label>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img">
                                                    <input type="radio" name="style_app" value="style_1" required
                                                        class="form-control" />
                                                    <img src="images/app_style/App_Style_1.png" alt="style_1"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img">
                                                    <input type="radio" name="style_app" value="style_2" />
                                                    <img src="images/app_style/App_Style_2.png" alt="style_2"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img">
                                                    <input type="radio" name="style_app" value="style_3" />
                                                    <img src="images/app_style/App_Style_3.png" alt="style_3"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img">
                                                    <input type="radio" name="style_app" value="style_4" />
                                                    <img src="images/app_style/App_Style_4.png" alt="style_4"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img">
                                                    <input type="radio" name="style_app" value="style_5" />
                                                    <img src="images/app_style/App_Style_5.png" alt="style_5"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img">
                                                    <input type="radio" name="style_app" value="style_6" />
                                                    <img src="images/app_style/App_Style_6.png" alt="style_6"
                                                        class="style_image">
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group row">
                                            <div class="col-md-12 col-sm-12">
                                                <label class="required">{{ __('Select Style for Web Section') }}</label>
                                            </div>
                                        </div>
                                        <div class="form-group row">
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img-web">
                                                    <input type="radio" name="style_web" value="style_1"
                                                        class="form-control" required />
                                                    <img src="images/app_style/Web_Style_1.png" alt="style_1"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img-web">
                                                    <input type="radio" name="style_web" value="style_2" />
                                                    <img src="images/app_style/Web_Style_2.png" alt="style_2"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img-web">
                                                    <input type="radio" name="style_web" value="style_3" />
                                                    <img src="images/app_style/Web_Style_3.png" alt="style_3"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img-web">
                                                    <input type="radio" name="style_web" value="style_4" />
                                                    <img src="images/app_style/Web_Style_4.png" alt="style_4"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img-web">
                                                    <input type="radio" name="style_web" value="style_5" />
                                                    <img src="images/app_style/Web_Style_5.png" alt="style_5"
                                                        class="style_image">
                                                </label>
                                            </div>
                                            <div class="col-md-2 col-sm-2">
                                                <label class="radio-img-web">
                                                    <input type="radio" name="style_web" value="style_6" />
                                                    <img src="images/app_style/Web_Style_6.png" alt="style_6"
                                                        class="style_image">
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="card-footer">
                                <button type="submit" class="btn btn-primary">{{ __('submit') }}</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            @can('featured-section-list')
            <div class="row">
                <div class="col-lg-9 col-md-12 col-sm-12">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('featured_section') . ' ' . __('list') }}</h3>
                        </div>
                        <div class="card-body">
                            <div id="toolbar" class="d-flex">
                                <div class="mr-3">
                                    <select id="filter_language_id" class="form-control">
                                        <option value="0">{{ __('select') . ' ' . __('language') }}</option>
                                        @foreach ($languageList as $row)
                                            <option value="{{ $row->id }}">{{ $row->language }}</option>
                                        @endforeach
                                    </select>
                                </div>
                                <div>
                                    <select id="filter_status" class="form-control">
                                        <option value="">{{ __('status') }}</option>
                                        <option value="1">{{ __('active') }}</option>
                                        <option value="0">{{ __('deactive') }}</option>
                                    </select>
                                </div>
                            </div>
                            <table aria-describedby="mydesc" id='table' data-toggle="table"
                                data-url="{{ route('featuredSectionList') }}" data-click-to-select="true"
                                data-side-pagination="server" data-pagination="true"
                                data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true" data-show-columns="true"
                                data-show-refresh="true" data-toolbar="#toolbar" data-mobile-responsive="true"
                                data-buttons-class="primary" data-trim-on-search="false" data-sort-name="row_order"
                                data-sort-order="asc" data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th scope="col" data-field="id" data-sortable="true">{{ __('id') }}</th>
                                        <th scope="col" data-field="language">{{ __('language') }}</th>
                                        <th scope="col" data-field="title" data-sortable="false">{{ __('title') }}
                                        </th>
                                        <th scope="col" data-field="slug" data-sortable="false">{{ __('slug') }}
                                        </th>
                                        <th scope="col" data-field="news_type_badge">{{ __('news_type') }}</th>
                                        <th scope="col" data-field="video_type_badge">{{ __('video_type') }}</th>
                                        <th scope="col" data-field="filter_type_badge">{{ __('type_of_filter') }}</th>
                                        <th scope="col" data-field="style_app">{{ __('app_style') }}</th>
                                        <th scope="col" data-field="style_web">{{ __('web_style') }}</th>
                                        <th scope="col" data-field="status1">{{ __('status') }}</th>
                                        <th scope="col" data-field="short_description" data-visible="false">
                                            {{ __('short_description') }}</th>
                                        <th scope="col" data-field="schema_markup" data-visible="false">
                                            {{ __('schema_markup') }}</th>
                                        <th scope="col" data-field="meta_keyword" data-visible="false">
                                            {{ __('meta_keywords') }}</th>
                                        <th scope="col" data-field="og_image" data-visible="false">
                                            {{ __('og_image') }}</th>
                                        <th scope="col" data-field="meta_title" data-visible="false">
                                            {{ __('meta_title') }}</th>
                                        <th scope="col" data-field="meta_description" data-visible="false">
                                            {{ __('meta_description') }}</th>
                                        <th scope="col" data-field="row_order" data-sortable="true">
                                            {{ __('row_order') }}</th>
                                        <th scope="col" data-field="created_at" data-visible="false">
                                            {{ __('created_at') }}</th>
                                        @canany(['featured-section-edit', 'featured-section-delete'])
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
                @can('featured-section-order-create')
                <div class="col-lg-3 col-md-12 col-sm-12">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title">{{ __('featured_section') . ' ' . __('order') }}</h3>
                        </div>
                        <form id="order_form" action="{{ route('update_featured_sections_order') }}" method="post"
                            onsubmit="return saveOrder()">
                            @csrf
                            <div class="card-body">
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
                                        @foreach ($featuredList as $row)
                                            <li id="{{ $row->id }}">{{ $row->title }}</li>
                                        @endforeach
                                    </ol>
                                </div>
                                <button type="submit" class="btn btn-primary float-right">{{ __('submit') }}</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            @endcan
        </div>
        <div class="modal fade" id="editDataModal">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">{{ __('edit') . ' ' . __('featured_section') }}</h4>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <form id="update_form" action="{{ url('featured_sections') }}" role="form" method="POST"
                        enctype="multipart/form-data">
                        @csrf
                        <input type='hidden' name="edit_id" id="edit_id" value='' />
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="required">{{ __('language') }}</label>
                                        <select id="edit_language_id" name="language_id" class="form-control language_id"
                                            required>
                                            <option disabled>{{ __('select') . ' ' . __('language') }}</option>
                                            @foreach ($languageList as $item)
                                                <option value="{{ $item->id }}">{{ $item->language }}
                                                </option>
                                            @endforeach
                                        </select>
                                    </div>
                                    <div class="form-group">
                                        <label class="required">{{ __('title') }}</label>
                                        <input id="edit_title" name="title" type="text" required
                                            class="form-control">
                                    </div>
                                    <div class="form-group">
                                        <label class="required">{{ __('slug') }}</label>
                                        <input id="edit_slug" name="slug" type="text" required
                                            class="form-control">
                                        <span class="text-danger">{{ __('avoid_special_characters') }}</span>
                                    </div>
                                    <div class="form-group">
                                        <label class="mr-2">{{ __('schema_markup') }}</label><i
                                            data-content="Schema markup, also known as structured data, is the language search engines use to read and understand the content
                                            on your pages. By language, we mean a semantic vocabulary (code) that helps search engines characterize and categorize the content of web pages.
                                            Learn more about schema markup and generate it for your website using the .<a href='https://www.rankranger.com/schema-markup-generator' target='_blank'>Rank Ranger Schema Markup Generator</a>".
                                            class="fa fa-question-circle"></i>
                                        <input id="edit_schema_markup" name="schema_markup" type="text"
                                            placeholder="{{ __('schema_markup') }}" class="form-control">
                                    </div>
                                    <div class="form-group">
                                        <label>{{ __('display_news_based_user_preference') }}</label>
                                        <div>
                                            <input type="checkbox" id="edit_is_based_on_user_choice"
                                                name="edit_is_based_on_user_choice" class="status-switch editInModel">
                                            <input type="hidden" id="edit_based_on_user_choice_mode"
                                                class="edit_based_on_user_choice_mode"
                                                name="edit_based_on_user_choice_mode" value="1">
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div id="edit_filter_section">
                                        <div class="form-group">
                                            <label class="required">{{ __('news_type') }}</label>
                                            <select id="edit_news_type" name="news_type" class="form-control">
                                                <option value="news">{{ __('news') }}</option>
                                                @if (is_breaking_news_enabled() == 1)
                                                    <option value="breaking_news">{{ __('breaking_news') }}</option>
                                                @endif
                                                <option value="videos">{{ __('videos') }}</option>
                                            </select>
                                        </div>
                                        <div id="edit_videos_option" class="form-group">
                                            <label>{{ __('which_videos_want_show') }}</label>
                                            <select id="edit_videos_type" name="videos_type" class="form-control">
                                                <option value="">{{ __('select') }}</option>
                                                <option value="news">{{ __('news') }}</option>
                                                @if (is_breaking_news_enabled() == 1)
                                                    <option value="breaking_news">{{ __('breaking_news') }}</option>
                                                @endif
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label class="required">{{ __('type_of_filter') }}</label>
                                            <select id="edit_filter_type" name="filter_type"
                                                class="form-control filter_type">
                                                <option value="">{{ __('select_option') }}</option>
                                                <option value="most_commented" class="most_commented">
                                                    {{ __('most_commented') }}</option>
                                                <option value="recently_added">{{ __('recently_added') }}</option>
                                                <option value="most_viewed">{{ __('most_viewed') }}</option>
                                                <option value="most_favorite" class="most_favorite">
                                                    {{ __('most_favorite') }}</option>
                                                <option value="most_like" class="most_like">{{ __('most_like') }}
                                                </option>
                                                <option value="custom">{{ __('custom') }}</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            @if (is_category_enabled() == 1)
                                                <div id="edit_filter_news" class="form-group">
                                                    <label class="required">{{ __('category') }}</label>
                                                    <select id="edit_category_ids" name="category_ids[]"
                                                        class="form-control" multiple="multiple">
                                                    </select>
                                                </div>
                                            @endif
                                            <div id="edit_custom" class="form-group">
                                                <label class="required"> {{ __('news') }}</label>
                                                <select id="edit_news_ids" name="news_ids[]" class="form-control"
                                                    multiple="multiple">
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label>{{ __('meta_description') }}</label>
                                        <textarea id="edit_meta_description" name="meta_description" class="form-control"
                                            oninput="getWordCount('edit_meta_description','edit_meta_description_count','12.9px arial')"></textarea>
                                        <h6 id="edit_meta_description_count">0</h6>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label class="required">{{ __('short_description') }}</label>
                                        <input type="text" id="edit_short_description" name="short_description"
                                            class="form-control" placeholder="{{ __('short_description') }}">
                                    </div>
                                    <div class="form-group">
                                        <label>{{ __('meta_keywords') }}</label>
                                        <input id="edit_meta_tags" class="w-100" type="text" name="meta_keyword"
                                            style="border-radius: 0.25rem"
                                            placeholder="{{ __('press_enter_add_keywords') }}">
                                    </div>
                                    <div class="form-group">
                                        <label>{{ __('meta_title') }}</label>
                                        <input id="edit_meta_title" name="meta_title" type="text"
                                            oninput="getWordCount('edit_meta_title','edit_meta_title_count','19.9px arial')"
                                            placeholder="{{ __('meta_title') }}" class="form-control">
                                        <h6 id="edit_meta_title_count">0</h6>
                                    </div>
                                    <div class="form-group">
                                        <div class="form-group">
                                            <label>{{ __('og_image') }} </label>
                                            <input name="file" type="file" class="filepond">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="form-group row">
                                <div class="col-md-6 row">
                                    <div class="col-lg-12">
                                        <label class="required">{{ __('select_style_for_app_section') }}</label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img">
                                            <input type="radio" name="style_app" value="style_1" required />
                                            <img src="images/app_style/App_Style_1.png" alt="style_1"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img">
                                            <input type="radio" name="style_app" value="style_2" />
                                            <img src="images/app_style/App_Style_2.png" alt="style_2"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img">
                                            <input type="radio" name="style_app" value="style_3" />
                                            <img src="images/app_style/App_Style_3.png" alt="style_3"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img">
                                            <input type="radio" name="style_app" value="style_4" />
                                            <img src="images/app_style/App_Style_4.png" alt="style_4"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img">
                                            <input type="radio" name="style_app" value="style_5" />
                                            <img src="images/app_style/App_Style_5.png" alt="style_5"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img">
                                            <input type="radio" name="style_app" value="style_6" />
                                            <img src="images/app_style/App_Style_6.png" alt="style_6"
                                                class="style_image">
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6 row">
                                    <div class="col-lg-12">
                                        <label class="required"> {{ __('Select Style for Web Section') }}</label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img-web">
                                            <input type="radio" name="style_web" value="style_1" required />
                                            <img src="images/app_style/Web_Style_1.png" alt="style_1"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img-web">
                                            <input type="radio" name="style_web" value="style_2" />
                                            <img src="images/app_style/Web_Style_2.png" alt="style_2"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img-web">
                                            <input type="radio" name="style_web" value="style_3" />
                                            <img src="images/app_style/Web_Style_3.png" alt="style_3"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img-web">
                                            <input type="radio" name="style_web" value="style_4" />
                                            <img src="images/app_style/Web_Style_4.png" alt="style_4"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img-web">
                                            <input type="radio" name="style_web" value="style_5" />
                                            <img src="images/app_style/Web_Style_5.png" alt="style_5"
                                                class="style_image">
                                        </label>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="radio-img edit-radio-img-web">
                                            <input type="radio" name="style_web" value="style_6" />
                                            <img src="images/app_style/Web_Style_6.png" alt="style_6"
                                                class="style_image">
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-sm-6 col-xs-12">
                                <label class="control-label"> {{ __('status') }}</label>
                                <div id="status1" class="btn-group">
                                    <label class="btn btn-success" data-toggle-class="btn-primary"
                                        data-toggle-passive-class="btn-default">
                                        <input class="mr-1" type="radio" name="status"
                                            value="1">{{ __('active') }}
                                    </label>
                                    <label class="btn btn-danger" data-toggle-class="btn-primary"
                                        data-toggle-passive-class="btn-default">
                                        <input class="mr-1" type="radio" name="status"
                                            value="0">{{ __('deactive') }}
                                    </label>
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
            data['table'] = 'tbl_featured_sections';
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
    $(document).on('keyup', '#title', function(e) {
        var data = {
            'name':  $('#title').val(),
        };
        getSlug(data, '#title', '#slug');
    });

    $(document).on('keyup', '#edit_title', function(e) {
        var data = {
            'name':  $('#edit_title').val(),
            'id':  $('#edit_id').val(),
        };
        getSlug(data, '#edit_title', '#edit_slug');
    });
</script>
    <script type="text/javascript">
        window.actionEvents = {
            'click .edit-data': function(e, value, row, index) {
                $("#edit_language_id").val(row.language_id).trigger('change', [row.language_id, row.category_id, row
                    .subcategory_id, row.news_id, row.filter_type, row.news_type
                ]);
                $('#edit_id').val(row.id);
                $("#edit_title").val(row.title);
                $('#edit_slug').val(row.slug);
                $("#edit_schema_markup").val(row.schema_markup);
                $("#edit_videos_type").val(row.videos_type);
                if (row.news_type == "videos") {
                    $('#edit_videos_option').show();
                } else {
                    $('#edit_videos_option').hide();
                }
                $("#edit_short_description").val(row.short_description_full);
                $('#edit_meta_description').val(row.meta_description);
                $('#edit_meta_title').val(row.meta_title);
                $("#edit_meta_tags").val(row.meta_keyword);
                getWordCount('edit_meta_description', 'edit_meta_description_count', '12.9px arial');
                getWordCount('edit_meta_title', 'edit_meta_title_count', '19.9px arial');
                if (row.status == 0) {
                    $("input[name=status][value=0]").prop('checked', true);
                } else {
                    $("input[name=status][value=1]").prop('checked', true);
                }
                setTimeout(function() {
                    if (row.is_based_on_user_choice == "1") {
                        $(".editInModel").prop("checked", false).trigger("click");
                    } else {
                        $(".editInModel").prop("checked", true).trigger("click");
                    }
                }, 1000);
                $("input[name=style_app][value=" + row.style_app_edit + "]").prop('checked', true);
                $("input[name=style_web][value=" + row.style_web_edit + "]").prop('checked', true);
            },
        };
    </script>

    <script type="text/javascript">
        $("#filter_language_id").on("change", function() {
            $('#table').bootstrapTable('refresh');
        });
        $("#filter_status").on("change", function() {
            $('#table').bootstrapTable('refresh');
        });

        function queryParams(p) {
            return {
                limit: p.limit,
                order: p.order,
                offset: p.offset,
                search: p.search,
                language_id: $('#filter_language_id').val(),
                status: $('#filter_status').val(),
            };
        }
    </script>

    <script type="text/javascript">
        function saveOrder() {
            var selectedLanguage = new Array();
            $('ol#sortable-row li').each(function() {
                selectedLanguage.push($(this).attr("id"));
            });
            document.getElementById("row_order").value = selectedLanguage;
        }

        $('#order_language_id').on('change', function(e) {
            var language_id = $('#order_language_id').val();
            var url = '{{ route('get_feature_section_by_language') }}';
            var data = {
                language_id: language_id,
                sortable: 1
            };
            fetchList(url, data, '#sortable-row');
        });

        $(function() {
            $("#sortable-row").sortable();

            $('.videos').hide();

            $('#category_ids').select2({
                placeholder: '{{ __('select') . ' ' . __('category') }}'
            });
            $('#news_ids').select2({
                placeholder: '{{ __('select') . ' ' . __('news') }}'
            });

            $('#edit_category_ids').select2({
                placeholder: '{{ __('select') . ' ' . __('category') }}'
            });
            $('#edit_news_ids').select2({
                placeholder: '{{ __('select') . ' ' . __('news') }}'
            });

            var elems = Array.prototype.slice.call(
                document.querySelectorAll(".status-switch")
            );
            elems.forEach(function(elem) {
                var switchery = new Switchery(elem, {
                    size: "small",
                    color: "#47C363",
                    secondaryColor: "#EB4141",
                    jackColor: "#ffff",
                    jackSecondaryColor: "#ffff",
                });
            });
        });
    </script>

    <script type="text/javascript">
        $(document).on('change', '#language_id', function(e) {
            var language_id = $('#language_id').val();
            var data = {
                language_id: language_id,
            };
            var url = '{{ route('get_categories_tree') }}';
            fetchList(url, data, '#category_ids');
        });

        $(document).on('change', '#news_type', function(e) {
            var news_type = $(this).val();
            if (news_type == "videos") {
                $("#videos_type").prop('required', true);
                $('#videos_option').show();
            } else {
                $("#videos_type").prop('required', false);
                $('#videos_option').hide();
            }
            if (news_type == "breaking_news") {
                $('#filter_news').hide();
                $('.most_commented').hide();
                $('.most_like').hide();
                $('.most_favorite').hide();
            } else {
                $('#filter_news').show();
                $('.most_commented').show();
                $('.most_like').show();
                $('.most_favorite').show();
            }
        });

        $(document).on('change', '#filter_type', function(e) {
            var filter_type = $(this).val();
            var news_type = $('#news_type').val();
            var videos_type = $('#videos_type').val();
            var language_id = $('#language_id').val();
            if (news_type == 'news' || news_type == 'videos') {
                if (filter_type == 'custom') {
                    $('#custom').show();
                    $('#filter_news').hide();
                } else {
                    $('#filter_news').show();
                    $('#custom').hide();
                }
            } else {
                if (filter_type == 'custom') {
                    $('#custom').show();
                    $('#filter_news').hide();
                } else {
                    $('#filter_news').hide();
                    $('#custom').hide();
                }
            }
            if (filter_type == 'custom') {
                var data = {
                    language_id: language_id,
                    news_type: news_type,
                    videos_type: videos_type
                };
                var url = '{{ route('get_custom_news') }}';
                fetchList(url, data, '#news_ids');
            }
        });

        $(document).on('change', '#videos_type', function(e) {
            var videos = $(this).val();
            if (videos == "breaking_news") {
                $('.most_commented').hide();
                $('.most_like').hide();
                $('.most_favorite').hide();
            } else {
                $('.most_commented').show();
                $('.most_like').show();
                $('.most_favorite').show();
            }
        });

        var is_based_on_user_choice = document.querySelector('#is_based_on_user_choice');
        is_based_on_user_choice.onchange = function() {
            if (is_based_on_user_choice.checked) {
                $('#based_on_user_choice_mode').val(1);
                $('#news_type').prop('required', false);
                $('#filter_type').prop('required', false);
                $('#filter_section').hide();
                // $('#filter_type').removeAttr('required');
            } else {
                $('#based_on_user_choice_mode').val(0);
                $('#news_type').prop('required', true);
                $('#filter_type').prop('required', true);
                $('#filter_section').show();
            }
        };

        /* on change of edit_based_on_choice_mode mode btn - switchery js */
        var edit_is_based_on_user_choice = document.querySelector('#edit_is_based_on_user_choice');
        edit_is_based_on_user_choice.onchange = function() {
            if (edit_is_based_on_user_choice.checked) {
                $('#edit_based_on_user_choice_mode').val(1);
                $('#edit_filter_section').hide();
                $('#edit_news_type').val('');
                $('#edit_videos_type').val('');
                $('#edit_filter_type').val('');
                $('#edit_category_ids').val('');
                $('#edit_news_ids').val('');
            } else {
                $('#edit_based_on_user_choice_mode').val(0);
                $('#edit_filter_section').show();
            }
        };

        $(document).on('change', '#edit_videos_type', function(e) {
            var videos = $(this).val();
            if (videos == "breaking_news") {
                $('.most_commented').hide();
                $('.most_like').hide();
                $('.most_favorite').hide();
            } else {
                $('.most_commented').show();
                $('.most_like').show();
                $('.most_favorite').show();
            }
        });

        $(document).on('change', '#edit_language_id', function(e, row_language_id, row_category_id, row_subcategory_id,
            row_news_id, row_filter_type, row_news_type) {
            var language_id = $('#edit_language_id').val();
            $.ajax({
                url: '{{ route('get_categories_tree') }}',
                type: "POST",
                data: {
                    language_id: language_id,
                },
                beforeSend: function() {
                    $('#edit_category_ids').html("Please wait..");
                },
                success: function(result) {
                    $('#edit_category_ids').html(result);
                    var filter_type = $('#edit_filter_type').val();
                    $("#edit_filter_type").val(row_filter_type).trigger('change', [row_filter_type,
                        row_news_id
                    ]);
                    $("#edit_news_type").val(row_news_type).trigger('change', [row_filter_type,
                        row_news_id, row_category_id, row_subcategory_id
                    ]);
                },
                error: function(errors) {
                    console.log(errors);
                },
            });
        });

        $(document).on('change', '#edit_news_type', function(e, row_filter_type, row_news_id, row_category_id,
            row_subcategory_id) {
            var news_type = $(this).val();
            if (news_type == 'videos') {
                $("#edit_videos_type").prop('required', true);
                $('#edit_videos_option').show();
            } else {
                $("#edit_videos_type").prop('required', false);
                $('edit_videos_option').hide();
            }

            if (row_filter_type == 'custom') {
                $('#edit_filter_news').hide();
                $('#edit_custom').show();
                console.log('row_news_id', row_news_id);

                var valueArray = row_news_id;
                if (valueArray) {
                    var arrayArea = valueArray.split(',');
                }
                $("#edit_news_ids").val(arrayArea).trigger("change");
            } else {
                $('#edit_filter_news').show();
                $('#edit_custom').hide();

                var category_ids = [];
                var subcategory_ids = [];
                if (row_category_id || row_subcategory_id) {
                    if (row_category_id) {
                        var row_category_id1 = row_category_id.split(',');
                        var prefix = 'cat-';
                        var category_ids = row_category_id1.map(el => prefix + el);
                    }
                    if (row_subcategory_id) {
                        var subcategory_idArea = row_subcategory_id.split(',');
                        var prefix = 'subcat-';
                        var subcategory_ids = subcategory_idArea.map(el => prefix + el);
                        if (row_category_id.length > 0 && row_subcategory_id.length > 0) {
                            var merge = $.merge(category_ids, subcategory_ids);
                        }
                    }
                    $("#edit_category_ids").val(category_ids).trigger("change");
                }
            }
            if (news_type == 'breaking_news') {
                $('.most_commented').hide();
                $('.most_like').hide();
                $('.most_favorite').hide();
                if (row_filter_type == 'custom') {
                    $('#edit_filter_news').hide();
                } else {
                    $('#edit_filter_news').show();
                }
            } else {
                $('.most_commented').show();
                $('.most_like').show();
                $('.most_favorite').show();
                if (row_filter_type == 'custom') {
                    $('#edit_filter_news').hide();
                } else {
                    $('#edit_filter_news').show();
                }
            }
        });

        $(document).on('change', '#edit_filter_type', function(e, row_filter_type, row_news_id) {
            var filter_type = $(this).val();
            var news_type = $('#edit_news_type').val();
            var videos_type = $('#edit_videos_type').val();
            var language_id = $('#edit_language_id').val();

            if (filter_type == 'custom') {
                var data = {
                    language_id: language_id,
                    news_type: news_type,
                    videos_type: videos_type
                };
                $.ajax({
                    url: '{{ route('get_custom_news') }}',
                    type: "POST",
                    data: data,
                    beforeSend: function() {
                        $('#edit_news_ids').html("Please wait..");
                    },
                    success: function(result) {
                        $('#edit_news_ids').html(result);
                        console.log('row_news_id1', row_news_id);
                        console.log('filter_type', filter_type);
                        console.log('row_filter_type', row_filter_type);

                        if (filter_type == row_filter_type) {
                            var valueArray = row_news_id;
                            if (valueArray) {
                                var arrayArea = valueArray.split(',');
                            }
                            console.log('arrayArea', arrayArea);
                            $("#edit_news_ids").val(arrayArea).trigger("change");
                        }
                    },
                    error: function(errors) {
                        console.log(errors);
                    },
                });

            }

            if (news_type == 'news' || news_type == 'videos') {
                if (filter_type == 'custom') {
                    $('#edit_custom').show();
                    $('#edit_filter_news').hide();
                } else {
                    $('#edit_filter_news').show();
                    $('#edit_custom').hide();
                }
            } else {
                if (filter_type == 'custom') {
                    $('#edit_custom').show();
                    $('#edit_filter_news').hide();
                } else {
                    $('#edit_filter_news').hide();
                    $('#edit_custom').hide();
                }
            }
        });

        $('.language_id, .news_type, .videos_type').on('change', function(e) {
            $('.filter_type').prop('selected', false).find('option:first').prop('selected', true);
        });
    </script>
@endsection
