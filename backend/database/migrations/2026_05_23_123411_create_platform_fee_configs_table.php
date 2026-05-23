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
        Schema::create('platform_fee_configs', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('name', 200);
            $table->decimal('guest_service_fee_pct', 5, 2)->default(12.00);
            $table->decimal('host_service_fee_pct', 5, 2)->default(3.00);
            $table->decimal('vat_on_service_fee_pct', 5, 2)->default(15.00)->comment('Bangladesh VAT');
            $table->decimal('tds_rate_pct', 5, 2)->default(5.00)->comment('TDS on host payouts');
            $table->decimal('tds_threshold_bdt', 12, 2)->default(0.00);
            $table->date('applicable_from');
            $table->date('applicable_to')->nullable();
            $table->boolean('is_active')->default(true);
            $table->char('created_by', 36)->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('created_by')
                ->references('id')
                ->on('users');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('platform_fee_configs');
    }
};
