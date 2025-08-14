<?php

namespace App\Http\Controllers;

use App\Models\Location;
use App\Services\ResponseService;
use Exception;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['location-list', 'location-create', 'location-edit', 'location-delete']);
        try {
            return view('location');
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }
    }

    public function show(Request $request)
    {
        ResponseService::noPermissionThenRedirect('location-list');
        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'id');
        $order = $request->input('order', 'DESC');

        $sql = Location::orderBy($sort, $order);
        if ($request->has('search') && $request->search != '') {
            $search = $request->search;
            if (!empty($search)) {
                $sql->where('id', 'LIKE', "%{$search}%")
                    ->orWhere('location_name', 'LIKE', "%{$search}%")
                    ->orWhere('latitude', 'LIKE', "%{$search}%")
                    ->orWhere('longitude', 'LIKE', "%{$search}%");
            }
        }
        $total = $sql->count('id');
        $sql = $sql->skip($offset)->take($limit);
        $rows = $sql->get()->map(function ($row) {
            $edit = '';
            if (auth()->user()->can('location-edit')) {
                $edit = '<a class="dropdown-item edit-data" data-toggle="modal" data-target="#editDataModal" title="' . __('edit') . '"><i class="fa fa-pen mr-1 text-primary"></i>' . __('edit') . '</a>';
            }
            $delete = '';
            if (auth()->user()->can('location-delete')) {
                $delete = '<a data-url="' . url('location', $row->id) . '" class="dropdown-item delete-form" data-id="' . $row->id . '" title="' . __('delete') . '"><i class="fa fa-trash mr-1 text-danger"></i>' . __('delete') . '</a>';
            }
            $operate = '';
            if (auth()->user()->can('location-edit') || auth()->user()->can('location-delete')) {
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
                'location_name' => $row->location_name,
                'latitude' => $row->latitude,
                'longitude' => $row->longitude,
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
        ResponseService::noPermissionThenRedirect('location-create');
        $request->validate([
            'name' => 'required',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);
        Location::create([
            'location_name' => $request->name,
            'latitude' => round($request->longitude, 3),
            'longitude' => round($request->latitude, 3),
        ]);
        $response = [
            'error' => false,
            'message' => __('created_success'),
        ];
        return response()->json($response);
    }

    public function update(Request $request)
    {
        ResponseService::noPermissionThenRedirect('location-edit');
        $request->validate([
            'name' => 'required',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        Location::where('id', $request->edit_id)->update([
            'location_name' => $request->name,
            'latitude' => round($request->latitude, 3),
            'longitude' => round($request->longitude, 3),
        ]);
        $response = [
            'error' => false,
            'message' => __('updated_success'),
        ];
        return response()->json($response);
    }

    public function destroy(string $id)
    {
        ResponseService::noPermissionThenRedirect('location-delete');
        Location::find($id)->delete();
        $response = [
            'error' => false,
            'message' => __('deleted_success'),
        ];
        return response()->json($response);
    }
}
