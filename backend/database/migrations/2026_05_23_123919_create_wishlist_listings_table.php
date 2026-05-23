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
        Schema::create('wishlist_listings', function (Blueprint $table) {
            $table->unsignedInteger('wishlist_id');
            $table->char('listing_id', 36);
            $table->timestamp('added_at')->nullable()->useCurrent();

            // Primary key
            $table->primary(['wishlist_id', 'listing_id']);

            // Foreign keys
            $table->foreign('wishlist_id')
                ->references('id')
                ->on('wishlists')
                ->onDelete('cascade');

            $table->foreign('listing_id')
                ->references('id')
                ->on('listings')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('wishlist_listings');
    }
};
