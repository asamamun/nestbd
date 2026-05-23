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
        Schema::create('listing_beds', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->char('listing_id', 36);
            $table->unsignedSmallInteger('room_number');
            $table->string('bed_type', 50)->comment('king, queen, double, single, bunk, sofa_bed, floor_mattress');
            $table->unsignedSmallInteger('quantity')->default(1);

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
        Schema::dropIfExists('listing_beds');
    }
};
