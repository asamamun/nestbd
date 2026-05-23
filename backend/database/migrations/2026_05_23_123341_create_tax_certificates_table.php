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
        Schema::create('tax_certificates', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('host_id', 36);
            $table->string('fiscal_year', 10)->comment('e.g. 2025-26');
            $table->decimal('total_earnings', 12, 2)->nullable();
            $table->decimal('total_tds_deducted', 12, 2)->nullable();
            $table->decimal('total_vat_collected', 12, 2)->nullable();
            $table->text('certificate_url')->nullable();
            $table->timestamp('generated_at')->nullable()->useCurrent();

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
        Schema::dropIfExists('tax_certificates');
    }
};
