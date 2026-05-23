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
        Schema::create('thanas', function (Blueprint $table) {
            $table->unsignedSmallInteger('id')->primary()->autoIncrement();
            //upazila_id
            $table->unsignedSmallInteger('upazila_id');
            $table->string('name_en');
            $table->string('name_bn');
            $table->foreign('upazila_id')->references('id')->on('upazilas')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('thanas');
    }
};
