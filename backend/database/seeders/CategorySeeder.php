<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Starters',    'description' => 'Light bites to begin your meal', 'display_order' => 1],
            ['name' => 'Main Course', 'description' => 'Hearty dishes to satisfy your hunger', 'display_order' => 2],
            ['name' => 'Pizzas',      'description' => 'Wood-fired pizzas with fresh toppings', 'display_order' => 3],
            ['name' => 'Desserts',    'description' => 'Sweet treats to end your meal', 'display_order' => 4],
            ['name' => 'Drinks',      'description' => 'Fresh juices, sodas, and hot drinks', 'display_order' => 5],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
