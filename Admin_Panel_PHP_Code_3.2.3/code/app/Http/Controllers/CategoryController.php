<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\Language;
use App\Services\ResponseService;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class CategoryController extends Controller
{
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['category-list', 'category-create', 'category-edit', 'category-delete', 'category-order-create']);
        try {
            $languageList = Language::where('status', 1)->get();
            $categoryList = Category::select('id', 'category_name')->orderBy('row_order', 'ASC')->get();
            return view('category', compact('languageList', 'categoryList'));
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }
    }

    public function get_category_by_language(Request $request)
    {
        $language_id = $request->language_id;
        if ($language_id == 0 && $request->sortable) {
            $res = Category::select('id', 'category_name')->get();
        } else {
            $res = Category::select('id', 'category_name')->where('language_id', $language_id)->orderBy('row_order', 'ASC')->get();
        }

        if (!empty($res)) {
            if ($request->sortable) {
                $options = '';
                foreach ($res as $row) {
                    $options .= '<li id="' . $row->id . '">' . $row->category_name . '</li>';
                }
            } else {
                $options = '<option value="">' . __('select') . ' ' . __('category') . '</option>';
                foreach ($res as $row) {
                    $options .= '<option value="' . $row->id . '">' . $row->category_name . '</option>';
                }
            }
        }
        return $options;
    }

    public function show(Request $request)
    {
        ResponseService::noPermissionThenRedirect('category-list');
        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'row_order');
        $order = $request->input('order', 'ASC');

        $sql = Category::with('language');
        if ($request->has('language_id') && $request->language_id) {
            $sql = $sql->where('language_id', $request->language_id);
        }
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            $sql = $sql->where(function ($q) use ($search) {
                $q->where('id', 'LIKE', "%{$search}%")->orwhere('category_name', 'LIKE', "%{$search}%");
            });
        }
        $total = $sql->count();
        $sql = $sql->orderBy($sort, $order)->skip($offset)->take($limit);
        $rows = $sql->get()->map(function ($row) {
            $edit = '';
            $delete = '';
            if (auth()->user()->can('category-edit')) {
                $edit = '<a class="dropdown-item edit-data" data-toggle="modal" data-target="#editDataModal" title="' . __('edit') . '"><i class="fa fa-pen mr-1 text-primary"></i>' . __('edit') . '</a>';
            }
            if (auth()->user()->can('category-delete')) {
                    $delete = '<a data-url="' . url('category', $row->id) . '" class="dropdown-item delete-form" data-id="' . $row->id . '" title="' . __('delete') . '"><i class="fa fa-trash mr-1 text-danger"></i>' . __('delete') . '</a>';
            }
            if ($edit == '' && $delete == '') {
                $operate = '-';
            }
            else{
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
            json_decode($row->meta_keyword);
            if (json_last_error() === JSON_ERROR_NONE) {
                $meta_keyword = json_decode($row->meta_keyword);
            } else {
                $meta_keyword = $row->meta_keyword;
            }
            return [
                'id' => $row->id,
                'language_id' => $row->language_id ?? '',
                'language_name' => $row->language ? $row->language->language : '',
                'category_name' => $row->category_name,
                'slug' => $row->slug,
                'meta_keyword' => $meta_keyword,
                'schema_markup' => $row->schema_markup,
                'description' => $row->meta_description,
                'meta_title' => $row->meta_title,
                'image' => $row->image ? '<a href="' . $row->image . '" data-toggle="lightbox" data-title="Image"><img  class = "images_border" src="' . $row->image . '" height="50" width="50"></a>' : '-',
                'row_order' => '<span class="btn btn-icon btn-sm btn-warning move" alt="Move" >' . $row->row_order . '</span>',
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
        ResponseService::noPermissionThenRedirect('category-create');
        $validator = Validator::make($request->all(), [
            'language' => ['required', 'numeric'],
            'name' => ['required', 'max:255'],
            'slug' => ['required', 'max:255'],
            'file' => ['required'],
        ]);
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }
        $slug = customSlug($request->slug);
        $existingSlug = Category::where('slug', $slug)->exists();
        if ($existingSlug) {
            $response = [
                'error' => true,
                'message' => __('slug_already_use'),
            ];
            return response()->json($response);
        }
        $category = new Category();
        $category->language_id = $request->language;
        $category->category_name = $request->name;
        $category->slug = $slug;
        if ($request->hasFile('file')) {
            $category->image = compressAndUpload($request->file('file'), 'category');
        } else {
            $category->image = '';
        }
        $category->schema_markup = $request->schema_markup ?? '';
        $category->meta_title = $request->meta_title ?? '';
        $category->meta_description = $request->meta_description ?? '';
        $meta_keyword = json_decode($request->meta_keyword, true);
        $category->meta_keyword = $meta_keyword ? get_meta_keyword($meta_keyword) : '';
        $category->save();
        $response = [
            'error' => false,
            'message' => __('created_success'),
        ];
        return response()->json($response);
    }

    public function update(Request $request)
    {
        ResponseService::noPermissionThenRedirect('category-edit');
        $validator = Validator::make($request->all(), [
            'language' => ['required', 'numeric'],
            'name' => ['required', 'max:255'],
            'slug' => ['required', 'max:255'],
        ]);
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }
        $slug = customSlug($request->slug);
        $existingSlug = Category::where('slug', $slug)
            ->where('id', '!=', $request->edit_id)
            ->exists();
        if ($existingSlug) {
            $response = [
                'error' => true,
                'message' => __('slug_already_use'),
            ];
            return response()->json($response);
        }

        $category = Category::find($request->edit_id);
        $category->language_id = $request->language;
        $category->category_name = $request->name;
        $category->slug = customSlug($request->slug);
        if ($request->hasFile('file')) {
            $category->image = compressAndReplace($request->file('file'), 'category', $category->getRawOriginal('image'));
        }
        $category->schema_markup = $request->schema_markup ?? '';
        $category->meta_title = $request->meta_title ?? '';
        $category->meta_description = $request->meta_description ?? '';
        $meta_keyword = json_decode($request->meta_keyword, true);
        $category->meta_keyword = $meta_keyword ? get_meta_keyword($meta_keyword) : '';
        $category->save();
        $response = [
            'error' => false,
            'message' => __('updated_success'),
        ];
        return response()->json($response);
    }

    public function destroy(string $id)
    {
        ResponseService::noPermissionThenRedirect('category-delete');
        Category::find($id)->delete();
        $response = [
            'error' => false,
            'message' => __('deleted_success'),
        ];
        return response()->json($response);
    }

    public function update_order(Request $request)
    {
        ResponseService::noPermissionThenRedirect('category-order-create');
        if ($request->row_order) {
            $row_order = explode(',', $request->row_order);
            foreach ($row_order as $key => $id) {
                Category::where('id', $id)->update(['row_order' => $key + 1]);
            }
        }
        return redirect('category')->with('success', __('updated_success'));
    }
}
