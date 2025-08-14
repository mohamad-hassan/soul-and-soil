<?php

namespace App\Http\Controllers;

use App\Models\Language;
use App\Models\Pages;
use App\Models\Settings;
use App\Models\WebSetting;
use App\Services\ResponseService;
use dacoto\EnvSet\Facades\EnvSet;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Log;
class SettingsController extends Controller
{
    public function view_data(Request $request)
    {
        $default_language = Settings::where('type', 'default_language')->value('message');
        if (empty($default_language)) {
            $language_data = Language::where('code', 'en')->first();
        } else {
            $language_data = Language::find($default_language);
        }
        $get_data = [];
        $type = $request->type;
        if ($language_data) {
            $get_data = Pages::where('language_id', $language_data->id)->where('status', 1)->where('page_type', $type)->first();
        }
        if (empty($get_data)) {
            $get_data = Pages::where('page_type', $type)->first();
        }
        return view('settings', compact('get_data'));
    }

    public function indexSetting()
    {
        ResponseService::noAnyPermissionThenRedirect(['general-settings',
            'panel-settings',
            'web-settings',
            'app-settings',
            'language-list',
            'language-create',
            'language-edit',
            'language-delete',
            'seo-list',
            'seo-create',
            'seo-edit',
            'seo-delete',
            'firebase-configuration',
            'social-media-list',
            'social-media-create',
            'social-media-edit',
            'social-media-delete',
            'system-update',]);
        return view('system-setting');
    }

    public function indexGeneralSetting()
    {
        ResponseService::noAnyPermissionThenRedirect(['general-settings']);
        $settings = [
            'category_mode',
            'subcategory_mode',
            'breaking_news_mode',
            'live_streaming_mode',
            'rss_feed_mode',
            'comments_mode',
            'weather_mode',
            'location_news_mode',
            'nearest_location_measure',
            'maintenance_mode',
            'mobile_login_mode',
            'country_code',
            'views_auth_mode'
        ];
        $setting = Settings::whereIn('type', $settings)->get()->pluck('message', 'type');
        $setting['android_app_link'] = WebSetting::where('type', 'android_app_link')->pluck('message')->first();
        $setting['ios_app_link'] = WebSetting::where('type', 'ios_app_link')->pluck('message')->first();
        return view('general-setting', compact('setting'));
    }

    public function storeGeneralSetting(Request $request)
    {
        ResponseService::noPermissionThenRedirect('general-settings');
        $settings = [
            'category_mode',
            'subcategory_mode',
            'breaking_news_mode',
            'live_streaming_mode',
            'rss_feed_mode',
            'comments_mode',
            'weather_mode',
            'location_news_mode',
            'nearest_location_measure',
            'maintenance_mode',
            'mobile_login_mode',
            'country_code',
            'views_auth_mode'
        ];
        foreach ($settings as $type) {
            $message = $request->input($type);
            $setting = Settings::where('type', $type)->first();
            if ($setting) {
                $setting->message = $message;
                $setting->save();
            } else {
                $setting = new Settings();
                $setting->type = $type;
                $setting->message = $message;
                $setting->save();
            }
        }

        $webSetting = ['android_app_link', 'ios_app_link'];
        foreach ($webSetting as $type) {
            $message = $request->input($type);
            $setting = WebSetting::firstOrNew(['type' => $type]);
            $setting->message = $message;
            $setting->save();
        }

        $fileTypes = ['assetlinks_file', 'association_file'];
        foreach ($fileTypes as $fileType) {
            if ($request->hasFile($fileType)) {
                $file = $request->file($fileType);

                $filenameMap = [
                    'assetlinks_file' => 'assetlinks.json',
                    'association_file' => 'apple-app-site-association',
                ];

                $filename = $filenameMap[$fileType];
                $fileContents = File::get($file);
                $publicWellKnownPath = public_path('.well-known');
                if (!File::exists($publicWellKnownPath)) {
                    File::makeDirectory($publicWellKnownPath, 0755, true);
                }
                $baseWellKnownPath = base_path('.well-known');
                if (!File::exists($baseWellKnownPath)) {
                    File::makeDirectory($baseWellKnownPath, 0755, true);
                }
                $publicPath = public_path('.well-known/' . $filename);
                File::put($publicPath, $fileContents);

                $rootPath = base_path('.well-known/' . $filename);
                File::put($rootPath, $fileContents);
            }
        }
        return redirect('general-settings')->with('success', __('updated_success'));
    }

