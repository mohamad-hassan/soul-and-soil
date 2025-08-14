<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RSS extends Model
{
    use HasFactory;

    protected $table = 'tbl_rss';

    protected $fillable = ['language_id', 'category_id', 'subcategory_id', 'tag_id',  'feed_name', 'feed_url', 'status'];
    
    public function language()
    {
        return $this->belongsTo(Language::class, 'language_id');
    }

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id');
    }

    public function tag()
    {
        return $this->belongsTo(Tag::class, 'tag_id');
    }

    public function sub_category()
    {
        return $this->belongsTo(SubCategory::class, 'subcategory_id');
    }
}
