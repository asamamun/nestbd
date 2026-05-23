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
        Schema::create('listing_amenities', function (Blueprint $table) {
            $table->char('listing_id', 36);
            $table->unsignedSmallInteger('amenity_id');
            $table->text('notes')->nullable();

            // Primary key
            $table->primary(['listing_id', 'amenity_id']);

            // Foreign keys
            $table->foreign('listing_id')
                ->references('id')
                ->on('listings')
                ->onDelete('cascade');

            $table->foreign('amenity_id')
                ->references('id')
                ->on('amenities');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listing_amenities');
    }
};
