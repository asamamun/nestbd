<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Thana extends Model
{
    /** @use HasFactory<\Database\Factories\ThanaFactory> */
    use HasFactory;
    //fillable
    protected $fillable = [
        'name_en',
        'name_bn',
        'upazila_id',
    ];
    //belongs to upazila
    public function upazila(): BelongsTo
    {
        return $this->belongsTo(Upazila::class);
    }
    //has many area
    public function areas(): HasMany
    {
        return $this->hasMany(Area::class);
    }
}
