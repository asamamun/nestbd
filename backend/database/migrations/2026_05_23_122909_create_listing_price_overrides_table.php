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
        Schema::create('listing_price_overrides', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('listing_id', 36);
            $table->string('label_en', 200)->nullable();
            $table->string('label_bn', 200)->nullable();
            $table->date('start_date');
            $table->date('end_date');
            $table->decimal('price_per_night', 12, 2);
            $table->unsignedSmallInteger('min_nights')->nullable();
            $table->timestamp('created_at')->nullable()->useCurrent();

            // Foreign keys
            $table->foreign('listing_id')
                ->references('id')
                ->on('listings')
                ->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('listing_price_overrides');
    }
};
