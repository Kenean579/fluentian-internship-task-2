<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\MenuItem;
use App\Models\Category;

class MenuItemSeeder extends Seeder
{
    public function run(): void
    {
        $traditional = Category::where('name', 'Traditional Mains')->first()->id;
        $meat        = Category::where('name', 'Meat Dishes')->first()->id;
        $vegetarian  = Category::where('name', 'Vegetarian')->first()->id;
        $beverages   = Category::where('name', 'Beverages')->first()->id;

        $items = [
            [
                'category_id' => $traditional,
                'name'        => 'Doro Wat',
                'description' => 'Spicy chicken stew with hard-boiled egg and injera',
                'price'       => 450.00,
                'prep_time'   => 20,
                'available'   => true,
            ],
            [
                'category_id' => $vegetarian,
                'name'        => 'Shiro Wat',
                'description' => 'Delicious chickpea powder stew served with injera',
                'price'       => 150.00,
                'prep_time'   => 15,
                'available'   => true,
            ],
            [
                'category_id' => $meat,
                'name'        => 'Awaze Tibs',
                'description' => 'Pan-fried beef cubes with awaze sauce, onions, and jalapeños',
                'price'       => 350.00,
                'prep_time'   => 18,
                'available'   => true,
            ],
            [
                'category_id' => $meat,
                'name'        => 'Kitfo',
                'description' => 'Minced raw beef marinated in mitmita and niter kibbeh',
                'price'       => 400.00,
                'prep_time'   => 12,
                'available'   => true,
            ],
            [
                'category_id' => $vegetarian,
                'name'        => 'Beyaynetu',
                'description' => 'A colorful platter of mixed vegetarian stews and salads',
                'price'       => 200.00,
                'prep_time'   => 25,
                'available'   => true,
            ],
            [
                'category_id' => $traditional,
                'name'        => 'Firfir',
                'description' => 'Shredded injera mixed with spicy stew',
                'price'       => 180.00,
                'prep_time'   => 10,
                'available'   => true,
            ],
            [
                'category_id' => $beverages,
                'name'        => 'Traditional Ethiopian Coffee',
                'description' => 'Strong and aromatic freshly roasted coffee (Buna)',
                'price'       => 30.00,
                'prep_time'   => 10,
                'available'   => true,
            ],
            [
                'category_id' => $beverages,
                'name'        => 'Tej',
                'description' => 'Traditional Ethiopian honey wine',
                'price'       => 100.00,
                'prep_time'   => 5,
                'available'   => true,
            ],
        ];

        foreach ($items as $item) {
            MenuItem::create($item);
        }
    }
}
