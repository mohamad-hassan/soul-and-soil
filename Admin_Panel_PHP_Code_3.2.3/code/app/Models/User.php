<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = ['firebase_id', 'name', 'type', 'email', 'mobile', 'profile', 'fcm_id', 'status', 'date', 'role'];

    protected $table = 'tbl_users';
    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = ['password', 'remember_token'];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function getProfileAttribute($profile)
    {
        if ($this->type == 'email' || $this->type == 'mobile' || $this->type == 'fb') {
            if (!empty($profile) && strpos($profile, 'profile/') === false) {
                $profile = 'profile/' . $profile;
            }
            return $profile && Storage::disk('public')->exists($profile) ? url(Storage::url('/' . $profile)) : '';
        } else {
            if (stripos($profile, 'google') !== false) {
                return $profile;
            } elseif (stripos($profile, 'facebook') !== false) {
                return $profile;
            } else {
                if (!empty($profile) && strpos($profile, 'profile/') === false) {
                    $profile = 'profile/' . $profile;
                }
                return $profile && Storage::disk('public')->exists($profile) ? url(Storage::url('/' . $profile)) : '';
            }
        }
    }

    public function roles()
    {
        return $this->belongsTo(Role::class, 'role');
    }

    public function user_category()
    {
        return $this->hasOne(UserCategory::class, 'user_id');
    }
}
