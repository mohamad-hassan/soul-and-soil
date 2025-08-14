<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class AdSpaces extends Model
{
    use HasFactory;

    protected $table = 'tbl_ad_spaces';

    protected $fillable = ['ad_space', 'ad_featured_section_id', 'ad_image', 'web_ad_image', 'ad_url', 'language_id', 'date', 'status'];

    public function getAdImageAttribute($AdImage)
    {
        if (!empty($AdImage) && strpos($AdImage, 'ad_spaces/') === false) {
            $AdImage = 'ad_spaces/' . $AdImage;
        }
        return $AdImage && Storage::disk('public')->exists($AdImage) ? url(Storage::url('/' . $AdImage)) : '';
    }

    public function getWebAdImageAttribute($WebAdImage)
    {
        if (!empty($WebAdImage) && strpos($WebAdImage, 'ad_spaces/') === false) {
            $WebAdImage = 'ad_spaces/' . $WebAdImage;
        }
        return $WebAdImage && Storage::disk('public')->exists($WebAdImage) ? url(Storage::url('/' . $WebAdImage)) : '';
    }

    public function language()
    {
        return $this->belongsTo(Language::class, 'language_id');
    }

    public function feature_section()
    {
        return $this->belongsTo(FeaturedSections::class, 'ad_featured_section_id');
    }

    protected static function boot()
    {
        parent::boot();
        static::deleting(function ($image) {
            // before delete() method call this
            if (!is_null($image->ad_image) && Storage::disk('public')->exists($image->getRawOriginal('ad_image'))) {
                Storage::disk('public')->delete($image->getRawOriginal('ad_image'));
            }
            if (!is_null($image->web_ad_image) && Storage::disk('public')->exists($image->getRawOriginal('web_ad_image'))) {
                Storage::disk('public')->delete($image->getRawOriginal('web_ad_image'));
            }
        });
    }
}
