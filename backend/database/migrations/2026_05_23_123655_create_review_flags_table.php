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
        Schema::create('review_flags', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('review_id', 36);
            $table->char('flagged_by', 36);
            $table->text('reason');
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('review_id')
                ->references('id')
                ->on('reviews');

            $table->foreign('flagged_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('review_flags');
    }
};
