<?php

namespace App\Http\Controllers;

use App\Models\Settings;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Validator;
use ZipArchive;

class UpdaterController extends Controller
{
    public function index()
    {
        $setting = getSetting('app_version');
        return view('system-updater', compact('setting'));
    }

    public function system_update(Request $request)
    {
        $destinationPath = public_path() . '/update/tmp/';

        $validator = Validator::make($request->all(), [
            'purchase_code' => 'required',
            'file' => 'required|file|mimes:zip,rar',
        ]);
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }

        $app_url = (string) url('/');
        $app_url = preg_replace('#^https?://#i', '', $app_url).'/';
        $curl = curl_init();
        curl_setopt_array($curl, [
            CURLOPT_URL => 'https://validator.wrteam.in/news_app_validator?purchase_code=' . $request->purchase_code . '&domain_url=' . $app_url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
            CURLOPT_CUSTOMREQUEST => 'GET',
        ]);
        $response = curl_exec($curl);
        if ($response) {
            curl_close($curl);
            $response = json_decode($response, true);
            if ($response['error'] == false) {
                if (!is_dir($destinationPath)) {
                    mkdir($destinationPath, 0777, true);
                }
                // zip upload
                $zipfile = $request->file('file');
                $fileName = $zipfile->getClientOriginalName();
                $zipfile->move($destinationPath, $fileName);
                $target_path = base_path(). DIRECTORY_SEPARATOR;

                $zip = new ZipArchive();
                $filePath = $destinationPath . '/' . $fileName;
                $zipStatus = $zip->open($filePath);
                if ($zipStatus) {
                    $zip->extractTo($destinationPath);
                    $zip->close();
                    unlink($filePath);

                    $ver_file = $destinationPath . 'version_info.php';
                    $source_path = $destinationPath . 'source_code.zip';
                    if (file_exists($ver_file) && file_exists($source_path)) {
                        $ver_file1 = $target_path . 'version_info.php';
                        $source_path1 = $target_path . 'source_code.zip';
                        if (rename($ver_file, $ver_file1) && rename($source_path, $source_path1)) {
                            $version_file = require_once $ver_file1;
                            $settings = getSetting('app_version');
                            $current_version = $settings['app_version'];
                            if ($current_version == $version_file['current_version']) {
                                $zip1 = new ZipArchive();
                                $zipFile1 = $zip1->open($source_path1);
                                if ($zipFile1 === true) {
                                    $zip1->extractTo($target_path); // change this to the correct site path
                                    $zip1->close();
                                    Artisan::call('optimize:clear');
                                    Artisan::call('migrate', ['--force' => true]);
                                    if (File::exists($destinationPath)) {
                                        File::deleteDirectory($destinationPath);
                                    }
                                    Settings::where('type', 'app_version')->update([
                                        'message' => $version_file['update_version'],
                                    ]);

                                    $response = [
                                        'error' => false,
                                        'message' => __('updated_success'),
                                    ];
                                } else {
                                    if (File::exists($destinationPath)) {
                                        File::deleteDirectory($destinationPath);
                                    }
                                    $response = [
                                        'error' => true,
                                        'message' => __('something_wrong_try_again'),
                                    ];
                                }
                            } elseif ($current_version == $version_file['update_version']) {
                                if (File::exists($destinationPath)) {
                                    File::deleteDirectory($destinationPath);
                                }
                                $response = [
                                    'error' => true,
                                    'message' => __('system_already_updated'),
                                ];
                            } else {
                                if (File::exists($destinationPath)) {
                                    File::deleteDirectory($destinationPath);
                                }
                                $message = $current_version . ' ' . __('update_nearest_version');
                                $response = [
                                    'error' => true,
                                    'message' => $message,
                                ];
                            }
                        } else {
                            if (File::exists($destinationPath)) {
                                File::deleteDirectory($destinationPath);
                            }
                            $response = [
                                'error' => true,
                                'message' => __('invalid_zip'),
                            ];
                        }
                    } else {
                        if (File::exists($destinationPath)) {
                            File::deleteDirectory($destinationPath);
                        }
                        $response = [
                            'error' => true,
                            'message' => __('invalid_zip'),
                        ];
                    }
                } else {
                    if (File::exists($destinationPath)) {
                        File::deleteDirectory($destinationPath);
                    }
                    $response = [
                        'error' => true,
                        'message' => __('something_wrong_try_again'),
                    ];
                }
            } else {
                $response = [
                    'error' => true,
                    'message' => $response['message'],
                ];
            }
        } else {
            $response = [
                'error' => true,
                'message' => __('something_wrong'),
                'errors' => curl_error($curl),
            ];
            curl_close($curl);
        }
        return response()->json($response);
    }
}
