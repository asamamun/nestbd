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
        Schema::create('listing_photos', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('listing_id', 36);
            $table->text('url');
            $table->text('thumbnail_url')->nullable();
            $table->string('caption_en', 255)->nullable();
            $table->string('caption_bn', 255)->nullable();
            $table->string('room_type', 100)->nullable()->comment('bedroom, bathroom, kitchen, living_room, exterior, view');
            $table->smallInteger('sort_order')->default(0);
            $table->boolean('is_cover')->default(false);
            $table->timestamp('uploaded_at')->nullable()->useCurrent();

            // Foreign keys
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
        Schema::dropIfExists('listing_photos');
    }
};
