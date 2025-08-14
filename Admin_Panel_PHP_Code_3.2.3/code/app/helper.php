<?php

use App\Models\Language;
use App\Models\Location;
use App\Models\Settings;
use App\Models\Token;
use App\Models\WebSetting;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Factory;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Storage;
use Kreait\Firebase\Messaging\CloudMessage;
use Intervention\Image\Laravel\Facades\Image;

if (!function_exists('get_meta_keyword')) {
    function get_meta_keyword($meta_keyword)
    {
        $meta_keyword1 = '';
        if ($meta_keyword) {
            $meta_keyword1 = implode(
                ',',
                array_map(function ($tag) {
                    return $tag['value'];
                }, $meta_keyword),
            );
        }
        return $meta_keyword1;
    }
}

if (!function_exists('customSlug')) {
    function customSlug($string, $separator = '-')
    {
        // Normalize the string
        $normalizedString = mb_strtolower(trim($string), 'UTF-8');
        // Check if the string contains only ASCII characters
        if (preg_match('/^[\x00-\x7F]*$/', $normalizedString)) {
            $slug = preg_replace('/[^a-z0-9]+/', $separator, $normalizedString);
        } else {
            // slug with remove special characters
            // $slug = preg_replace('/[^\p{L}\p{N}\s]+/u', '', $string);
            // $slug = preg_replace('/\s+/', $separator, $slug);

            //slug with all language
            // $slug = preg_replace('/[^\p{Gujarati}0-9]+/u', '', $normalizedString);

            //remove space from string
            $slug = preg_replace('/\s+/', $separator, $string);
        }
        return $slug;
    }
}

if (!function_exists('getSetting')) {
    function getSetting($type = '')
    {
        $settingList = [];
        if ($type == '') {
            $setting = Settings::get();
        } else {
            $setting = Settings::where('type', $type)->get();
        }
        foreach ($setting as $row) {
            $settingList[$row->type] = $row->message;
        }
        return $settingList;
    }
}

if (!function_exists('getSettingMode')) {
    function getSettingMode($type)
    {
        return Settings::where('type', $type)->pluck('message')->first();
    }
}

if (!function_exists('getWebSetting')) {
    function getWebSetting($type = '')
    {
        $settingList = [];
        if ($type == '') {
            $setting = WebSetting::get();
        } else {
            $setting = WebSetting::where('type', $type)->get();
        }
        foreach ($setting as $row) {
            $settingList[$row->type] = $row->message;
        }
        return $settingList;
    }
}

if (!function_exists('send_notification')) {
    function send_notification($fcmMsg, $language_id, $location_id, $devicetoken = [])
    {
        if (empty($devicetoken)) {
            if ($location_id != 0) {
                $filteredTokens = [];
                $location = Location::where('id', $location_id)->first();
                $news_lat = $location->latitude;
                $news_long = $location->longitude;
                $devicetoken = Token::where('language_id', $language_id)->get();

                foreach ($devicetoken as $value) {
                    $devicetoken1[] = $value->token;
                    $device_lat = $value->latitude; // Latitude of the device
                    $device_long = $value->longitude; // Longitude of the device
                    if (!empty($device_lat)) {
                        $distance = calculateDistance($news_lat, $news_long, $device_lat, $device_long);

                        $nearest_location_measure = Settings::where('type', 'nearest_location_measure')->first();
                        $nearest_location_measure = $nearest_location_measure->message;
                        if ($distance < $nearest_location_measure) {
                            // If the distance is less than 100 km, add the token to the filtered list
                            $filteredTokens[] = $value->token;
                        }
                    }
                }
                $registrationIDs_chunks = array_chunk($filteredTokens, 500);
            } else {
                $devicetoken1 = [];
                $devicetoken = Token::where('language_id', $language_id)->get();
                foreach ($devicetoken as $value) {
                    $devicetoken1[] = $value->token;
                }
                $registrationIDs_chunks = array_chunk($devicetoken1, 500);
            }
        } else {
            $registrationIDs_chunks = array_chunk($devicetoken, 500);
        }

        $firebase_config = public_path('assets/firebase_config.json');
        if (file_exists($firebase_config)) {
            $firebase = (new Factory())->withServiceAccount($firebase_config);
            $messaging = $firebase->createMessaging();
            foreach ($registrationIDs_chunks as $registrationIDs) {
                $message = CloudMessage::new();
                $message = $message->withNotification($fcmMsg)->withData($fcmMsg);
                $report = $messaging->sendMulticast($message, $registrationIDs);
            }
        }
    }
}

