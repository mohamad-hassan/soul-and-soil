<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Tag extends Model
{
    use HasFactory;

    protected $table = 'tbl_tag';

    protected $fillable = ['language_id', 'tag_name', 'slug', 'meta_title', 'meta_description', 'meta_keyword', 'schema_markup', 'og_image'];

    public function language()
    {
        return $this->belongsTo(Language::class, 'language_id');
    }

    public function getOgImageAttribute($image)
    {
        if ($image && strpos($image, 'tag_og_image/') === false) {
            $image = 'tag_og_image/' . $image;
        }

        return $image && Storage::disk('public')->exists($image) ? url(Storage::url($image)) : '';
    }

    protected static function boot()
    {
        parent::boot();
        static::deleting(function ($tag) {
            if (!is_null($tag->og_image) && Storage::disk('public')->exists($tag->getRawOriginal('og_image'))) {
                Storage::disk('public')->delete($tag->getRawOriginal('og_image'));
            }
        });
    }
}
