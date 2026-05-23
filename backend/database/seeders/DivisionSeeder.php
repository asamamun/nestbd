<?php

namespace Database\Seeders;

use App\Models\Division;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DivisionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        //bangladesh all division list
        foreach ([
            'Dhaka',
            'Rajshahi',
            'Khulna',
            'Barisal',
            'Chittagong',
            'Sylhet',
            'Rangpur',
            'Mymensingh',
        ] as $name) {
            Division::create(['name_en' => $name, 'name_bn' => $name]);
        }
    }
}
