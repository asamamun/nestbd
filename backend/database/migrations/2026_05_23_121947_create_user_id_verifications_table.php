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
        Schema::create('user_id_verifications', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('user_id', 36);
            $table->enum('doc_type', ['nid', 'passport', 'driving_licence', 'birth_certificate']);
            $table->string('doc_number', 100);
            $table->text('doc_front_url');
            $table->text('doc_back_url')->nullable();
            $table->text('selfie_url')->nullable();
            $table->enum('status', ['not_submitted', 'pending', 'approved', 'rejected', 'expired'])->default('pending');
            $table->char('reviewer_admin_id', 36)->nullable();
            $table->text('reviewer_notes')->nullable();
            $table->timestamp('submitted_at')->nullable()->useCurrent();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamp('expires_at')->nullable();

            // Foreign keys
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('cascade');

            $table->foreign('reviewer_admin_id')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_id_verifications');
    }
};
