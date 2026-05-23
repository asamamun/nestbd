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
        Schema::create('feature_flags', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary();
            $table->string('flag_key', 200);
            $table->text('description')->nullable();
            $table->boolean('is_enabled')->default(false);
            $table->unsignedTinyInteger('rollout_pct')->default(0)->comment('0–100 percent of users');
            $table->json('user_segment')->nullable();
            $table->char('updated_by', 36)->nullable();
            $table->timestamp('updated_at')->nullable()->useCurrent()->useCurrentOnUpdate();

            // Indexes
            $table->unique('flag_key', 'uq_feature_flags_key');

            // Foreign keys
            $table->foreign('updated_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('feature_flags');
    }
};
