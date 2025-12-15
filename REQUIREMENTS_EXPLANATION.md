# Requirements Explanation - Simple Guide

This document explains each requirement in the app, like teaching to a 12-year-old! 🎓

---

## ✅ 1. Register and Log In Using Firebase Authentication

**What it means:** Users can create accounts and sign in using Firebase (Google's authentication service).

**How it works in the app:**
- When you register, the app uses Firebase to create your account
- When you log in, Firebase checks if your email and password are correct
- It's like having a security guard that checks your ID before letting you in

**Where to find it:**
- `lib/screens/auth/register_screen.dart` - Registration page
- `lib/screens/auth/login_screen.dart` - Login page
- `lib/services/auth_service.dart` - The code that talks to Firebase

**Status:** ✅ **STRICTLY IMPLEMENTED** - Full Firebase authentication with email/password

---

## ✅ 2. Dropdown Menu for User Role Selection

**What it means:** When registering, users can pick their role (like choosing "Student" or "Teacher" from a list).

**How it works in the app:**
- There's a dropdown menu in the registration form
- You can choose: "User (Buyer & Seller)" or "Admin"
- It's like choosing your character type in a game

**Where to find it:**
- `lib/screens/auth/register_screen.dart` lines 361-421
- Uses `DropdownButtonFormField` widget
- Options: `roleUser` and `roleAdmin`

**Status:** ✅ **STRICTLY IMPLEMENTED** - Dropdown menu inside registration form with role selection

---

## ✅ 3. Date Picker and Time Picker in a Form

**What it means:** Users can pick a date and time from a calendar/clock instead of typing it.

**How it works in the app:**
- When checking out, you need to pick when you want your order delivered
- Tap the date field → a calendar pops up → pick your date
- Tap the time field → a clock pops up → pick your time
- It's like setting an alarm on your phone - you pick from a visual calendar and clock!

**Where to find it:**
- `lib/screens/buyer/checkout_screen.dart` lines 48-84
- Uses `flutter_datetime_picker_plus` package
- Date picker: `DatePicker.showDatePicker()`
- Time picker: `DatePicker.showTimePicker()`
- Both are required fields in the checkout form

**Status:** ✅ **STRICTLY IMPLEMENTED** - Both date and time pickers in checkout form

---

## ✅ 4. Forgot Password Functionality

**What it means:** If you forget your password, you can get a reset link sent to your email.

**How it works in the app:**
- On the login screen, there's a "Forgot Password?" link
- Click it → enter your email → Firebase sends you a reset email
- Open the email → click the link → set a new password
- It's like losing your house key and getting a new one sent to your mailbox!

**Where to find it:**
- `lib/screens/auth/forgot_password_screen.dart` - The forgot password page
- `lib/services/auth_service.dart` line 82-94 - `resetPassword()` function
- `lib/screens/auth/login_screen.dart` line 351-364 - Link to forgot password

**Status:** ✅ **STRICTLY IMPLEMENTED** - Full forgot password flow with email reset

---

## ✅ 5. Save and Retrieve Data from MySQL Database Using PHP REST API

**What it means:** The app stores information (like products, orders) in a MySQL database, and uses PHP to send/get that data.

**How it works in the app:**
- MySQL = A big filing cabinet that stores all your data
- PHP = The assistant that goes to the filing cabinet and gets/puts things
- REST API = The way the app talks to PHP (like sending letters back and forth)

**Where to find it:**
- `php-api/controllers/` - All PHP files that handle database operations:
  - `auth.php` - User registration/login
  - `products.php` - Product data
  - `cart.php` - Shopping cart
  - `orders.php` - Orders
- `php-api/config/database.php` - Database connection
- All Flutter services use `ApiService` to call these PHP endpoints

**Status:** ✅ **STRICTLY IMPLEMENTED** - Complete MySQL database with PHP REST API for all operations

---

## ✅ 6. Login and Registration System Using MySQL Backend Through REST API

**What it means:** When you register/login, the app saves your info in MySQL database (not just Firebase).

**How it works in the app:**
- Step 1: Register with Firebase (for authentication)
- Step 2: Save your details (name, role, etc.) to MySQL database via PHP API
- Step 3: When you login, it gets your info from MySQL
- It's like: Firebase checks your ID, MySQL stores your profile card

**Where to find it:**
- `lib/services/auth_service.dart` - Firebase authentication
- `lib/services/user_service.dart` - MySQL operations via API
- `php-api/controllers/auth.php` - PHP endpoints for user data
- Registration flow: `register_screen.dart` lines 43-168

**Status:** ✅ **STRICTLY IMPLEMENTED** - Dual system: Firebase for auth + MySQL for user data via REST API

---

## ✅ 7. Database Schema Design and Documentation

**What it means:** A document that explains how the database is organized (like a map of the filing cabinet).

**How it works in the app:**
- The document shows all tables (users, products, orders, etc.)
- It explains what each table stores and how they connect
- It's like a blueprint of a building - shows all the rooms and how they connect!

**Where to find it:**
- `php-api/DATABASE_SETUP.md` - Complete database schema documentation
- Shows all 5 tables:
  1. `users` - User accounts
  2. `products` - Product listings
  3. `cart_items` - Shopping cart
  4. `orders` - Orders
  5. `order_items` - Items in each order
- Includes SQL commands to create all tables

**Status:** ✅ **STRICTLY IMPLEMENTED** - Well-documented database schema with SQL setup instructions

---

## ✅ 8. Sellers Can Add, Edit, or Delete Products

**What it means:** Sellers (people selling things) can create new products, change existing ones, or remove them.

**How it works in the app:**
- Sellers have a "My Products" page
- Click "+" button → Add new product (fill form)
- Click on a product → Edit it
- Swipe or click delete → Remove product
- It's like managing items in your store - you can add new items, change prices, or remove sold-out items!

**Where to find it:**
- `lib/screens/seller/products_list_screen.dart` - List of seller's products
- `lib/screens/seller/product_form_screen.dart` - Add/Edit product form
- `lib/services/product_service.dart` - Functions to create/update/delete
- `php-api/controllers/products.php` - PHP endpoints (POST, PUT, DELETE)

**Status:** ✅ **STRICTLY IMPLEMENTED** - Full CRUD (Create, Read, Update, Delete) for products

---

## ✅ 9. Products Include Name, Description, Price, Image, and Stock Quantity

**What it means:** Every product must have these 5 pieces of information.

**How it works in the app:**
- **Name:** What the product is called (e.g., "DJI Mavic 3")
- **Description:** Details about the product
- **Price:** How much it costs (e.g., ₱50,000)
- **Image:** A picture of the product
- **Stock Quantity:** How many are available (e.g., 5 units)

**Where to find it:**
- Product form: `lib/screens/seller/product_form_screen.dart`
- Product model: `lib/models/product_model.dart`
- Database table: `products` table in MySQL (see DATABASE_SETUP.md)
- All fields are required/validated in the form

**Status:** ✅ **STRICTLY IMPLEMENTED** - All 5 fields are present and required

---

## ❌ 10. Product Data in MySQL, Images in Firebase Storage (EXCLUDED)

**What it means:** Product information stored in MySQL, but images stored in Firebase Storage.

**Why it's excluded:** 
- Firebase Storage is a **paid service** (costs money after free tier)
- The app uses **local PHP file upload** instead (free!)
- Images are stored in `php-api/uploads/` folder on the server
- This is actually BETTER for a free project!

**Current implementation:**
- Product data: ✅ MySQL database
- Images: ✅ Local PHP upload (not Firebase Storage)
- Image upload: `php-api/controllers/upload.php`
- Image storage: `php-api/uploads/` directory

**Status:** ❌ **NOT IMPLEMENTED** (by design - using free alternative instead)

---

## ✅ 11. Buyers Can Browse Products from Database

**What it means:** Buyers (people shopping) can see all products that sellers added, loaded from the database.

**How it works in the app:**
- Buyers see a "Browse Products" page
- Products are loaded from MySQL database
- Can search by name/description
- Can filter by category
- It's like walking through a store and seeing all items on shelves!

**Where to find it:**
- `lib/screens/buyer/products_browse_screen.dart` - Browse page
- `lib/services/product_service.dart` - `getAllProducts()` function
- `php-api/controllers/products.php` - GET endpoint to fetch products
- Home screen also shows products: `lib/screens/home_screen.dart`

**Status:** ✅ **STRICTLY IMPLEMENTED** - Full product browsing with search and category filters

---

## ✅ 12. Add Products to Cart and Checkout

**What it means:** Buyers can add items to a shopping cart, then buy them all at once.

**How it works in the app:**
- Browse products → Click "Add to Cart" → Item goes to cart
- View cart → See all items and total price
- Click "Checkout" → Fill delivery info → Place order
- It's like shopping at a store: pick items, put in cart, go to checkout counter!

**Where to find it:**
- Cart screen: `lib/screens/buyer/cart_screen.dart`
- Checkout screen: `lib/screens/buyer/checkout_screen.dart`
- Cart service: `lib/services/cart_service.dart`
- Cart provider: `lib/providers/cart_provider.dart`
- PHP endpoints: `php-api/controllers/cart.php` and `orders.php`

**Status:** ✅ **STRICTLY IMPLEMENTED** - Complete cart and checkout system

---

## ✅ 13. Sellers Can View Incoming Orders

**What it means:** Sellers can see all orders that buyers placed for their products.

**How it works in the app:**
- Sellers have a "My Orders" page
- Shows all orders containing their products
- Can see buyer info, items, total, delivery date/time
- It's like a seller seeing all the orders they need to fulfill!

**Where to find it:**
- `lib/screens/seller/seller_orders_screen.dart` - Orders list
- `lib/screens/seller/seller_order_detail_screen.dart` - Order details
- `lib/services/order_service.dart` - `getOrdersBySeller()` function
- PHP endpoint: `php-api/controllers/orders.php` - `bySeller` action

**Status:** ✅ **STRICTLY IMPLEMENTED** - Sellers can view all their incoming orders

---

## ✅ 14. Order Status Can Be Updated (Pending, Shipped, Completed)

**What it means:** Sellers can change the status of orders to show progress.

**How it works in the app:**
- **Pending:** Order just placed, not shipped yet
- **Shipped:** Order is on the way to buyer
- **Completed:** Order delivered successfully
- Sellers use a dropdown to change status
- It's like tracking a package: "Processing" → "Shipped" → "Delivered"!

**Where to find it:**
- `lib/screens/seller/seller_order_detail_screen.dart` lines 146-192
- Status dropdown with 3 options: Pending, Shipped, Completed
- `lib/services/order_service.dart` - `updateOrderStatus()` function
- PHP endpoint: `php-api/controllers/orders.php` - PUT request with status

**Status:** ✅ **STRICTLY IMPLEMENTED** - Full order status management with all 3 statuses

---

## Summary Table

| # | Requirement | Status | Notes |
|---|------------|--------|-------|
| 1 | Firebase Auth (Register/Login) | ✅ | Fully implemented |
| 2 | Role Dropdown in Form | ✅ | In registration form |
| 3 | Date & Time Picker | ✅ | In checkout form |
| 4 | Forgot Password | ✅ | Email reset link |
| 5 | MySQL + PHP REST API | ✅ | All data operations |
| 6 | Login/Reg with MySQL | ✅ | Dual system |
| 7 | Database Schema Docs | ✅ | DATABASE_SETUP.md |
| 8 | Seller CRUD Products | ✅ | Add/Edit/Delete |
| 9 | Product Fields | ✅ | All 5 fields present |
| 10 | Firebase Storage | ❌ | Using free PHP upload instead |
| 11 | Browse Products | ✅ | With search/filter |
| 12 | Cart & Checkout | ✅ | Complete flow |
| 13 | Seller View Orders | ✅ | All incoming orders |
| 14 | Update Order Status | ✅ | Pending/Shipped/Completed |

---

## 🎉 Conclusion

**13 out of 14 requirements are strictly implemented!**

The only exception is Firebase Storage (#10), which was intentionally replaced with a free PHP file upload system. This is actually a better solution for a free/open-source project!

All other requirements are fully functional and working. 🚀

