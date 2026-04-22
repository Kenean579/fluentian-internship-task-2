<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Creates the table_sessions table which tracks which device
     * is currently associated with which table.
     */
    public function up(): void
    {
        Schema::create('table_sessions', function (Blueprint $table) {
            $table->id();

            // The table number or identifier (e.g. "Table 5")
            $table->string('table_id');

            // A unique ID generated on the customer's device (browser or phone)
            // Indexed for fast lookups when restoring sessions
            $table->string('user_device_id')->index();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('table_sessions');
    }
};
