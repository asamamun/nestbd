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
        Schema::create('dispute_evidence', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->unsignedInteger('dispute_id');
            $table->char('submitted_by', 36);
            $table->text('file_url');
            $table->string('file_type', 50)->nullable();
            $table->text('description')->nullable();
            $table->timestamp('submitted_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('dispute_id')
                ->references('id')
                ->on('disputes');

            $table->foreign('submitted_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('dispute_evidence');
    }
};
