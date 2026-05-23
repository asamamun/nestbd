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
        Schema::create('listing_ical_syncs', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('listing_id', 36);
            $table->string('source_name', 100)->comment('booking.com, agoda, airbnb_export');
            $table->text('ical_url');
            $table->timestamp('last_synced_at')->nullable();
            $table->string('sync_status', 50)->default('active');

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
        Schema::dropIfExists('listing_ical_syncs');
    }
};
