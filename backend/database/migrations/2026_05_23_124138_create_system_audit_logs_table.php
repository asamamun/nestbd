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
        Schema::create('system_audit_logs', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('table_name', 100);
            $table->text('record_id');
            $table->char('operation', 1)->comment('I=Insert, U=Update, D=Delete');
            $table->json('old_data')->nullable();
            $table->json('new_data')->nullable();
            $table->char('changed_by', 36)->nullable();
            $table->timestamp('changed_at')->nullable()->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('system_audit_logs');
    }
};
