<?php

namespace App\Http\Controllers;

use App\Models\Language;
use App\Models\Settings;
use App\Services\ResponseService;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Storage;

class LanguageController extends Controller
{
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['language-list', 'language-create', 'language-edit', 'language-delete']);
        try {
            return view('language');
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }
    }

    public function downloadPanelJson(Request $request)
    {
        $langFile = $request->lang . '.json';
        $file = base_path('resources/lang/') . $langFile;
        $filename = 'panel-' . $langFile;
        return Response::download($file, $filename, [
            'Content-Type' => 'application/json',
        ]);
    }

    public function downloadAppWebJson(Request $request)
    {
        $langFile = $request->lang . '.json';
        $file = storage_path('app/public/language/') . $langFile;
        return Response::download($file, $langFile, [
            'Content-Type' => 'application/json',
        ]);
    }

    public function set_language(Request $request)
    {
        Session::put('locale', $request->lang);
        $language = Language::where('code', $request->lang)->first();
        Session::put('language_name', $language->language);
        // Session::put('language', $language);
        // Session::put('isRTL', $language->isRTL);
        Session::save();
        app()->setLocale(Session::get('locale'));
        return redirect()->back();
    }

    public function show(Request $request)
    {
        ResponseService::noPermissionThenRedirect('language-list');
        $default_lang = getSetting('default_language');
        $default_lang_value = $default_lang['default_language'];

        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'status');
        $order = $request->input('order', 'DESC');

        $sql = Language::orderBy($sort, $order);
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            if (!empty($search)) {
                $sql->where('id', 'LIKE', "%{$search}%")
                    ->orWhere('language', 'LIKE', "%{$search}%")
                    ->orWhere('code', 'LIKE', "%{$search}%")
                    ->orWhere('language', 'LIKE', "%{$search}%");
            }
        }
        $total = $sql->count('id');
        $sql = $sql->skip($offset)->take($limit);
        $rows = $sql->get()->map(function ($row) use ($default_lang_value) {
            $edit = '';
            if (auth()->user()->can('language-edit')) {
                $edit = '<a class="dropdown-item edit-data" data-toggle="modal" data-target="#editDataModal" title="' . __('edit') . '"><i class="fa fa-pen mr-1 text-primary"></i>' . __('edit') . '</a>';
            }
            $delete = '';
            if (auth()->user()->can('language-delete')) {
                if ($default_lang_value != $row->id) {
                    $delete = '<a data-url="' . url('language', $row->id) . '" class="dropdown-item delete-form" data-id="' . $row->id . '" title="' . __('delete') . '"><i class="fa fa-trash mr-1 text-danger"></i>' . __('delete') . '</a>';
                }
            }
            $operate = '';
            if ($edit == '' && $delete == '') {
                $operate = '-';
            } else {
                $operate =
                '<div class="dropdown">
                            <a href="javascript:void(0)" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                <button class="btn btn-primary btn-sm px-3"><i class="fas fa-ellipsis-v"></i></button>
                            </a>
                            <div class="dropdown-menu dropdown-scrollbar" aria-labelledby="dropdownMenuButton">
                            ' .
                $edit .
                $delete .
                '
                            </div>
                        </div>';
            }

            if ($default_lang_value == $row->id) {
                $default = '<span class="badge badge-secondary"><em class="fa fa-check"></em> Default</span>';
            } elseif ($row->status == 1) {
                $default = '<a class="btn btn-icon btn-sm btn-info text-white store_default_language" data-id="' . $row->id . '"><em class="fa fa-ellipsis-h"></em> Set as Default</a>';
            } else {
                $default = '<a class="btn btn-icon btn-sm btn-info text-white store_default_language disabled" data-id="' . $row->id . '"><em class="fa fa-ellipsis-h"></em> Set as Default</a>';
            }

            return [
                'id' => $row->id,
                'language' => $row->language,
                'display_name' => $row->display_name ?? '',
                'code' => $row->code,
                'isRTL' => $row->isRTL == 1 ? '<span class="badge badge-success">Yes</span>' : '<span class="badge badge-danger">No</span>',
                'image' => !empty($row->image) ? '<a href=' . $row->image . '  data-toggle="lightbox" data-title="Image"><img src=' . $row->image . ' height=50, width=50 >' : '-',
                'default1' => $default,
                'is_default' => $default_lang_value == $row->id ? 1 : 0,
                'isRtl_value' => $row->isRTL,
                'status' => $row->status,
                'status1' => $row->status == 1 ? '<span class="badge badge-success">' . __('active') . '</span>' : '<span class="badge badge-danger">' . __('deactive') . '</span>',
                'app_web_json' => '<a class="btn btn-sm btn-info" href="' . url('download-app-web-json') . '/' . $row->code . '"><i class="fa fa-download"></i></a>',
                'panel_json' => '<a class="btn btn-sm btn-info" href="' . url('download-panel-json') . '/' . $row->code . '"><i class="fa fa-download"></i></a>',
                'operate' => $operate,
            ];
        });

        return response()->json([
            'total' => $total,
            'rows' => $rows,
        ]);
    }

    public function store(Request $request)
    {
        ResponseService::noPermissionThenRedirect('language-create');
        $request->validate(
            [
                'language' => 'required',
                'code' => 'required|unique:tbl_languages',
            ],
            [
                'code.unique' => __('language_code_unique'), //Code already exists.
            ],
        );

        $image = '';
        if ($request->hasFile('flag')) {
            $image = compressAndUpload($request->file('flag'), 'flags');
        }

        $language_code = $request->code;

        Language::create([
            'language' => $request->language,
            'code' => $language_code,
            'status' => 1,
            'isRTL' => $request->is_rtl_switch === 'on' ? 1 : 0,
            'image' => $image,
            'display_name' => $request->display_name ?? '',
        ]);

        if ($request->hasFile('file')) {
            $file = $request->file('file');
            $filename = $language_code . '.' . $file->getClientOriginalExtension();
            $file->storeAs('language', $filename, 'public');
        }
        if ($request->hasFile('admin_json')) {
            $file1 = $request->file('admin_json');
            $filename1 = $language_code . '.' . $file1->getClientOriginalExtension();
            $file1->move(resource_path('lang/'), $filename1);
        }

        $response = [
            'error' => false,
            'message' => __('created_success'),
        ];
        return response()->json($response);
    }

    public function update(Request $request)
    {
        ResponseService::noPermissionThenRedirect('language-edit');
        $request->validate(
            [
                'language' => 'required',
                'code' => 'required|unique:tbl_languages,code,' . $request->edit_id . ',id',
            ],
            [
                'code.unique' => __('language_code_unique'), //Code already exists.
            ],
        );

        $language = Language::find($request->edit_id);
        $language->language = $request->language;
        $language->display_name = $request->display_name;
        $language->code = $request->code;
        $language->isRTL = $request->is_rtl_switch === 'on' ? 1 : 0;
        if ($request->hasFile('flag')) {
            $language->image = compressAndReplace($request->file('flag'), 'flags', $language->getRawOriginal('image'));
        }
        $language->status = $request->status;
        $language->save();

        if ($request->hasFile('file')) {
            $uploadedFile = $request->file('file');
            $filename = $request->code . '.' . $uploadedFile->getClientOriginalExtension();
            $uploadedFile->storeAs('language', $filename, 'public');
        }

        if ($request->hasFile('edit_json_admin')) {
            $file = $request->file('edit_json_admin');
            $filename = $request->code . '.' . $file->getClientOriginalExtension();
            if ($file->getClientOriginalExtension() != 'json') {
                return back()->with('error', 'Invalid File Type');
            }
            if (file_exists(resource_path('lang/') . $filename)) {
                File::delete(resource_path('lang/'), $filename);
            }
            $file->move(resource_path('lang/'), $filename);
        }

        return response()->json([
            'error' => false,
            'message' => __('updated_success'),
        ]);
    }

    public function destroy(string $id)
    {
        ResponseService::noPermissionThenRedirect('language-delete');
        $language = Language::find($id);
        if ($language->code != 'en') {
            $filename = $language->code . '.json';
            $filePath = resource_path('lang/') . $filename;
            if (file_exists($filePath)) {
                File::delete($filePath);
            }
            if (Storage::disk('public')->exists('language/' . $filename)) {
                Storage::disk('public')->delete('language/' . $filename);
            }
        }
        $language->delete();
        $response = [
            'error' => false,
            'message' => __('deleted_success'),
        ];
        return response()->json($response);
    }

    public function store_default_language(Request $request)
    {
        $setting = getSetting('default_language');
        if (empty($setting)) {
            $setting = new Settings();
            $setting->type = 'default_language';
            $setting->message = $request->id;
            session()->forget('locale');
            session()->forget('language_name');
            $setting->save();
        } else {
            $setting = Settings::where('type', 'default_language')->first();
            $setting->message = $request->id;
            session()->forget('locale');
            session()->forget('language_name');
            $setting->save();
        }
        // $language = get_default_language();
        // if ($language) {
        //     Session::put('locale', $request->code);
        //     Session::put('language_name', $language->language);
        //     // Session::put('language', $language);
        //     Session::save();
        //     app()->setLocale(Session::get('locale'));
        // }
        $response = [
            'error' => false,
            'message' => __('updated_success'),
        ];
        return response()->json($response);
    }
}
