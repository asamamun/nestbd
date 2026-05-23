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
        Schema::create('listing_reports', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('listing_id', 36);
            $table->char('reporter_id', 36);
            $table->string('category', 100)->comment('inaccurate, fraudulent, offensive, spam, safety');
            $table->text('description')->nullable();
            $table->string('status', 50)->default('open');
            $table->char('reviewed_by', 36)->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('listing_id')
                ->references('id')
                ->on('listings');

            $table->foreign('reporter_id')
                ->references('id')
                ->on('users');

            $table->foreign('reviewed_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listing_reports');
    }
};
