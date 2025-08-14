<?php

namespace App\Http\Controllers;

use App\Models\Language;
use App\Models\News;
use App\Models\Tag;
use App\Services\ResponseService;
use Illuminate\Http\Request;
use Exception;

class TagController extends Controller
{
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['tag-list', 'tag-create', 'tag-edit', 'tag-delete']);
        try {
            $languageList = Language::where('status', 1)->get();
            return view('tag', compact('languageList'));
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }
    }

    public function show(Request $request)
    {
        ResponseService::noPermissionThenRedirect('tag-list');
        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'id');
        $order = $request->input('order', 'DESC');
        $sql = Tag::with('language');

        if ($request->has('language_id') && $request->language_id) {
            $sql = $sql->where('language_id', $request->language_id);
        }
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            $sql = $sql->where(function ($q) use ($search) {
                $q->where('id', 'LIKE', "%{$search}%")->orwhere('tag_name', 'LIKE', "%{$search}%");
            });
        }
        $total = $sql->count();
        $sql = $sql->orderBy($sort, $order)->skip($offset)->take($limit);
        $rows = $sql->get()->map(function ($row) {
            $edit = '';
            $delete = '';
            if (auth()->user()->can('tag-edit')) {
                $edit = '<a class="dropdown-item edit-data" data-toggle="modal" data-target="#editDataModal" title="' . __('edit') . '"><i class="fa fa-pen mr-1 text-primary"></i>' . __('edit') . '</a>';
            }
            if (auth()->user()->can('tag-delete')) {
                $delete = '<a data-url="' . url('tag', $row->id) . '" class="dropdown-item delete-form" data-id="' . $row->id . '" title="' . __('delete') . '"><i class="fa fa-trash mr-1 text-danger"></i>' . __('delete') . '</a>';
            }
            if ($edit == '' && $delete == '') {
                $operate = '-';
            }
            else{
                $operate =
                '<div class="dropdown">
                            <a href="javascript:void(0) role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
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
                'language_id' => $row->language_id,
                'language' => $row->language->language ?? '',
                'tag_name' => $row->tag_name,
                'slug' => $row->slug,
                'schema_markup' => $row->schema_markup,
                'meta_title' => $row->meta_title,
                'meta_keyword' => $meta_keyword,
                'description' => $row->meta_description,
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
        ResponseService::noPermissionThenRedirect('tag-create');
        $request->validate([
            'language' => 'required',
            'name' => 'required',
            'slug' => 'required',
        ]);

        $slug = customSlug($request->slug);
        $existingSlug = Tag::where('slug', $slug)->exists();
        if ($existingSlug) {
            $response = [
                'error' => true,
                'message' => __('slug_already_use'),
            ];
            return response()->json($response);
        }

        $tag = new Tag();
        $tag->language_id = $request->language;
        $tag->tag_name = $request->name;
        $tag->slug = $slug;
        if ($request->hasFile('file')) {
            $tag->og_image = compressAndUpload($request->file('file'), 'tag_og_image');
        } else {
            $tag->og_image = '';
        }
        $tag->schema_markup = $request->schema_markup ?? '';
        $tag->meta_title = $request->meta_title ?? '';
        $tag->meta_description = $request->meta_description ?? '';
        $meta_keyword = json_decode($request->meta_keyword, true);
        $tag->meta_keyword = $meta_keyword ? get_meta_keyword($meta_keyword) : '';
        $tag->save();
        $response = [
            'error' => false,
            'message' => __('created_success'),
        ];
        return response()->json($response);
    }

    public function update(Request $request)
    {
        ResponseService::noPermissionThenRedirect('tag-edit');
        $request->validate([
            'language' => 'required',
            'name' => 'required',
            'slug' => 'required',
        ]);
        $slug = customSlug($request->slug);
        $existingSlug = Tag::where('slug', $slug)
            ->where('id', '!=', $request->edit_id)
            ->exists();
        if ($existingSlug) {
            $response = [
                'error' => true,
                'message' => __('slug_already_use'),
            ];
            return response()->json($response);
        }

        $tag = Tag::find($request->edit_id);
        $tag->language_id = $request->language;
        $tag->tag_name = $request->name;
        $tag->slug = $slug;
        if ($request->hasFile('file')) {
            $tag->og_image = compressAndReplace($request->file('file'), 'tag_og_image', $tag->getRawOriginal('og_image'));
        }
        $tag->schema_markup = $request->schema_markup ?? '';
        $tag->meta_title = $request->meta_title ?? '';
        $tag->meta_description = $request->meta_description ?? '';
        $meta_keyword = json_decode($request->meta_keyword, true);
        $tag->meta_keyword = $meta_keyword ? get_meta_keyword($meta_keyword) : '';
        $tag->save();

        $response = [
            'error' => false,
            'message' => __('updated_success'),
        ];
        return response()->json($response);
    }

    public function destroy(string $id)
    {
        ResponseService::noPermissionThenRedirect('tag-delete');
        News::whereRaw('FIND_IN_SET(?, tag_id)', [$id])
            ->get()
            ->each(function ($news) use ($id) {
                $tagIds = explode(',', $news->tag_id); // Split the tag_ids into an array
                $tagIds = array_diff($tagIds, [$id]); // Remove the specified tag ID
                $news->tag_id = implode(',', $tagIds); // Join the remaining tag_ids back into a comma-separated list
                $news->save(); // Save the updated news item
            });

        Tag::find($id)->delete();
        $response = [
            'error' => false,
            'message' => __('deleted_success'),
        ];
        return response()->json($response);
    }

    public function get_tag_by_language(Request $request)
    {
        $language_id = $request->language_id;
        $res = Tag::where('language_id', $language_id)->get();
        // $option = '<option value="">'.__('select') . ' ' . __('tag').'</option>';
        $option = '';
        if (!empty($res)) {
            foreach ($res as $value) {
                $option .= '<option value="' . $value['id'] . '">' . $value['tag_name'] . '</option>';
            }
        }
        return $option;
    }
}
