@extends('layouts.main')

@section('title')
    {{ __('comment_flag') }}
@endsection

@section('content')
    <section class="content-header">
        <div class="container-fluid">
            <div class="row mb-2">
                <div class="col-sm-6">
                    <h1 class="m-0"></h1>
                </div>
                <div class="col-sm-6">
                    <ol class="breadcrumb float-sm-right">
                        <li class="breadcrumb-item text-dark">
                            <a href="{{ route('home') }}" class="text-dark"><i class="fas fa-home mr-1"></i>{{ __('dashboard') }}</a>
                        </li>
                        <li class="breadcrumb-item active"><i class="nav-icon fas fa-flag mr-1"></i>{{ __('comment_flag') }}</li>
                    </ol>
                </div>
            </div>
        </div>
    </section>
    <section class="content">
        @can('comment-flag-list')
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="card card-secondary">
                        <div class="card-header">
                            <h3 class="card-title"> {{ __('comment_flag') }}</h3>
                        </div>
                        <div class="card-body">
                            <table aria-describedby="mydesc" id='table' data-toggle="table" data-url="{{ route('commentsFlagsList') }}" data-click-to-select="true" data-side-pagination="server" data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200]" data-search="true"
                                data-show-columns="true" data-show-refresh="true" data-toolbar="#toolbar" data-mobile-responsive="true" data-buttons-class="primary" data-trim-on-search="false" data-sort-name="id"
                                data-sort-order="desc" data-query-params="queryParams">
                                <thead>
                                    <tr>
                                        <th scope="col" data-field="id" data-sortable="true">{{ __('id') }}</th>
                                        <th scope="col" data-field="comment_id" data-sortable="true">{{ __('comment_id') }}</th>
                                        <th scope="col" data-field="user_id" data-sortable="true" data-visible="false">{{ __('user_id') }}</th>
                                        <th scope="col" data-field="name">{{ __('user') }}</th>
                                        <th scope="col" data-field="news_id" data-sortable="true" data-visible="false">{{ __('news_id') }}</th>
                                        <th scope="col" data-field="title">{{ __('news') }}</th>
                                        <th scope="col" data-field="comment">{{ __('comment') }}</th>
                                        <th scope="col" data-field="message">{{ __('message') }}</th>
                                        @canany(['comment-flag-delete'])
                                        <th scope="col" data-field="operate">{{ __('operate') }}</th>
                                        @endcanany
                                    </tr>
                                </thead>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        @endcan
    </section>
@endsection

@section('script')
    <script type="text/javascript">
        function queryParams(p) {
            return {
                sort: p.sort,
                order: p.order,
                limit: p.limit,
                offset: p.offset,
                search: p.search,
            };
        }
    </script>
@endsection
