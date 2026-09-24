![Project Banner](Banner.png)
ward.robe is a "Virtual Closet" website, offering an innovative solution to efficiently and intelligently manage and organize clothing collections. This website is created with the primary goal of providing users with a pleasant and practical experience in managing their everyday clothing inventory.

With ward.robe, users can upload, store, and categorize all their clothing items into an easy-to-use application. Sometimes, finding or selecting the right attire can be a confusing task. Therefore, this website was developed to provide a solution that allows users to track all the clothing items they own, mark garments that are in the laundry process, and even provide recommendations for outfit combinations based on the user's clothing inventory.

Not only that, but users can also note additional details such as size, brand, and specific notes for each clothing item in the free-form description. ward.robe is designed to help reduce confusion in choosing daily clothing, optimize the use of clothing collections, and bring joy to the dressing process.

## Installation

Requirements: PHP 8.0+ (with `mysqli`, `fileinfo`, `mbstring`) and MySQL 5.7+/MariaDB 10.2+, e.g. XAMPP.

1. Copy the `wardrobe/` folder into your web root (e.g. `htdocs/`).
2. Create an empty database named `wardrobe`, then import `wardrobe/DB/wardrobe.sql` followed by `wardrobe/DB/procedures.sql`.
3. Copy `wardrobe/inc/config.example.php` to `wardrobe/inc/config.local.php` and fill in your MySQL credentials (a dedicated MySQL user is recommended over `root`). Environment variables `WARDROBE_DB_HOST`, `WARDROBE_DB_USER`, `WARDROBE_DB_PASS`, `WARDROBE_DB_NAME` override the file.
4. Open the app in your browser. On the first visit you will be asked to create the login password, so do this before exposing the app to a network.

### Upgrading from 1.x

Back up your database first, then import `wardrobe/DB/migrate_v2.sql` followed by `wardrobe/DB/procedures.sql`. Clothing numbers are renumbered to 1, 2, 3, … and existing laundry entries are kept.

## Features

Upon entering the landing page, users will be greeted by a sleeping wizard. When awakened, users will be presented with six menus that encapsulate basic features within the database (CRUD): input menu, laundry, edit, sold, wardrobe, and dressme.

### Input Feature
- Users can input their clothing items, including tops, bottoms, and accessories.
- Users can fill in clothing data such as name, description, and photo (the number is assigned automatically). The description allows users to input freely, including clothing brand, size, or perhaps an unforgettable novelty associated with the garment.

### Laundry Feature
- Users can view and add clothing items (tops, bottoms, and accessories) that are currently in the laundry and can remove items from the laundry list when they are done.

### Edit Feature
- Users can edit all data except the number if they have made an input mistake or if the description needs updating due to changes in the clothing item or color.

### Sold Feature
- When users no longer possess a certain clothing item, they can delete it from their wardrobe list.

### Wardrobe Feature
- Users can view all the contents of their virtual closet in this feature.

### DressMe Feature
- When users run out of ideas for outfit combinations, they can utilize this feature. DressMe suggests combinations consisting of 2 tops, 1 bottom, and 1 accessory, skipping anything that is still in the laundry.

#### and some easter egg
