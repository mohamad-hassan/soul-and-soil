<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use App\Services\ResponseService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Facades\Validator;

class StaffController extends Controller
{
    /**
     * Display a listing of the staff members.
     */
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['staff-list', 'staff-create', 'staff-edit', 'staff-delete', 'staff-change-password']);
        $staff = Admin::with('roles')
            ->whereDoesntHave('roles', function($query) {
                $query->where('name', 'Admin');
            })
            ->get();
            
        $roles = Role::where('name', '!=', 'Admin')->get();
        return view('staff', compact('staff', 'roles'));
    }

    /**
     * Store a newly created staff member.
     */
    public function store(Request $request)
    {
        ResponseService::noPermissionThenRedirect('staff-create');
        $validator = Validator::make($request->all(), [
            'username' => ['required', 'string', 'min:3', 'max:255', 'unique:admin'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:admin'],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['required', 'exists:roles,id'],
            'status' => ['required', 'boolean'],
        ]);
    
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }
    
        try {
            $staff = new Admin();
            $staff->username = $request->username;
            $staff->email = $request->email;
            $staff->password = Hash::make($request->password);
            $staff->status = $request->status;
            $staff->save();
    
            // Find role by ID and assign it
            $role = Role::findById($request->role, 'admin');
            $staff->assignRole($role);
    
            $response = [
                'error' => false,
                'message' => __('Staff member created successfully.'),
            ];
            return response()->json($response);
        } catch (\Exception $e) {
            $response = [
                'error' => true,
                'message' => $e->getMessage(),
            ];
            return response()->json($response, 500);
        }
    }
    
    /**
     * Update the specified staff member.
     */
    public function update(Request $request, $id)
    {
        ResponseService::noPermissionThenRedirect('staff-edit');
        $staff = Admin::findOrFail($id);
    
        $validator = Validator::make($request->all(), [
            'username' => ['required', 'string', 'min:3', 'max:255', 'unique:admin,username,' . $id],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:admin,email,' . $id],
            'role' => ['required', 'exists:roles,id'],
            'status' => ['required', 'boolean'],
        ]);
    
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }
    
        try {
            $staff->username = $request->username;
            $staff->email = $request->email;
            $staff->status = $request->status;
    
            // Update password if provided
            if ($request->filled('password')) {
                $request->validate([
                    'password' => ['required', 'string', 'min:8'],
                ]);
                $staff->password = Hash::make($request->password);
            }
    
            $staff->save();
            
            // Find role by ID and sync it
            $role = Role::findById($request->role, 'admin');
            $staff->syncRoles([$role]);
    
            $response = [
                'error' => false,
                'message' => __('Staff member updated successfully.'),
            ];
            return response()->json($response);
        } catch (\Exception $e) {
            $response = [
                'error' => true,
                'message' => $e->getMessage(),
            ];
            return response()->json($response, 500);
        }
    }
    
    /**
     * Remove the specified staff member.
     */
    public function destroy($id)
    {
        ResponseService::noPermissionThenRedirect('staff-delete');
        try {
            $staff = Admin::findOrFail($id);
    
            $staff->delete();
    
            $response = [
                'error' => false,
                'message' => __('Staff member deleted successfully.'),
            ];
            return response()->json($response);
        } catch (\Exception $e) {
            $response = [
                'error' => true,
                'message' => $e->getMessage(),
            ];
            return response()->json($response, 500);
        }
    }
    
    /**
     * Change staff member password.
     */
    public function changePassword(Request $request)
    {
        ResponseService::noPermissionThenRedirect('staff-change-password');
        $validator = Validator::make($request->all(), [
            'staff_id' => ['required', 'exists:admin,id'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);
    
        if ($validator->fails()) {
            $response = [
                'error' => true,
                'message' => $validator->errors()->all(),
            ];
            return response()->json($response);
        }
    
        try {
            $staff = Admin::findOrFail($request->staff_id);
    
            // Prevent changing admin users' passwords unless it's the current user
            if ($staff->hasRole('Admin') && $staff->id !== auth()->id()) {
                $response = [
                    'error' => true,
                    'message' => __('Cannot change other admin users\' passwords.'),
                ];
                return response()->json($response, 403);
            }
    
            $staff->password = Hash::make($request->password);
            $staff->save();
    
            $response = [
                'error' => false,
                'message' => __('Password changed successfully.'),
            ];
            return response()->json($response);
        } catch (\Exception $e) {
            $response = [
                'error' => true,
                'message' => $e->getMessage(),
            ];
            return response()->json($response, 500);
        }
    }
    
    /**
     * Get staff list for datatable.
     */
    public function list(Request $request)
    {
        ResponseService::noPermissionThenRedirect('staff-list');
        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'id');
        $order = $request->input('order', 'ASC');
        $search = $request->input('search', '');

        $query = Admin::with('roles')->whereDoesntHave('roles', function ($q) {
            $q->where('name', 'Admin');
        });

        if (!empty($search)) {
            $query->where(function ($q) use ($search) {
                $q->where('username', 'LIKE', "%{$search}%")
                    ->orWhere('email', 'LIKE', "%{$search}%");
            });
        }

        $total = $query->count();

        $staff = $query->orderBy($sort, $order)
            ->skip($offset)
            ->take($limit)
            ->get();

        $rows = $staff->map(function ($member) {
            return [
                'id' => $member->id,
                'username' => $member->username,
                'email' => $member->email,
                'role_id' => $member->roles->first() ? $member->roles->first()->id : '',
                'role_name' => $member->roles->pluck('name')->implode(', '),
                'status' => $member->status,
                'status_badge' => '<span class="badge badge-' . ($member->status ? 'success' : 'danger') . '">' .
                    ($member->status ? __('active') : __('inactive')) . '</span>',
                'is_admin' => $member->hasRole('Admin'),
            ];
        });

        return response()->json([
            'total' => $total,
            'rows' => $rows,
        ]);
    }

    
}