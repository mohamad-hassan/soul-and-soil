<?php

use App\Http\Controllers\ApiController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::post('get_settings', [ApiController::class, 'getSettings']);
Route::post('get_languages_list', [ApiController::class, 'getLanguagesList']);
Route::post('get_language_json_data', [ApiController::class, 'getLanguageJsonData']);
Route::post('get_pages', [ApiController::class, 'getPages']);
Route::post('get_policy_pages', [ApiController::class, 'getPolicyPages']);
Route::post('get_location', [ApiController::class, 'getLocation']);
Route::post('get_category', [ApiController::class, 'getCategory']);
Route::post('get_subcategory_by_category', [ApiController::class, 'getSubcategoryByCategory']);
Route::post('get_tag', [ApiController::class, 'getTag']);
Route::post('get_notification', [ApiController::class, 'getNotification']);
Route::post('get_web_seo_pages', [ApiController::class, 'getWebSeoPages']);
Route::post('get_live_streaming', [ApiController::class, 'getLiveStreaming']);
Route::post('get_rss_feed', [ApiController::class, 'getRssFeed']);
Route::post('get_rss_feed_by_id', [ApiController::class, 'getRssFeedById']);

Route::group(['middleware' => ['auth.optional']], function () {
    Route::post('set_news_view', [ApiController::class, 'setNewsView']);
    Route::post('set_breaking_news_view', [ApiController::class, 'setBreakingNewsView']);
    Route::post('get_featured_sections', [ApiController::class, 'getFeaturedSections']);
    Route::post('get_news', [ApiController::class, 'getNews']);
    Route::post('get_videos', [ApiController::class, 'getVideos']);
    Route::post('get_comment_by_news', [ApiController::class, 'getCommentByNews']);
    Route::post('get_breaking_news', [ApiController::class, 'getBreakingNews']);
});

Route::post('get_ad_space_news_details', [ApiController::class, 'getAdSpaceNewsDetails']);
Route::post('user_signup', [ApiController::class, 'userSignup']);

Route::post('check_slug_availability', [ApiController::class, 'checkSlugAvailability']);

Route::group(['middleware' => ['auth:sanctum']], function () {
    Route::post('delete_news_images', [ApiController::class, 'deleteNewsImages']);
    Route::post('delete_news', [ApiController::class, 'deleteNews']);
    Route::post('set_news', [ApiController::class, 'setNews']);
    Route::post('get_question_result', [ApiController::class, 'getQuestionResult']);
    Route::post('set_question_result', [ApiController::class, 'setQuestionResult']);
    Route::post('get_question', [ApiController::class, 'getQuestion']);
    Route::post('get_bookmark', [ApiController::class, 'getBookmark']);
    Route::post('set_bookmark', [ApiController::class, 'setBookmark']);
    Route::post('set_flag', [ApiController::class, 'setFlag']);
    Route::post('set_comment_like_dislike', [ApiController::class, 'setCommentLikeDislike']); // change in user detail object
    Route::post('delete_comment', [ApiController::class, 'deleteComment']);
    Route::post('set_comment', [ApiController::class, 'setComment']);
    Route::post('get_like', [ApiController::class, 'getLike']); //for app
    Route::post('set_like_dislike', [ApiController::class, 'setLikeDislike']);
    Route::post('delete_user_notification', [ApiController::class, 'deleteUserNotification']);
    Route::post('get_user_notification', [ApiController::class, 'getUserNotification']); // pagintion pending
    Route::post('set_user_category', [ApiController::class, 'setUserCategory']);

    Route::post('register_token', [ApiController::class, 'registerToken']);
    Route::post('delete_user', [ApiController::class, 'deleteUser']);
    Route::post('update_profile', [ApiController::class, 'updateProfile']);
    Route::post('get_user_by_id', [ApiController::class, 'getUserById']);
});