if (!function_exists('page_type')) {
    function page_type($type)
    {
        $values = [
            'home' => 'Home',
            'video_news' => 'Video News',
            'personal_notifications' => 'Personal notifications',
            'all_breaking_news' => 'All Breaking News',
            'live_streaming_news' => 'Live streaming news',
            'rss_feeds' => 'RSS Feed'
        ];
        return $values[$type] ?? '';
    }
}

if (!function_exists('is_category_enabled')) {
    function is_category_enabled()
    {
        return Settings::where('type', 'category_mode')->pluck('message')->first();
    }
}

if (!function_exists('is_subcategory_enabled')) {
    function is_subcategory_enabled()
    {
        return Settings::where('type', 'subcategory_mode')->pluck('message')->first();
    }
}

if (!function_exists('is_breaking_news_enabled')) {
    function is_breaking_news_enabled()
    {
        $setting = Settings::where('type', 'breaking_news_mode')->pluck('message')->first();
        return $setting ? $setting : 0;
    }
}

if (!function_exists('is_auto_news_expire_news_enabled')) {
    function is_auto_news_expire_news_enabled()
    {
        $setting = Settings::where('type', 'auto_delete_expire_news_mode')->pluck('message')->first();
        return $setting ? $setting : 0;
    }
}

if (!function_exists('is_live_streaming_enabled')) {
    function is_live_streaming_enabled()
    {
        $setting = Settings::where('type', 'live_streaming_mode')->pluck('message')->first();
        return $setting ? $setting : 0;
    }
}

if (!function_exists('is_location_news_enabled')) {
    function is_location_news_enabled()
    {
        $setting = Settings::where('type', 'location_news_mode')->pluck('message')->first();
        return $setting ? $setting : 0;
    }
}

if (!function_exists('getTimezoneOptions')) {
    function getTimezoneOptions()
    {
        $list = DateTimeZone::listAbbreviations();
        $idents = DateTimeZone::listIdentifiers();
        $data = $offset = $added = [];
        foreach ($list as $info) {
            foreach ($info as $zone) {
                if (!empty($zone['timezone_id']) && !in_array($zone['timezone_id'], $added) && in_array($zone['timezone_id'], $idents)) {
                    $z = new DateTimeZone($zone['timezone_id']);
                    $c = new DateTime(); // Replace $n = '' with $n = null
                    $c->setTimezone($z);
                    $zone['time'] = $c->format('H:i a');
                    $offset[] = $zone['offset'] = $z->getOffset($c);
                    $data[] = $zone;
                    $added[] = $zone['timezone_id'];
                }
            }
        }
        array_multisort($offset, SORT_ASC, $data);
        $options = [];
        foreach ($data as $row) {
            $options[] = [
                'time' => $row['time'],
                'offset' => formatOffset($row['offset']),
                'timezone_id' => $row['timezone_id'],
            ];
        }
        return $options;
    }
}

if (!function_exists('formatOffset')) {
    function formatOffset($offset)
    {
        $hours = floor($offset / 3600);
        $minutes = abs(($offset % 3600) / 60);
        return sprintf('%+d:%02d', $hours, $minutes);
    }
}

