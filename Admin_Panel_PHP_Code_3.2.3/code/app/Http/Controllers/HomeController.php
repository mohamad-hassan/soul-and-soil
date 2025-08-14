<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use App\Models\AdSpaces;
use App\Models\BreakingNews;
use App\Models\Category;
use App\Models\Comments;
use App\Models\FeaturedSections;
use App\Models\Language;
use App\Models\News;
use App\Models\Pages;
use App\Models\Role;
use App\Models\Settings;
use App\Models\User;
use Carbon\Carbon;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class HomeController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
    }

    public function getSlug(Request $request)
    {
        $table = $request->table;
        $name = $request->name;
        $slug = customSlug($name);
        $originalSlug = $slug;
        if ($request->has('id')) {
            $id = $request->id;
            $counter = 1;
            while (DB::table($table)->where('id', '!=', $id)->where('slug', $slug)->exists()) {
                $slug = $originalSlug . '-' . $counter;
                $counter++;
            }
        } else {
            $counter = 1;
            while (DB::table($table)->where('slug', $slug)->exists()) {
                $slug = $originalSlug . '-' . $counter;
                $counter++;
            }
        }

        return $slug;
    }

    public function index(Request $request)
    {
        $setting = Settings::where('type', 'app_version')->where('message', '3.1.3')->first();
        if ($setting) {
            $setting->message = '3.1.4';
            $setting->save();
        }

        $count_news_per_category = DB::table('tbl_news')->select('tbl_news.category_id', 'tbl_category.category_name', DB::raw('COUNT(tbl_news.id) as news_count'))->leftJoin('tbl_category', 'tbl_category.id', '=', 'tbl_news.category_id')->where('tbl_news.status', 1)->groupBy('tbl_news.category_id', 'tbl_category.category_name')->get();
        $news_per_category = [];
        foreach ($count_news_per_category as $row) {
            $news_per_category[] = [
                'category' => $row->category_name,
                'news' => floatval($row->news_count),
            ];
        }

        $count_news_per_language = DB::table('tbl_news as n')->select('l.language', DB::raw('COUNT(n.id) as news_count'))->join('tbl_languages as l', 'l.id', '=', 'n.language_id')->where('n.status', 1)->groupBy('n.language_id', 'l.language')->get();
        $news_per_language = $count_news_per_language->map(function ($row) {
            return [
                'language' => $row->language,
                'news' => floatval($row->news_count),
            ];
        });

        $count_surveys_per_language = DB::table('tbl_survey_question as s')->select('l.language', DB::raw('COUNT(s.id) as surveys_count'))->join('tbl_languages as l', 'l.id', '=', 's.language_id')->where('s.status', 1)->groupBy('s.language_id', 'l.language')->get();
        $surveys_per_language = $count_surveys_per_language->map(function ($row) {
            return [
                'language' => $row->language,
                'surveys' => floatval($row->surveys_count),
            ];
        });
        $countBreakingNews = BreakingNews::count('id');
        $countFeatredSection = FeaturedSections::where('status', 1)->count('id');
        $countCategory = Category::count('id');
        $countNews = News::count('id');
        $countUsers = User::count('id');
        $countUserRole = Role::count('id');
        $countPages = Pages::where('status', 1)->count('id');
        $countAdSpace = AdSpaces::where('status', 1)->count('id');
            
        // Daily most viewed news
        $daily_news_view = DB::table('tbl_news')
        ->select('tbl_news.*', DB::raw('COUNT(tbl_news_view.id) as viewcount'))
        ->join('tbl_news_view', 'tbl_news_view.news_id', '=', 'tbl_news.id')
        ->whereDate('tbl_news_view.created_at', now()->toDateString())
        ->where('tbl_news.status', 1)
        ->groupBy('tbl_news.id')
        ->orderByDesc('viewcount')
        ->limit(3)
        ->get();
        // Weekly most viewed news
        $weekly_news_view = DB::table('tbl_news')
        ->select('tbl_news.*', DB::raw('COUNT(tbl_news_view.id) as viewcount'))
        ->join('tbl_news_view', 'tbl_news_view.news_id', '=', 'tbl_news.id')
        ->whereBetween('tbl_news_view.created_at', [now()->startOfWeek(), now()->endOfWeek()])
        ->where('tbl_news.status', 1)
        ->groupBy('tbl_news.id')
        ->orderByDesc('viewcount')
        ->limit(3)
        ->get();
            
        // Monthly most viewed news
        $monthly_news_view = DB::table('tbl_news')
        ->select('tbl_news.*', DB::raw('COUNT(tbl_news_view.id) as viewcount'))
        ->join('tbl_news_view', 'tbl_news_view.news_id', '=', 'tbl_news.id')
        ->whereYear('tbl_news_view.created_at', now()->year)
        ->whereMonth('tbl_news_view.created_at', now()->month)
        ->where('tbl_news.status', 1)
        ->groupBy('tbl_news.id')
        ->orderByDesc('viewcount')
        ->limit(3)
        ->get();
        
        foreach ([$daily_news_view, $weekly_news_view, $monthly_news_view] as $collection) {
            foreach ($collection as $row) {
                if (!empty($row->image) && strpos($row->image, 'news/') === false) {
                    $row->image = 'news/' . $row->image;
                }
                $row->image = Storage::disk('public')->exists($row->image) ? url(Storage::url($row->image)) : '';
            }
        }
            
        $recent_categories = Category::orderBy('id', 'DESC')->limit(8)->get();
        $recent_comments = Comments::with('user')->orderBy('id', 'DESC')->limit(6)->get();
        foreach ($recent_comments as $row) {
            $timestamp = Carbon::parse($row->date);
            $row->date = $timestamp->diffForHumans();
        }

        $enbled_language = Language::where('status', 1)->count();
        return view('dashboard', [
            'news_per_category' => $news_per_category,
            'news_per_language' => $news_per_language,
            'surveys_per_language' => $surveys_per_language,
            'countBreakingNews' => $countBreakingNews,
            'countFeatredSection' => $countFeatredSection,
            'countCategory' => $countCategory,
            'countNews' => $countNews,
            'countUsers' => $countUsers,
            'countUserRole' => $countUserRole,
            'countPages' => $countPages,
            'countAdSpace' => $countAdSpace,
            'daily_news_view' => $daily_news_view,
            'weekly_news_view' => $weekly_news_view,
            'monthly_news_view' => $monthly_news_view,
            'recent_categories' => $recent_categories,
            'recent_comments' => $recent_comments,
            'enbled_language' => $enbled_language,
        ]);
    }

    public function upload_img(Request $request)
    {
        $page = $request->input('page');

        $fileType = $request->input('filetype');
        if ($fileType == 'image') {
            $validExtensions = ['png', 'jpeg', 'jpg'];
        } else {
            $validExtensions = ['mp4', 'mp3', 'mov'];
        }

        if (!$request->file('file')->isValid()) {
            return response('Invalid file', 400);
        }
        $file = $request->file('file');
        if (!in_array($file->getClientOriginalExtension(), $validExtensions)) {
            return response('Invalid file extension', 400);
        }
        if ($page == 'news') {
            $upload_file = $file->store('news', 'public');
        } else if ($page == 'breaking_new') {
            $upload_file = $file->store('breaking_news', 'public');
        } else if ($page == 'pages') {
            $upload_file = $file->store('pages', 'public');
        }
        return $upload_file;
    }

    public function editProfile()
    {
        $user = Auth::user();
        return view('edit-profile', compact('user'));
    }

    public function checkOldPass(Request $request)
    {
        $id = Auth::user()->id;
        $password = $request->oldpass;
        $data = Admin::find($id);
        if ($data) {
            if (Hash::check($password, $data->password)) {
                return response()->json(true);
            } else {
                return response()->json(false);
            }
        } else {
            return response()->json(false);
        }
    }

    public function update_profile(Request $request)
    {
        $username = $request->username;
        $email = $request->email;
        $new_password = $request->newpassword;
        $confirm_password = $request->confirmpassword;
        $id = Auth::user()->id;
        if (!empty($new_password) && !empty($confirm_password)) {
            if ($new_password == $confirm_password) {
                $admin = Admin::find($id);
                $admin->username = $username;
                $admin->email = $email;
                $admin->password = $confirm_password;
                if ($request->hasFile('file')) {
                    $admin->image = $request->file('file')->store('admin', 'public');
                }
                $admin->save();
                $response = [
                    'error' => false,
                    'message' => trans('Password Change Successfully..'),
                ];
                return response()->json($response);
            } else {
                $response = [
                    'error' => true,
                    'message' => trans('New and Confirm Password not Match..'),
                ];
                return response()->json($response);
            }
        } else {
            $admin = Admin::find($id);
            $admin->username = $username;
            $admin->email = $email;
            if ($request->hasFile('file')) {
                $admin->image = $request->file('file')->store('admin', 'public');
            }
            $admin->save();
            $response = [
                'error' => false,
                'message' => __('updated_success'),
            ];
            return response()->json($response);
        }
    }

    public function database_backup()
    {
        try {
            Artisan::call('backup:run', ['--only-db' => true]);
            // '--disable-notifications' => true
            $app_name = env('APP_NAME');
            $path = storage_path('app/' . $app_name . '/*');
            $latest_ctime = 0;
            $latest_filename = '';
            $files = glob($path);
            foreach ($files as $file) {
                if (is_file($file) && filectime($file) > $latest_ctime) {
                    $latest_ctime = filectime($file);
                    $latest_filename = $file;
                }
            }
            return response()->download($latest_filename);
        } catch (Exception $e) {
            return $e->getMessage();
        }
    }
}
