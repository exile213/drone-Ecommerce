# PHP API Files for Drone E-Commerce

## Installation Instructions

These PHP files need to be copied to your Laragon server.

### Step 1: Copy Files to Laragon

1. Copy the entire `php-api` folder contents to:
   ```
   C:\laragon\www\ecommercephp-api\
   ```

2. Your folder structure should be:
   ```
   C:\laragon\www\ecommercephp-api\
   ├── config/
   │   └── database.php
   ├── controllers/
   │   ├── auth.php
   │   ├── products.php
   │   ├── cart.php
   │   ├── orders.php
   │   └── upload.php
   └── uploads/
       (empty folder for image uploads)
   ```

### Step 2: Configure Database

1. Open `config/database.php`
2. Update database credentials if needed:
   - Default Laragon: username = `root`, password = `` (empty)
   - If you changed MySQL password, update it here

### Step 3: Set Uploads Folder Permissions

1. Right-click `uploads/` folder
2. Properties → Security
3. Give "Write" permissions to "Everyone" or your web server user

### Step 4: Verify Database Exists

Make sure you've created the `drone_ecommerce` database and all tables (see SETUP_AND_RUN_GUIDE.md).

### Step 5: Test API

1. Start Laragon (Apache + MySQL should be running)
2. Test in browser: `http://localhost/ecommercephp-api/controllers/auth.php?action=getUser&firebase_uid=test`
   - Should return JSON (even if user not found, that's OK - means API is working)

## API Endpoints

### Authentication
- `POST /controllers/auth.php?action=register` - Register user
- `POST /controllers/auth.php?action=login` - Login user
- `GET /controllers/auth.php?action=getUser&firebase_uid=xxx` - Get user by Firebase UID

### Products
- `GET /controllers/products.php` - Get all products
- `GET /controllers/products.php?id=1` - Get product by ID
- `GET /controllers/products.php?action=bySeller&seller_id=1` - Get seller's products
- `POST /controllers/products.php` - Create product
- `PUT /controllers/products.php` - Update product
- `DELETE /controllers/products.php?id=1` - Delete product

### Cart
- `GET /controllers/cart.php?action=byUser&user_id=1` - Get user's cart
- `POST /controllers/cart.php` - Add to cart
- `PUT /controllers/cart.php` - Update cart item
- `DELETE /controllers/cart.php?id=1` - Remove from cart

### Orders
- `POST /controllers/orders.php` - Create order
- `GET /controllers/orders.php?action=byUser&user_id=1` - Get user's orders
- `GET /controllers/orders.php?action=bySeller&seller_id=1` - Get seller's orders
- `GET /controllers/orders.php?id=1` - Get order by ID
- `PUT /controllers/orders.php?action=updateStatus` - Update order status

### Upload
- `POST /controllers/upload.php` - Upload image (multipart/form-data)
- `DELETE /controllers/upload.php?filename=xxx` - Delete image

## Troubleshooting

### 404 Errors
- Make sure files are in correct location: `C:\laragon\www\ecommercephp-api\`
- Check Apache is running in Laragon
- Verify folder structure matches exactly

### Database Connection Errors
- Check MySQL is running in Laragon
- Verify database `drone_ecommerce` exists
- Check credentials in `config/database.php`

### Image Upload Errors
- Check `uploads/` folder has write permissions
- Verify folder exists
- Check PHP `upload_max_filesize` in php.ini

### CORS Errors
- All files have CORS headers set
- If still getting errors, check browser console for specific message

