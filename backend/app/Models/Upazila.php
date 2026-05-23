<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Upazila extends Model
{
    /** @use HasFactory<\Database\Factories\UpazilaFactory> */
    use HasFactory;

    protected $guarded = [];
    //fillable
    protected $fillable = [
        'name_en',
        'name_bn',
        'district_id',
    ];

    //relationship
    public function districts(): BelongsTo
    {
        return $this->belongsTo(District::class);
    }
    //has many thanas
    public function thanas(): HasMany
    {
        return $this->hasMany(Thana::class);
    }
}
