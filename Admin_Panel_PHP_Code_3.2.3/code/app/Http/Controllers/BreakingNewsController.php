<?php

namespace App\Http\Controllers;

use App\Models\Language;
use App\Models\BreakingNews;
use App\Models\BreakingNewsView;
use App\Services\ResponseService;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class BreakingNewsController extends Controller
{
    public function index()
    {
        ResponseService::noAnyPermissionThenRedirect(['breaking-news-list', 'breaking-news-create', 'breaking-news-edit']);
        try {
            $languageList = Language::where('status', 1)->get();
            return view('breaking-news', compact('languageList'));
        } catch (Exception $e) {
            return back()->with('error', $e->getMessage());
        }
    }

    public function show(Request $request)
    {
        ResponseService::noPermissionThenRedirect('breaking-news-list');
        $offset = $request->input('offset', 0);
        $limit = $request->input('limit', 10);
        $sort = $request->input('sort', 'id');
        $order = $request->input('order', 'DESC');
        $search = $request->input('search', '');

        $sql = BreakingNews::with('language')->withCount('breaking_news_view as total_views');
        if ($request->has('language_id') && $request->language_id) {
            $sql = $sql->where('language_id', $request->language_id);
        }
        if ($search != '') {
            $sql = $sql->where(function ($q) use ($search) {
                $q->where('id', 'LIKE', "%{$search}%")->orWhere('title', 'LIKE', "%{$search}%");
            });
        }
        $total = $sql->count('id');
        $sql = $sql->skip($offset)->take($limit)->orderBy($sort, $order);
        $rows = $sql->get()->map(function ($row) {
            $con_value = $con_v = $videos = '';
            if ($row->content_type != 'standard_post') {
                if ($row->content_type == 'video_upload') {
                    $filename = $row->content_value;
                    $con_value = Storage::url($filename);
                    $videos = '<a class="btn btn-icon" data-toggle="lightbox" data-title="Video" data-type="video" href="' . $con_value . '" title="view video"><i class="fa fa-eye mr-1 text-primary"></i> view Video</a>';
                } else {
                    $con_value = $row->content_value;
                    $videos = '<a class="btn btn-icon" data-toggle="lightbox" data-title="Video" data-type="youtube" href="' . $con_value . '" title="view video"><i class="fa fa-eye mr-1 text-primary"></i>View Video</a>';
                }
            }
            $edit = '';
            if (auth()->user()->can('breaking-news-edit')) {
                $edit = '<a class="dropdown-item edit-data" data-toggle="modal" data-target="#editDataModal" title="' . __('edit') . '"><i class="fa fa-pen mr-1 text-primary"></i>' . __('edit') . '</a>';
            }
            $delete = '';
            if (auth()->user()->can('breaking-news-delete')) {
                $delete = '<a data-url="' . url('breaking_news', $row->id) . '" class="dropdown-item delete-form" data-id="' . $row->id . '" title="' . __('delete') . '"><i class="fa fa-trash mr-1 text-danger"></i>' . __('delete') . '</a>';
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
                $videos .
                '
                            </div>
                        </div>';
            }

            $image = !empty($row->image) ? $row->image : '';

            $media =
                '     <div class="o-media o-media--middle">
                    <img class="o-media__img images_in_card"
                        src="' .
                $image .
                '"
                        data-lightbox="image-1" alt="diaa barri">
                        <div class="o-media__body">
                            <div class="provider_name_table">' .
                $row->title .
                '</div>
                            <div class="provider_email_table"><span>
                                    slug : ' .
                $row->slug .
                '
                                </span></div>
                        </div>
                </div>
         ';
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
                'title' => $row->title,
                'slug' => $row->slug,
                'content_type' => str_replace('_', ' ', $row->content_type) ?? '',
                'image' => !empty($row->image) ? '<a href=' . $image . '  data-toggle="lightbox" data-title="Image"><img class = "images_border"src=' . $image . ' height=50, width=50 style="border-radius:8px;">' : '-',
                'content_value' => $row->content_value ?? '',
                'description' => $row->description ?? '',
                'views' => $row->total_views,
                'con_v' => $con_v,
                'content' => $row->content_type,
                'media' => $media,
                'meta_keyword' => $meta_keyword,
                'schema_markup' => $row->schema_markup,
                'meta_title' => $row->meta_title,
                'meta_description' => $row->meta_description,
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
        ResponseService::noPermissionThenRedirect('breaking-news-create');
        $request->validate(
            [
                'language' => 'required',
                'slug' => 'required',
                'title' => 'required',
                'content_type' => 'required',
                'des' => 'required|string',
                'file' => 'image',
                'video_file' => $request->content_type == 'video_upload' ? 'required|mimes:mp4,mov,avi|max:20480' : '',
                'youtube_url' => $request->content_type == 'video_youtube' ? 'required|youtube_url' : '',
                'other_url' => $request->content_type == 'video_other' ? 'required' : '',
            ],
            [
                'des.required' => 'Description field is required.',
            ],
        );
        $content_value = '';
        $content_type = $request->content_type;
        if ($content_type == 'video_youtube') {
            $content_value = $request->youtube_url;
        } elseif ($content_type == 'video_other') {
            $content_value = $request->other_url;
        } elseif ($content_type == 'video_upload' && $request->hasFile('video_file')) {
            $content_value = $request->file('video_file')->store('breaking_news_video', 'public');
        }

        $slug = customSlug($request->slug);
        $existingSlug = BreakingNews::where('slug', $slug)->exists();
        if ($existingSlug) {
            $response = [
                'error' => true,
                'message' => __('slug_already_use'),
            ];
            return response()->json($response);
        }

        $breacking_news = new BreakingNews();
        $breacking_news->title = $request->title;
        $breacking_news->slug = $slug;
        $breacking_news->content_type = $request->content_type;
        $breacking_news->content_value = $content_value;
        $breacking_news->language_id = $request->language;
        $breacking_news->description = $request->des;
        $breacking_news->schema_markup = $request->schema_markup ?? '';
        $breacking_news->meta_title = $request->meta_title ?? '';
        $breacking_news->meta_description = $request->meta_description ?? '';
        $meta_keyword = json_decode($request->meta_keyword, true);
        $breacking_news->meta_keyword = $meta_keyword ? get_meta_keyword($meta_keyword) : '';
        if ($request->hasFile('file')) {
            $breacking_news->image = compressAndUpload($request->file('file'), 'breaking_news');
        } else {
            $breacking_news->image = '';
        }
        $breacking_news->save();
        $response = [
            'error' => false,
            'message' => __('created_success'),
        ];
        return response()->json($response);
    }

    public function update(Request $request)
    {
        ResponseService::noPermissionThenRedirect('breaking-news-edit');
        $request->validate(
            [
                'language' => 'required',
                'title' => 'required|string',
                'content_type' => 'required',
                'des' => 'required|string',
                'file' => 'image',
                'other_url' => $request->content_type == 'video_other' ? 'required' : '',
                'youtube_url' => $request->content_type == 'video_youtube' ? 'required|youtube_url' : '',
            ],
            [
                'des.required' => 'Description field is required.',
            ],
        );
        $slug = customSlug($request->slug);
        $existingSlug = BreakingNews::where('slug', $slug)
            ->where('id', '!=', $request->edit_id)
            ->exists();
        if ($existingSlug) {
            $response = [
                'error' => true,
                'message' => __('slug_already_use'),
            ];
            return response()->json($response);
        }
        $breacking_news = BreakingNews::find($request->edit_id);
        $content_type = $request->content_type;
        $content_value = '';
        if ($content_type == 'video_youtube') {
            $content_value = $request->youtube_url;
        } elseif ($content_type == 'video_other') {
            $content_value = $request->other_url;
        } elseif ($content_type == 'video_upload') {
            if ($request->hasFile('video_file')) {
                Storage::disk('public')->delete($breacking_news->getRawOriginal('content_value'));
                $content_value = $request->file('video_file')->store('breaking_news_video', 'public');
            } else {
                $content_value = $breacking_news->content_value;
            }
        }

        $breacking_news->language_id = $request->language;
        $breacking_news->title = $request->title;
        $breacking_news->slug = $slug;
        $breacking_news->content_type = $request->content_type;
        $breacking_news->content_value = $content_value;
        $breacking_news->description = $request->des;
        $breacking_news->schema_markup = $request->schema_markup ?? '';
        $breacking_news->meta_title = $request->meta_title ?? '';
        $breacking_news->meta_description = $request->meta_description ?? '';
        $meta_keyword = json_decode($request->meta_keyword, true);
        $breacking_news->meta_keyword = $meta_keyword ? get_meta_keyword($meta_keyword) : '';
        if ($request->hasFile('file')) {
            $breacking_news->image = compressAndReplace($request->file('file'), 'breaking_news', $breacking_news->getRawOriginal('image'));
        }
        $breacking_news->save();
        $response = [
            'error' => false,
            'message' => __('updated_success'),
        ];
        return response()->json($response);
    }

    public function destroy(string $id)
    {
        ResponseService::noPermissionThenRedirect('breaking-news-delete');
        $breacking_news = BreakingNews::find($id);
        if ($breacking_news->content_type == 'video_upload') {
            Storage::disk('public')->delete($breacking_news->getRawOriginal('content_value'));
        }
        $breacking_news->delete();
        $response = [
            'error' => false,
            'message' => __('deleted_success'),
        ];
        return response()->json($response);
    }

    public function bulk_brecking_news_delete(Request $request)
    {
        ResponseService::noPermissionThenRedirect('breaking-news-delete');
        try {
            $request_ids = $request->request_ids;
            foreach ($request_ids as $row) {
                $news = BreakingNews::find($row);
                if ($news) {
                    $news->delete();
                }
            }
            $response = [
                'error' => false,
                'message' => __('deleted_success'),
            ];
            return response()->json($response);
        } catch (Exception $th) {
            throw $th;
        }
    }
}
