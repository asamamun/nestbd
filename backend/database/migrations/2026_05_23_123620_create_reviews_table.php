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
        Schema::create('reviews', function (Blueprint $table) {
            $table->char('id', 36)->primary();
            $table->char('booking_id', 36);
            $table->enum('review_type', ['guest_to_listing', 'host_to_guest']);
            $table->char('reviewer_id', 36);
            $table->char('reviewee_id', 36);
            $table->char('listing_id', 36)->nullable();

            // Ratings (1.0 – 5.0)
            $table->decimal('overall_rating', 3, 2);
            $table->decimal('cleanliness_rating', 3, 2)->nullable();
            $table->decimal('accuracy_rating', 3, 2)->nullable();
            $table->decimal('checkin_rating', 3, 2)->nullable();
            $table->decimal('communication_rating', 3, 2)->nullable();
            $table->decimal('location_rating', 3, 2)->nullable();
            $table->decimal('value_rating', 3, 2)->nullable();

            $table->text('comment_en')->nullable();
            $table->text('comment_bn')->nullable();

            $table->timestamp('submitted_at')->nullable()->useCurrent();
            $table->timestamp('published_at')->nullable();
            $table->boolean('is_published')->default(false);

            // Host public response
            $table->text('response_text')->nullable();
            $table->timestamp('response_at')->nullable();

            // Moderation
            $table->boolean('is_flagged')->default(false);
            $table->text('flagged_reason')->nullable();
            $table->char('moderated_by', 36)->nullable();
            $table->timestamp('moderated_at')->nullable();
            $table->boolean('is_removed')->default(false);

            $table->timestamp('created_at')->nullable()->useCurrent();

            // Indexes
            $table->unique(['booking_id', 'review_type'], 'uq_review_booking_type');
            $table->index(['listing_id', 'is_published'], 'idx_reviews_listing');
            $table->index(['reviewee_id', 'review_type', 'is_published'], 'idx_reviews_reviewee');

            // Foreign keys
            $table->foreign('booking_id')
                ->references('id')
                ->on('bookings');

            $table->foreign('reviewer_id')
                ->references('id')
                ->on('users');

            $table->foreign('reviewee_id')
                ->references('id')
                ->on('users');

            $table->foreign('listing_id')
                ->references('id')
                ->on('listings');

            $table->foreign('moderated_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
