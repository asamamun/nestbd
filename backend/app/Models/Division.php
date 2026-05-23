<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Division extends Model
{
    /** @use HasFactory<\Database\Factories\DivisionFactory> */
    use HasFactory;
    //fillable
    protected $fillable = [
        'name_en',
        'name_bn',
    ];
    //relationship
    public function districts(): HasMany
    {
        return $this->hasMany(District::class);
    }
}
