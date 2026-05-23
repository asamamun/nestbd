<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Area extends Model
{
    /** @use HasFactory<\Database\Factories\AreaFactory> */
    use HasFactory;
    /*
    thana_id        SMALLINT UNSIGNED NULL,
    district_id     SMALLINT UNSIGNED NULL,
    name_en         VARCHAR(200) NOT NULL,
    name_bn         VARCHAR(200) NULL,
    area_type       VARCHAR(50) NULL COMMENT 'neighbourhood, beach_zone, tourist_area, city_ward',
    is_tourist_area TINYINT(1) NOT NULL DEFAULT 0,
    latitude        DECIMAL(10,8) NULL,
    longitude       DECIMAL(11,8) NULL,
    */
    //fillable
    protected $fillable = [
        'thana_id',
        'district_id',
        'name_en',
        'name_bn',
        'area_type',
        'is_tourist_area',
        'latitude',
        'longitude',
    ];

    public function thana(): BelongsTo
    {
        return $this->belongsTo(Thana::class);
    }
    public function district(): BelongsTo
    {
        return $this->belongsTo(District::class);
    }

}
