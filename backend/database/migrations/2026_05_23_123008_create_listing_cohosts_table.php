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
        Schema::create('listing_cohosts', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('listing_id', 36);
            $table->char('host_id', 36);
            $table->char('cohost_id', 36);
            $table->enum('permission', ['view_only', 'manage_calendar', 'manage_bookings', 'full_access'])->default('manage_bookings');
            $table->timestamp('invited_at')->nullable()->useCurrent();
            $table->timestamp('accepted_at')->nullable();
            $table->boolean('is_active')->default(true);

            // Indexes
            $table->unique(['listing_id', 'cohost_id'], 'uq_listing_cohost');

            // Foreign keys
            $table->foreign('listing_id')
                ->references('id')
                ->on('listings')
                ->onDelete('cascade');

            $table->foreign('host_id')
                ->references('id')
                ->on('users');

            $table->foreign('cohost_id')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listing_cohosts');
    }
};
