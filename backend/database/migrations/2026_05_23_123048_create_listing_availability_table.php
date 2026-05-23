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
        Schema::create('listing_availability', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('listing_id', 36);
            $table->date('date');
            $table->enum('availability', ['available', 'blocked_by_host', 'blocked_by_booking', 'blocked_by_ical'])->default('available');
            $table->decimal('price_override', 12, 2)->nullable()->comment('NULL = use listing base price');
            $table->unsignedSmallInteger('min_nights')->nullable();
            $table->text('note')->nullable();

            // Indexes
            $table->unique(['listing_id', 'date'], 'uq_listing_date');
            $table->index(['listing_id', 'date'], 'idx_availability_listing_date');

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
        Schema::dropIfExists('listing_availability');
    }
};
