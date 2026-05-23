<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class District extends Model
{
    /** @use HasFactory<\Database\Factories\DistrictFactory> */
    use HasFactory;
    //fillable
    protected $fillable = [
        'name_en',
        'name_bn',
        'division_id',
    ];
    //relationship
    public function upazilas(): HasMany
    {
        return $this->hasMany(Upazila::class);
    }
    //belongs to division
    public function division(): BelongsTo
    {
        return $this->belongsTo(Division::class);
    }
}
