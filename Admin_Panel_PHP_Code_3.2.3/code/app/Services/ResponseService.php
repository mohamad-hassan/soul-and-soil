<?php

namespace App\Services;
use Illuminate\Support\Facades\Auth;

class ResponseService
{
    public static function noPermissionThenRedirect($permission)
    {
        if (!Auth::user()->can($permission)) {
            return redirect(route('home'))->with('error', "You Don't have enough permissions");
        }
        return true;
    }

    public static function noAnyPermissionThenRedirect(array $permissions)
    {
        if (!Auth::user()->canany($permissions)) {
            return redirect()->route('home')->with('error', "You Don't have enough permissions");
        } 
        return true;
    }
}