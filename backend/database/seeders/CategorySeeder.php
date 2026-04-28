<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Traditional Mains', 'description' => 'Classic Ethiopian main dishes served with Injera', 'display_order' => 1],
            ['name' => 'Meat Dishes', 'description' => 'Savory meat delicacies', 'display_order' => 2],
            ['name' => 'Vegetarian', 'description' => 'Rich and flavorful plant-based dishes', 'display_order' => 3],
            ['name' => 'Beverages', 'description' => 'Traditional drinks and coffee', 'display_order' => 4],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
