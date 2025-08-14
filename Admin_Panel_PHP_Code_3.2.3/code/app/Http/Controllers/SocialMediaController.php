<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\SocialMedia;
use App\Services\ResponseService;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class SocialMediaController extends Controller
{
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['social-media-list', 'social-media-create', 'social-media-edit', 'social-media-delete']);
        try {
            $socialList = SocialMedia::orderBy('row_order', 'ASC')->get();
            return view('social-media', compact('socialList'));
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }
    }

    public function show(Request $request)
    {
        ResponseService::noPermissionThenRedirect('social-media-list');
        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'row_order');
        $order = $request->input('order', 'ASC');

        $sql = SocialMedia::orderBy($sort, $order);        
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            $sql = $sql->where(function ($q) use ($search) {
                $q->where('id', 'LIKE', "%{$search}%")->orwhere('link', 'LIKE', "%{$search}%");
            });
        }
        $total = $sql->count();
        $sql = $sql->skip($offset)->take($limit);
        $rows = $sql->get()->map(function ($row) {
            $edit = '';
            if (auth()->user()->can('social-media-edit')) {
                $edit = '<a class="dropdown-item edit-data" data-toggle="modal" data-target="#editDataModal" title="' . __('edit') . '"><i class="fa fa-pen mr-1 text-primary"></i>' . __('edit') . '</a>';
            }
            $delete = '';
            if (auth()->user()->can('social-media-delete')) {
                $delete = '<a data-url="' . url('social-media', $row->id) . '" class="dropdown-item delete-form" data-id="' . $row->id . '" title="' . __('delete') . '"><i class="fa fa-trash mr-1 text-danger"></i>' . __('delete') . '</a>';
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
            return [
                'id' => $row->id,
                'link' => $row->link,
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
        ResponseService::noPermissionThenRedirect('social-media-create');
        $validator = Validator::make($request->all(), [
            'link' => ['required', 'max:255'],
            'file' => ['required'],
        ]);
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }
        $res = new SocialMedia();
        $res->link = $request->link;
        if ($request->hasFile('file')) {
            $res->image = compressAndUpload($request->file('file'), 'social_media');
        } else {
            $res->image = '';
        }
        $res->row_order = 0;
        $res->save();
        $response = [
            'error' => false,
            'message' => __('created_success'),
        ];
        return response()->json($response);
    }

    public function update(Request $request)
    {
        ResponseService::noPermissionThenRedirect('social-media-edit');
        $validator = Validator::make($request->all(), [
            'link' => ['required', 'max:255'],
        ]);
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }

        $res = SocialMedia::find($request->edit_id);
        $res->link = $request->link;
        if ($request->hasFile('file')) {
            $res->image = compressAndReplace($request->file('file'), 'social_media', $res->getRawOriginal('image'));
        }
        $res->save();
        $response = [
            'error' => false,
            'message' => __('updated_success'),
        ];
        return response()->json($response);
    }

    public function destroy(string $id)
    {
        ResponseService::noPermissionThenRedirect('social-media-delete');
        SocialMedia::find($id)->delete();
        $response = [
            'error' => false,
            'message' => __('deleted_success'),
        ];
        return response()->json($response);
    }

    public function update_order(Request $request)
    {
        if ($request->row_order) {
            $row_order = explode(',', $request->row_order);
            foreach ($row_order as $key => $id) {
                SocialMedia::where('id', $id)->update(['row_order' => $key + 1]);
            }
        }
        return redirect('social-media')->with('success', __('updated_success'));
    }
}