    public function importDummyData()
    {
        try {
            Artisan::call('db:seed', [
                '--class' => 'DummyDataSeeder',
                '--force' => true
            ]);

            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            Log::error($e->getMessage());
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function createStorageLink()
    {
        try {
            if (!file_exists(public_path('storage'))) {
                Artisan::call('storage:link');
            }
            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function removeStorageLink()
    {
        try {
            if (file_exists(public_path('storage'))) {
                File::delete(public_path('storage'));
            }
            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }

    public function indexPanelSetting()
    {
        ResponseService::noAnyPermissionThenRedirect(['panel-settings']);
        $settings = [
            'system_timezone',
            'app_name',
            'auto_delete_expire_news_mode',
            'smtp_host',
            'smtp_user',
            'smtp_password',
            'smtp_port',
            'smtp_crypto',
            'from_name',
            'primary_color',
            'secondary_color',
            'app_logo_full',
            'app_logo'
        ];
        $setting = Settings::whereIn('type', $settings)->get()->pluck('message', 'type');
        return view('panel-setting', compact('setting'));
    }

    public function storePanelSetting(Request $request)
    {
        ResponseService::noPermissionThenRedirect('panel-settings');
        $settings = [
            'system_timezone',
            'app_name',
            'auto_delete_expire_news_mode',
            'smtp_host',
            'smtp_user',
            'smtp_password',
            'smtp_port',
            'smtp_crypto',
            'from_name',
            'primary_color',
            'secondary_color'
        ];

        if ($request->hasFile('file1')) {
            $image_full = $request->file('file1');
            if ($image_full->isValid()) {
                $previousFileName = Settings::where('type', 'app_logo_full')->value('message');
                if ($previousFileName) {
                    $setting = Settings::where('type', 'app_logo_full')->first();
                    Storage::disk('public')->delete($setting->getRawOriginal('message'));
                }
                $setting = Settings::where('type', 'app_logo_full')->first();
                if ($setting) {
                    $setting->message = $request->file('file1')->store('logos', 'public');
                    $setting->save();
                }
            }
        }
        if ($request->hasFile('file')) {
            $image = $request->file('file');
            if ($image->isValid()) {
                $previousFileName = Settings::where('type', 'app_logo')->value('message');
                if ($previousFileName) {
                    $setting = Settings::where('type', 'app_logo')->first();
                    Storage::disk('public')->delete($setting->getRawOriginal('message'));
                }
                $setting = Settings::where('type', 'app_logo')->first();
                if ($setting) {
                    $setting->message = $request->file('file')->store('logos', 'public');
                    $setting->save();
                }
            }
        }
        foreach ($settings as $type) {
            $message = $request->input($type);
            if ($type == 'smtp_host') {
                EnvSet::setKey('MAIL_HOST', $message);
                EnvSet::save();
            }
            if ($type == 'smtp_port') {
                EnvSet::setKey('MAIL_PORT', $message);
                EnvSet::save();
            }
            if ($type == 'smtp_user') {
                EnvSet::setKey('MAIL_USERNAME', $message);
                EnvSet::save();
            }
            if ($type == 'smtp_password') {
                EnvSet::setKey('MAIL_PASSWORD', $message);
                EnvSet::save();
            }
            if ($type == 'smtp_crypto') {
                EnvSet::setKey('MAIL_ENCRYPTION', $message);
                EnvSet::save();
            }
            if ($type == 'app_name') {
                EnvSet::setKey('APP_NAME', $message);
                EnvSet::save();
            }
            if ($type == 'system_timezone') {
                $key = 'APP_TIMEZONE';
                // Check if the key already exists in the .env file
                if (!EnvSet::keyExists($key)) {
                    // If key does not exist, append it to the end of the .env file
                    $envFilePath = base_path('.env');
                    File::append($envFilePath, "{$key}={$message}\n");
                } else {
                    // If key exists, update its value
                    EnvSet::setKey($key, $message);
                    EnvSet::save();
                }
            }
            $setting = Settings::where('type', $type)->first();
            if ($message) {
                if ($setting) {
                    $setting->message = $message;
                    $setting->save();
                } else {
                    $setting = new Settings();
                    $setting->type = $type;
                    $setting->message = $message;
                    $setting->save();
                }
            }
        }
        return redirect('panel-settings')->with('success', __('updated_success'));
    }

    public function indexWebSetting()
    {
        ResponseService::noAnyPermissionThenRedirect(['web-settings']);
        $setting = getWebSetting();
        return view('web-setting', compact('setting'));
    }

    public function storeWebSetting(Request $request)
    {
        ResponseService::noPermissionThenRedirect('web-settings');
        $settings = [
            'web_name',
            'accept_cookie',
            'web_footer_description',
            'google_adsense',
            'light_body_color',
            'light_hover_color',
            'light_primary_color',
            'light_secondary_color',
            'light_text_primary_color',
            'light_text_secondary_color',
            'dark_body_color',
            'dark_hover_color',
            'dark_primary_color',
            'dark_secondary_color',
            'dark_text_primary_color',
            'dark_text_secondary_color'
        ];

        $fileTypes = [
            'light_header_logo',
            'light_footer_logo',
            'light_placeholder_image',
            'dark_header_logo',
            'dark_footer_logo',
            'dark_placeholder_image',
            'favicon_icon'
        ];

        foreach ($fileTypes as $fileType) {
            if ($request->hasFile($fileType)) {
                $file = $request->file($fileType);
                if ($file->isValid()) {
                    $setting = WebSetting::firstOrNew(['type' => $fileType]);
                    $previousFileName = $setting->getRawOriginal('message');
                    if ($previousFileName) {
                        Storage::disk('public')->delete($previousFileName);
                    }
                    $setting->message = $file->store('logos', 'public');
                    $setting->save();
                }
            }
        }

        foreach ($settings as $type) {
            $message = $request->input($type);
            $setting = WebSetting::firstOrNew(['type' => $type]);
            $setting->message = $message;
            $setting->save();
        }
        return redirect('web-settings')->with('success', __('updated_success'));
    }

    public function indexAppSetting()
    {
        ResponseService::noAnyPermissionThenRedirect(['app-settings']);
        $settings = [
            'appstore_app_id',
            'shareapp_text',
            'video_type_preference',
            'ads_type',
            'in_app_ads_mode',
            'google_rewarded_video_id',
            'google_interstitial_id',
            'google_banner_id',
            'google_native_unit_id',
            'ios_ads_type',
            'ios_in_app_ads_mode',
            'ios_google_rewarded_video_id',
            'ios_google_interstitial_id',
            'ios_google_banner_id',
            'ios_google_native_unit_id',
            'unity_rewarded_video_id',
            'unity_interstitial_id',
            'unity_banner_id',
            'android_game_id',
            'ios_unity_rewarded_video_id',
            'ios_unity_interstitial_id',
            'ios_unity_banner_id',
            'ios_game_id',
            'force_update_app_mode',
            'android_app_version',
            'ios_app_version'
        ];
        $setting = Settings::whereIn('type', $settings)->get()->pluck('message', 'type');
        return view('app-setting', compact('setting'));
    }

    public function storeAppSetting(Request $request)
    {
        ResponseService::noPermissionThenRedirect('app-settings');

        // Validate version format (numbers and dots only)
        $request->validate([
            'android_app_version' => [
                'required',
                'regex:/^[0-9]+(\.[0-9]+)*$/',
            ],
            'ios_app_version' => [
                'required',
                'regex:/^[0-9]+(\.[0-9]+)*$/',
            ],
        ], [
            'android_app_version.regex' => 'Android app version must be in format like 1.0.0 (numbers and dots only)',
            'ios_app_version.regex' => 'iOS app version must be in format like 1.0.0 (numbers and dots only)',
        ]);
        $settings = [
            'appstore_app_id',
            'shareapp_text',
            'video_type_preference',
            'ads_type',
            'in_app_ads_mode',
            'google_rewarded_video_id',
            'google_interstitial_id',
            'google_banner_id',
            'google_native_unit_id',
            'ios_ads_type',
            'ios_in_app_ads_mode',
            'ios_google_rewarded_video_id',
            'ios_google_interstitial_id',
            'ios_google_banner_id',
            'ios_google_native_unit_id',
            'unity_rewarded_video_id',
            'unity_interstitial_id',
            'unity_banner_id',
            'android_game_id',
            'ios_unity_rewarded_video_id',
            'ios_unity_interstitial_id',
            'ios_unity_banner_id',
            'ios_game_id',
            'force_update_app_mode',
            'android_app_version',
            'ios_app_version'
        ];
        foreach ($settings as $type) {
            $message = $request->input($type);
            $setting = Settings::where('type', $type)->first();
            if ($setting) {
                $setting->message = $message;
                $setting->save();
            } else {
                $setting = new Settings();
                $setting->type = $type;
                $setting->message = $message;
                $setting->save();
            }
        }

        //upload ads file
        if ($request->hasFile('ads_file')) {
            $filename = 'app-ads.txt';
            $file = $request->file('ads_file');
            $fileContents = File::get($file);
            $publicWellKnownPath = public_path('.well-known');
            if (!File::exists($publicWellKnownPath)) {
                File::makeDirectory($publicWellKnownPath, 0755, true);
            }
            $baseWellKnownPath = base_path('.well-known');
            if (!File::exists($baseWellKnownPath)) {
                File::makeDirectory($baseWellKnownPath, 0755, true);
            }

            $publicPath = public_path('.well-known/' . $filename);
            File::put($publicPath, $fileContents);

            $rootPath = base_path('.well-known/' . $filename);
            File::put($rootPath, $fileContents);
        }
        return redirect('app-settings')->with('success', __('updated_success'));
    }

    public function indexFirebaseSetting()
    {
        ResponseService::noAnyPermissionThenRedirect(['firebase-configuration']);
        $firebase_config = public_path('assets/firebase_config.json');
        if (file_exists($firebase_config)) {
            $is_file = 1;
        } else {
            $is_file = 0;
        }
        return view('firebase-configuration', compact('is_file'));
    }

    public function storeFirebaseSetting(Request $request)
    {
        ResponseService::noPermissionThenRedirect('firebase-configuration');
        $validator = Validator::make($request->all(), [
            'file' => ['required', 'file', 'mimetypes:application/json'],
        ]);
        if ($validator->fails()) {
            return redirect('firebase-configuration')->with('error', $validator->errors()->first());
        }

        $old_file = public_path() . 'assets/firebase_config.json';
        if (file_exists($old_file)) {
            unlink($old_file);
        }
        if ($request->hasFile('file')) {
            $file1 = $request->file('file');
            $filename1 = 'firebase_config.' . $file1->getClientOriginalExtension();
            $file1->move(public_path('assets/'), $filename1);
        }

        return redirect('firebase-configuration')->with('success', __('updated_success'));
    }
}
