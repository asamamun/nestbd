<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('areas', function (Blueprint $table) {
            $table->id();
            /* thana_id        SMALLINT UNSIGNED NULL,
    district_id     SMALLINT UNSIGNED NULL,
    name_en         VARCHAR(200) NOT NULL,
    name_bn         VARCHAR(200) NULL,
    area_type       VARCHAR(50) NULL COMMENT 'neighbourhood, beach_zone, tourist_area, city_ward',
    is_tourist_area TINYINT(1) NOT NULL DEFAULT 0,
    latitude        DECIMAL(10,8) NULL,
    longitude       DECIMAL(11,8) NULL,*/
            $table->unsignedBigInteger('thana_id')->nullable();
            $table->unsignedBigInteger('district_id')->nullable();
            $table->string('name_en');
            $table->string('name_bn');
            $table->string('area_type')->nullable();
            $table->tinyInteger('is_tourist_area')->default(0);
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            //reference
            $table->foreign('thana_id')->references('id')->on('thanas')->onDelete('cascade');
            $table->foreign('district_id')->references('id')->on('districts')->onDelete('cascade');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('areas');
    }
};
