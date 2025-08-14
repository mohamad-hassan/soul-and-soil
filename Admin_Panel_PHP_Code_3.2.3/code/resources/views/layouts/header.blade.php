<nav class="main-header navbar navbar-expand navbar-white navbar-light">
    <style>
        @media (max-width: 425px) {
            .navbar .nav-link {
                padding: 0.3rem 0.5rem !important;
            }
            .navbar .user-image {
                max-width: 25px;
                max-height: 25px;
            }
        }
        @media (max-width: 320px) {
            .navbar .nav-link {
                padding: 0.2rem 0.3rem !important;
                width: min-content;
            }
            .navbar .user-image {
                max-width: 10px;
                max-height: 10px;
            }
            .user-image {
                display: none;
            }
        }
    </style>
    <!-- Left navbar links -->
    <ul class="navbar-nav">
        <li class="nav-item">
            <a class="nav-link" data-widget="pushmenu" href="javascript:void(0)" role="button"><i class="fas fa-bars text-dark"></i></a>
        </li>
        <li class="nav-item my-auto ml-2">
            <span class="badge" style="border-radius: 8px!important;padding:8px; color:{{ $setting['primary_color'] }};border:1px solid {{ $setting['primary_color'] }}">{{ $setting['app_version'] }}</span>
        </li>
        @if (env('DEMO_MODE'))
            <li class="nav-item my-auto ml-2">
                <span class="badge badge-danger" style="border-radius: 8px!important;padding:8px">Demo mode</span>
            </li>
        @endif
    </ul>
    @php
        $setting = getSetting();
    @endphp

    <!-- Right navbar links -->
    <ul class="navbar-nav ml-auto">

        <li class="nav-item dropdown user-menu">
            <div class="row">
                <label class="current_language">
                    {{ empty(session('language_name')) ? 'English' : session('language_name') }}
                </label>
                <div class="dropdown navbar_dropdown mr-2">
                    <a href="javascript:void(0)" class="nav-link dropdown-toggle text-white" data-toggle="dropdown">
                        <i class="fas fa-language text-white mt-2"></i>
                    </a>
                    <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right" id="languageDropdown" aria-labelledby="languageDropdown">
                        <div class="scrollable-menu">
                            @foreach (get_language(1) as $key => $language)
                                <a class="dropdown-item" href="{{ url('set-language') . '/' . $language->code }}">
                                    {{ $language->language }}
                                </a>
                            @endforeach
                        </div>
                    </div>
                </div>

                <div class="dropdown navbar_dropdown mr-1">
                    <a href="javascript:void(0)" class="nav-link dropdown-toggle text-white" data-toggle="dropdown">
                        @if (Auth::user()->image)
                            <img src="{{ url(Storage::url(Auth::user()->image)) }}" class="user-image img-circle elevation-2" alt="image">
                        @endif
                        Hi, {{ Auth::user()->username }}
                    </a>
                    <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right">
                        <a href="{{ route('edit-profile') }}" class="dropdown-item">
                            <em class="fas fa-user mr-2"></em> {{ __('edit') . ' ' . __('profile') }}
                        </a>
                        <div class="dropdown-divider"></div>
                        <a href="{{ url('logout') }}" class="dropdown-item">
                            <em class="fas fa-power-off mr-2"></em> {{ __('logout') }}
                        </a>
                    </div>
                </div>
            </div>
        </li>
    </ul>
</nav>
<!-- /.navbar -->
