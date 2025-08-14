<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Language;
use App\Models\RSS;
use App\Models\Tag;
use App\Services\ResponseService;
use Exception;
use Illuminate\Http\Request;

class RSSController extends Controller
{
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['rss-list', 'rss-create', 'rss-edit', 'rss-delete']);
        try {
            $languageList = Language::where('status', 1)->get();
            $categoryList = [];
            $tagList = [];
            if (count($languageList) == 1) {
                $language_id = $languageList[0]->id;
                $categoryList = Category::select('id', 'category_name')->where('language_id', $language_id)->get();
                $tagList = Tag::where('language_id', $language_id)->get();
            }
            return view('rss', compact('languageList', 'categoryList', 'tagList'));
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }
    }

    public function show(Request $request)
    {
        ResponseService::noPermissionThenRedirect('rss-list');
        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'id');
        $order = $request->input('order', 'DESC');

        $sql = RSS::with('language:id,language', 'category:id,category_name', 'sub_category:id,subcategory_name');
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            $sql = $sql->where(function ($q) use ($search) {
                $q->orWhere('id', 'LIKE', "%{$search}%")->orWhere('feed_name', 'LIKE', "%{$search}%")->orWhere('feed_url', 'LIKE', "%{$search}%");
            });
        }
        if ($request->has('language_id') && $request->language_id) {
            $sql = $sql->where('language_id', $request->language_id);
        }
        if ($request->has('category_id') && $request->category_id) {
            $sql->where('category_id', $request->category_id);
        }
        if ($request->has('subcategory_id') && $request->subcategory_id) {
            $sql->where('subcategory_id', $request->subcategory_id);
        }
        $total = $sql->count();
        $sql = $sql->orderBy($sort, $order)->skip($offset)->take($limit);
        $rows = $sql->get()->map(function ($row) {
            $edit = '';
            if (auth()->user()->can('rss-edit')) {
                $edit = '<a class="dropdown-item edit-data" data-toggle="modal" data-target="#editDataModal" title="' . __('edit') . '"><i class="fa fa-pen mr-1 text-primary"></i>' . __('edit') . '</a>';
            }
            $delete = '';
            if (auth()->user()->can('rss-delete')) {
                $delete = '<a data-url="' . url('rss', $row->id) . '" class="dropdown-item delete-form" data-id="' . $row->id . '" title="' . __('delete') . '"><i class="fa fa-trash mr-1 text-danger"></i>' . __('delete') . '</a>';
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

            if (isset($row->tag_id) && !empty($row->tag_id)) {
                $tagNames = Tag::whereIn('id', explode(',', $row->tag_id))
                    ->distinct()
                    ->pluck('tag_name')
                    ->implode(',');
                $row->tag_name = $tagNames;
                $row->tag_id = !empty($res2) ? $res2[0]->tag_id : $row->tag_id;
            }

            $status = [
                0 => '<span class="badge badge-danger">' . __('deactive') . '</span>',
                1 => '<span class="badge badge-success">' . __('active') . '</span>',
            ];
            return [
                'id' => $row->id,
                'language_id' => $row->language_id,
                'language_name' => $row->language->language ?? '',
                'category_id' => $row->category_id,
                'category_name' => $row->category->category_name ?? '',
                'subcategory_id' => $row->subcategory_id ?? '',
                'subcategory_name' => $row->sub_category->subcategory_name ?? '',
                'tag_id' => $row->tag_id ?? '',
                'tag_name' => $row->tag_name ?? '',
                'feed_name' => $row->feed_name,
                'feed_url' => $row->feed_url,
                'status' => $row->status ?? '',
                'created_at' => date('d-m-Y H:i:s', strtotime($row->created_at)) ?? '',
                'updated_at' => date('d-m-Y H:i:s', strtotime($row->updated_at)) ?? '',
                'status_badge' => $status[$row->status],
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
        ResponseService::noPermissionThenRedirect('rss-create');
        $rules = [
            'language' => 'required',
            'feed_name' => 'required',
            'feed_url' => 'required',
        ];
        if (is_category_enabled() == 1) {
            $rules['category_id'] = 'required';
        }
        $request->validate($rules);

        $rss = new RSS();
        $language_id = $request->language;
        $rss->language_id = $language_id;
        $rss->category_id = $request->category_id ?? 0;
        $rss->subcategory_id = $request->subcategory_id ?? 0;
        $rss->tag_id = implode(',', $request->tag_id ?? []);
        $rss->feed_name = $request->feed_name;
        $rss->feed_url = $request->feed_url;
        $rss->status = 1;
        $rss->save();
        $response = [
            'error' => false,
            'message' => __('created_success'),
        ];
        return response()->json($response);
    }

    public function update(Request $request, RSS $news)
    {
        ResponseService::noPermissionThenRedirect('rss-edit');
        $rules = [
            'language' => 'required',
            'feed_name' => 'required',
            'feed_url' => 'required',
        ];
        if (is_category_enabled() == 1) {
            $rules['category_id'] = 'required';
        }

        $request->validate($rules);

        $rss = RSS::find($request->edit_id);
        $rss->language_id = $request->language;
        $rss->category_id = $request->category_id ?? 0;
        $rss->subcategory_id = $request->subcategory_id ?? 0;
        $rss->tag_id = implode(',', $request->tag_id ?? []);
        $rss->feed_name = $request->feed_name;
        $rss->feed_url = $request->feed_url;
        $rss->status = $request->status;
        $rss->save();
        $response = [
            'error' => false,
            'message' => __('updated_success'),
        ];
        return response()->json($response);
    }

    public function destroy($id)
    {
        ResponseService::noPermissionThenRedirect('rss-delete');
        RSS::find($id)->delete();
        $response = [
            'error' => false,
            'message' => __('deleted_success'),
        ];
        return response()->json($response);
    }

    public function bulk_delete(Request $request)
    {
        ResponseService::noPermissionThenRedirect('rss-bulk-delete');
        try {
            $request_ids = $request->request_ids;
            foreach ($request_ids as $row) {
                $res = RSS::find($row);
                if ($res) {
                    $res->delete();
                }
            }
            $response = [
                'error' => false,
                'message' => __('deleted_success'),
            ];
        } catch (Exception $e) {
            $response = [
                'error' => true,
                'message' => $e->getMessage(),
            ];
        }
        return response()->json($response);
    }
}
