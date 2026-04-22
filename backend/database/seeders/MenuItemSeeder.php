<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\MenuItem;
use App\Models\Category;

class MenuItemSeeder extends Seeder
{
    public function run(): void
    {
        $starters   = Category::where('name', 'Starters')->first()->id;
        $main       = Category::where('name', 'Main Course')->first()->id;
        $pizza      = Category::where('name', 'Pizzas')->first()->id;
        $desserts   = Category::where('name', 'Desserts')->first()->id;
        $drinks     = Category::where('name', 'Drinks')->first()->id;

        $items = [
            [
                'category_id' => $starters,
                'name'        => 'Garlic Bread',
                'description' => 'Toasted bread with garlic butter and herbs',
                'price'       => 4.99,
                'prep_time'   => 8,
                'available'   => true,
            ],
            [
                'category_id' => $starters,
                'name'        => 'Chicken Wings',
                'description' => 'Crispy wings with BBQ dipping sauce',
                'price'       => 9.99,
                'prep_time'   => 15,
                'available'   => true,
            ],
            [
                'category_id' => $main,
                'name'        => 'Grilled Salmon',
                'description' => 'Fresh Atlantic salmon with seasonal vegetables',
                'price'       => 18.99,
                'prep_time'   => 20,
                'available'   => true,
            ],
            [
                'category_id' => $main,
                'name'        => 'Beef Burger',
                'description' => 'Juicy 200g beef patty with fries',
                'price'       => 14.99,
                'prep_time'   => 18,
                'available'   => true,
            ],
            [
                'category_id' => $pizza,
                'name'        => 'Margherita Pizza',
                'description' => 'Classic tomato, mozzarella, and basil',
                'price'       => 12.99,
                'prep_time'   => 20,
                'available'   => true,
            ],
            [
                'category_id' => $pizza,
                'name'        => 'Pepperoni Pizza',
                'description' => 'Loaded with pepperoni and melted cheese',
                'price'       => 14.99,
                'prep_time'   => 22,
                'available'   => true,
            ],
            [
                'category_id' => $desserts,
                'name'        => 'Chocolate Lava Cake',
                'description' => 'Warm chocolate cake with a molten center',
                'price'       => 6.99,
                'prep_time'   => 12,
                'available'   => true,
            ],
            [
                'category_id' => $drinks,
                'name'        => 'Fresh Orange Juice',
                'description' => 'Freshly squeezed orange juice',
                'price'       => 3.99,
                'prep_time'   => 3,
                'available'   => true,
            ],
        ];

        foreach ($items as $item) {
            MenuItem::create($item);
        }
    }
}
