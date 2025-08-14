<?php

namespace App\Http\Controllers;

use App\Models\Language;
use App\Models\Pages;
use App\Services\ResponseService;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class PagesController extends Controller
{
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['page-list', 'page-create', 'page-edit', 'page-delete']);
        try {
            $languageList = Language::where('status', 1)->get();
            return view('pages', compact('languageList'));
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }
    }

    public function show(Request $request)
    {
        ResponseService::noPermissionThenRedirect('page-list');
        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'id');
        $order = $request->input('order', 'DESC');

        $sql = Pages::with('language:id,language')->orderBy($sort, $order);
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            $sql = $sql->where(function ($q) use ($search) {
                $q->where('id', 'LIKE', "%{$search}%")
                    ->orWhere('title', 'LIKE', "%{$search}%")
                    ->orWhere('slug', 'LIKE', "%{$search}%");
            });
        }
        if ($request->has('language_id') && $request->language_id) {
            $sql = $sql->where('language_id', $request->language_id);
        }
        if ($request->has('status') && $request->status != '') {
            $sql->where('status', $request->status);
        }
        if ($request->has('page_type') && $request->page_type != '') {
            $sql->where('page_type', $request->page_type);
        }
        // if ($request->policy_type != '') {
        //     $policy_type = $request->policy_type;
        //     if ($policy_type == 'terms_policy') {
        //         $sql = $sql->where('is_termspolicy', 1);
        //     }
        //     if ($policy_type == 'privacy_policy') {
        //         $sql = $sql->where('is_privacypolicy', 1);
        //     }
        // }
        $total = $sql->count('id');
        $sql = $sql->skip($offset)->take($limit);
        $rows = $sql->get()->map(function ($row) {
            $edit = '';
            if (auth()->user()->can('page-edit')) {
                $edit = '<a class="dropdown-item edit-data" data-toggle="modal" data-target="#editDataModal" title="' . __('edit') . '"><i class="fa fa-pen mr-1 text-primary"></i>' . __('edit') . '</a>';
            }
            if(!in_array($row->id, [1, 2, 3, 4])){
                $delete = '';
                if (auth()->user()->can('page-delete')) {
                    $delete = '<a data-url="' . url('pages', $row->id) . '" class="dropdown-item delete-form" data-id="' . $row->id . '" title="' . __('delete') . '"><i class="fa fa-trash mr-1 text-danger"></i>' . __('delete') . '</a>';
                }
                $readonly = false;
            } else {
                $delete = '';
                if (auth()->user()->can('page-edit')) {
                    $delete = '<a href="'.url('settings') .'/'. $row->slug .'" target="_blank" class="dropdown-item"><i class="fa fa-link mr-1 text-danger" title="' . __('generate_link') . '"></i>'.__('generate_link').'</a>';
                }
                $readonly = true;
            }
            $operate = '';
            if (auth()->user()->can('page-edit') || auth()->user()->can('page-delete')) {  
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
            json_decode($row->meta_keywords);
            if (json_last_error() === JSON_ERROR_NONE) {
                $meta_keyword = json_decode($row->meta_keywords);
            } else {
                $meta_keyword = $row->meta_keywords;
            }
            return [
                'readonly' => $readonly,
                'id' => $row->id,
                'language_id' => $row->language_id,
                'language' => $row->language->language ?? '',
                'title' => $row->title,
                'slug' => $row->slug,
                'page_type' => $row->page_type,
                'page_content' => $row->page_content,
                'schema_markup' => $row->schema_markup,
                'meta_title' => $row->meta_title,
                'meta_description' => $row->meta_description,
                'meta_keyword' => $meta_keyword,
                'status' => $row->status,
                'status1' => $row->status == '1' ? '<div class="badge badge-success">' . __('active') . '</div>' : '<div class="badge badge-danger">' . __('deactive') . '</div>',
                'image' => !empty($row->page_icon) ? '<a href="' . $row->page_icon . '" data-toggle="lightbox" data-title="Image"><img class="images_border" src="' . $row->page_icon . '" height="50" width="50"></a>' : '-',
                'og_image' => !empty($row->og_image) ? '<a href="' . $row->og_image . '" data-toggle="lightbox" data-title="Image"><img class="images_border" src="' . $row->og_image . '" height="50" width="50"></a>' : '-',
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
        ResponseService::noPermissionThenRedirect('page-create');
        $validator = Validator::make($request->all(), [
            'language' => ['required'],
            'title' => ['required'],
            'page_type' => ['required'],
            'slug' => ['required'],
            'page_content' => ['required'],
        ]);
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }

        $language_id = $request->language;
        $page_type = $request->page_type;

        if ($page_type != 'custom') {
            $slug = $request->slug;
            $existingSlug = Pages::where('language_id', $language_id)->where('page_type', $page_type)->exists();
            if ($existingSlug) {
                $response = [
                    'error' => true,
                    'message' => __('page_already_exists'),
                ];
                return response()->json($response);
            }
        } else {
            $slug = customSlug($request->slug);
            $existingSlug = Pages::where('language_id', $language_id)->where('slug', $slug)->exists();
            if ($existingSlug) {
                $response = [
                    'error' => true,
                    'message' => __('slug_already_use'),
                ];
                return response()->json($response);
            }
        }

        $page_icon = '';
        if ($request->hasFile('file')) {
            $page_icon = compressAndUpload($request->file('file'), 'pages');
        }
        $og_image = '';
        if ($request->hasFile('og_file')) {
            $og_image = compressAndUpload($request->file('og_file'), 'pages_og_image');
        }
        $language_id = $request->language;
        $title = $request->title;
        $meta_keyword = json_decode($request->meta_keyword, true);
        Pages::create([
            'language_id' => $language_id,
            'title' => $title,
            'page_type' => $request->page_type,
            'slug' => $slug,
            'schema_markup' => $request->schema_markup ?? '',
            'meta_title' => $request->meta_title ?? '',
            'meta_description' => $request->meta_description ?? '',
            'meta_keywords' => $meta_keyword ? get_meta_keyword($meta_keyword) : '',
            'page_content' => $request->page_content,
            'is_termspolicy' => 0,
            'is_privacypolicy' => 0,
            'status' => 1,
            'og_image' => $og_image,
            'page_icon' => $page_icon,
        ]);

        $response = [
            'error' => false,
            'message' => __('created_success'),
        ];
        return response()->json($response);
    }

    public function update(Request $request)
    {
        ResponseService::noPermissionThenRedirect('page-edit');
        $request->validate([
            'language' => 'required|numeric',
            'title' => 'required',
            'page_type' => 'required',
            'slug' => 'required',
            'page_content' => 'required',
        ]);

        $edit_id = $request->edit_id;
        $language_id = $request->language;
        $page_type = $request->page_type;

        if ($page_type != 'custom') {
            $slug = $request->slug;
            $existingSlug = Pages::where('language_id', $language_id)->where('page_type', $page_type)->where('id', '!=', $edit_id)->exists();
            if ($existingSlug) {
                $response = [
                    'error' => true,
                    'message' => __('page_already_exists'),
                ];
                return response()->json($response);
            }
        } else {
            $slug = customSlug($request->slug);
            $existingSlug = Pages::where('language_id', $language_id)->where('slug', $slug)->where('id', '!=', $edit_id)->exists();
            if ($existingSlug) {
                $response = [
                    'error' => true,
                    'message' => __('slug_already_use'),
                ];
                return response()->json($response);
            }
        }

        $page = Pages::find($edit_id);
        $page->language_id = $request->language;
        $page->title = $request->title;
        $page->page_type = $page_type;
        $page->slug = $slug;
        $page->page_content = $request->page_content;
        if ($request->hasFile('file')) {
            $page->page_icon = compressAndReplace($request->file('file'), 'pages', $page->getRawOriginal('page_icon'));
        }
        if ($request->hasFile('og_file')) {
            $page->og_image = compressAndReplace($request->file('og_file'), 'pages_og_image', $page->getRawOriginal('og_image'));
        }
        if($request->has('status')){
            $page->status = $request->status;
        }
        $page->schema_markup = $request->schema_markup ?? '';
        $page->meta_title = $request->meta_title ?? '';
        $page->meta_description = $request->meta_description ?? '';
        $meta_keyword = json_decode($request->meta_keyword, true);
        $page->meta_keywords = $meta_keyword ? get_meta_keyword($meta_keyword) : '';
        $page->save();
        $response = [
            'error' => false,
            'message' => __('updated_success'),
        ];
        return response()->json($response);
    }

    public function destroy(string $id)
    {
        ResponseService::noPermissionThenRedirect('page-delete');
        $page = Pages::find($id);
        $page->delete();
        $response = [
            'error' => false,
            'message' => __('deleted_success'),
        ];
        return response()->json($response);
    }
}
