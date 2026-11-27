<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AgentPool extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'role_id',
        'title',
        'notes',
        'image_url',
    ];

    /**
     * Relasi: AgentPool milik satu User
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi: AgentPool milik satu Role (Tabel Induk)
     */
    public function role()
    {
        return $this->belongsTo(Role::class);
    }
}