if (!function_exists('generateRandomString')) {
    function generateRandomString($length = 10)
    {
        return substr(str_shuffle(str_repeat($x = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', ceil($length / strlen($x)))), 1, $length);
    }
}

if (!function_exists('is_email_setting')) {
    function is_email_setting()
    {
        $builder = new Settings(); // Create an instance of the Settings model
        $email_setting = new \stdClass(); // Create a new stdClass object to store email settings
        // Retrieve and set individual email settings
        $email_setting->SMTPHost = $builder->where('type', 'smtp_host')->first()->message;
        $email_setting->SMTPUser = $builder->where('type', 'smtp_user')->first()->message;
        $email_setting->SMTPPass = $builder->where('type', 'smtp_password')->first()->message;
        $email_setting->SMTPPort = $builder->where('type', 'smtp_port')->first()->message;
        $email_setting->SMTPCrypto = $builder->where('type', 'smtp_crypto')->first()->message;
        $email_setting->fromName = $builder->where('type', 'from_name')->first()->message;
        $email_setting->mailType = 'html';
        return $email_setting;
    }
}

if (!function_exists('createSlug')) {
    function createSlug($text)
    {
        // // Convert the title to lowercase and replace spaces with hyphens
        $slug = str_replace(' ', '-', strtolower($text));
        // Remove special characters
        $slug = preg_replace('/[^A-Za-z0-9\-]/', '', $slug);
        return $slug . '-' . rand(1, 100);
    }
}

if (!function_exists('get_language')) {
    function get_language($status = '')
    {
        if ($status) {
            return Language::where('status', $status)->get();
        } else {
            return Language::get();
        }
    }
}

if (!function_exists('get_default_language')) {
    function get_default_language()
    {
        $language = '';
        $setting = getSetting('default_language');
        if (!empty($setting)) {
            $language = Language::where('id', $setting['default_language'])->first();
        }
        return $language;
    }
}

if (!function_exists('calculateDistance')) {
    function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        // Convert degrees to radians
        $lat1 = deg2rad($lat1);
        $lon1 = deg2rad($lon1);
        $lat2 = deg2rad($lat2);
        $lon2 = deg2rad($lon2);
        // Radius of the Earth in kilometers
        $earthRadius = 6371; // You can also use 3959 for miles
        // Haversine formula
        $dlat = $lat2 - $lat1;
        $dlon = $lon2 - $lon1;
        $a = sin($dlat / 2) * sin($dlat / 2) + cos($lat1) * cos($lat2) * sin($dlon / 2) * sin($dlon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        return $earthRadius * $c;
    }
}

//hideEmailAddress
if (!function_exists('hideEmailAddress')) {
    function hideEmailAddress($email)
    {
        $demo_mode = env('DEMO_MODE');
        if ($demo_mode == true && $email != '') {
            return 'xyz@gmail.com';
        } else {
            return $email;
        }
    }
}

//hideMobileNumber
if (!function_exists('hideMobileNumber')) {
    function hideMobileNumber($mobile)
    {
        $demo_mode = env('DEMO_MODE');
        if ($demo_mode == true && $mobile != '') {
            return '***********';
        } else {
            return $mobile;
        }
    }
}
if (!function_exists('compressAndUpload')) {
function compressAndUpload($requestFile, $folder, $quality = 75) {
    $extension = strtolower($requestFile->getClientOriginalExtension());
    $mime = $requestFile->getMimeType();
    $file_name = uniqid() . '.' . $extension;

    try {
        if ($extension === 'svg' || $mime === 'image/svg+xml') {
            return $requestFile->storeAs($folder, $file_name, 'public');
        }

        if ($extension === 'gif' || $mime === 'image/gif') {
            return $requestFile->storeAs($folder, $file_name, 'public');
        }

        $image = Image::read($requestFile);

        switch ($extension) {
            case 'jpg':
            case 'png':
            case 'jpeg':
                $encoded = $image->toJpeg($quality);
                break;
            case 'webp':
                $encoded = $image->toWebp($quality);
                break;
            default:
                return $requestFile->storeAs($folder, $file_name, 'public');
        }

        Storage::disk('public')->put("$folder/$file_name", $encoded->toString());

    } catch (\Exception $e) {
        return $requestFile->storeAs($folder, $file_name, 'public');
    }

    return "$folder/$file_name";
}
}

if (!function_exists('compressAndReplace')) {
function compressAndReplace($requestFile, $folder, $deleteRawOriginalImage) {
    if (!empty($deleteRawOriginalImage) && Storage::disk('public')->exists($deleteRawOriginalImage)) {
        Storage::disk('public')->delete($deleteRawOriginalImage);
    }
    return compressAndUpload($requestFile, $folder);
}
}
