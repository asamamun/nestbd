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
        Schema::create('superhost_assessments', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('host_id', 36);
            $table->string('assessment_period', 20)->comment('Q1-2026, Q2-2026');
            $table->decimal('response_rate', 5, 2)->nullable();
            $table->decimal('acceptance_rate', 5, 2)->nullable();
            $table->unsignedInteger('completed_stays')->nullable();
            $table->unsignedInteger('completed_nights')->nullable();
            $table->decimal('avg_rating', 3, 2)->nullable();
            $table->boolean('passed_response_rate')->nullable();
            $table->boolean('passed_acceptance_rate')->nullable();
            $table->boolean('passed_stays_or_nights')->nullable();
            $table->boolean('passed_rating')->nullable();
            $table->boolean('is_superhost_awarded')->nullable();
            $table->timestamp('assessed_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('host_id')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('superhost_assessments');
    }
};
