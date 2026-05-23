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
        Schema::create('amenities', function (Blueprint $table) {
            $table->smallIncrements('id');
            $table->string('category', 100)->comment('basics, bathroom, kitchen, power, safety, outdoor, bangladesh_specific');
            $table->string('name_en', 150);
            $table->string('name_bn', 150)->nullable();
            $table->string('icon_key', 100)->nullable();
            $table->boolean('is_highlight')->default(false);
            $table->smallInteger('sort_order')->default(0);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('amenities');
    }
};
