<?php

namespace Database\Seeders;

use App\Models\District;
use App\Models\Division;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DistrictSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $districts = [
            // Dhaka (id: 1)
            'Dhaka' => [
                'Dhaka', 'Gazipur', 'Narayanganj', 'Tangail', 'Kishoreganj',
                'Manikganj', 'Munshiganj', 'Narsingdi', 'Rajbari', 'Shariatpur',
                'Faridpur', 'Gopalganj', 'Madaripur'
            ],
            
            // Rajshahi (id: 2)
            'Rajshahi' => [
                'Rajshahi', 'Natore', 'Chapai Nawabganj', 'Naogaon', 'Bogra',
                'Sirajganj', 'Pabna', 'Joypurhat'
            ],
            
            // Khulna (id: 3)
            'Khulna' => [
                'Khulna', 'Bagerhat', 'Satkhira', 'Jessore', 'Jhenaidah',
                'Magura', 'Narail', 'Chuadanga', 'Kushtia', 'Meherpur'
            ],
            
            // Barisal (id: 4)
            'Barisal' => [
                'Barisal', 'Barguna', 'Bhola', 'Jhalokati', 'Patuakhali',
                'Pirojpur'
            ],
            
            // Chittagong (id: 5)
            'Chittagong' => [
                'Chittagong', 'Cox\'s Bazar', 'Rangamati', 'Bandarban',
                'Khagrachari', 'Comilla', 'Brahmanbaria', 'Chandpur',
                'Lakshmipur', 'Noakhali', 'Feni'
            ],
            
            // Sylhet (id: 6)
            'Sylhet' => [
                'Sylhet', 'Moulvibazar', 'Habiganj', 'Sunamganj'
            ],
            
            // Rangpur (id: 7)
            'Rangpur' => [
                'Rangpur', 'Dinajpur', 'Kurigram', 'Gaibandha', 'Nilphamari',
                'Panchagarh', 'Thakurgaon', 'Lalmonirhat'
            ],
            
            // Mymensingh (id: 8)
            'Mymensingh' => [
                'Mymensingh', 'Netrokona', 'Jamalpur', 'Sherpur'
            ],
        ];
            foreach ($districts as $divisionName => $districtNames) {
            // Find the division by name
            $division = Division::where('name_en', $divisionName)->first();
            
            if ($division) {
                foreach ($districtNames as $districtName) {
                    District::create([
                        'name_en' => $districtName,
                        'name_bn' => $districtName,
                        'division_id' => $division->id
                    ]);
                }
            }
        }
    }
}
