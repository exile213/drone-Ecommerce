# Database Setup Fix

## The Error

You're getting: `Database connection failed`

This means either:
1. MySQL is not running in Laragon
2. Database `drone_ecommerce` doesn't exist
3. Wrong database credentials

## Quick Fix

### Step 1: Check Laragon MySQL is Running

1. Open Laragon
2. Check if MySQL shows **green/running**
3. If not, click "Start All" or start MySQL manually

### Step 2: Create Database

**Option A: Using phpMyAdmin (Easiest)**
1. Open browser: `http://localhost/phpmyadmin`
2. Click "New" in left sidebar
3. Database name: `drone_ecommerce`
4. Collation: `utf8mb4_unicode_ci`
5. Click "Create"

**Option B: Using SQL Command**
1. Open Laragon terminal (or MySQL command line)
2. Run:
```sql
CREATE DATABASE IF NOT EXISTS drone_ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Step 3: Create Tables

After creating database, run this SQL in phpMyAdmin:

```sql
USE drone_ecommerce;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firebase_uid VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    category VARCHAR(100) NOT NULL,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Cart items table
CREATE TABLE IF NOT EXISTS cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (user_id, product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    delivery_date DATE NOT NULL,
    delivery_time TIME NOT NULL,
    delivery_address TEXT NOT NULL,
    status ENUM('pending', 'shipped', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Step 4: Check Database Credentials

If you changed MySQL password in Laragon, update `config/database.php`:

```php
private $username = 'root';
private $password = 'YOUR_PASSWORD_HERE'; // Update if you changed it
```

Default Laragon: password is empty (leave as `''`)

### Step 5: Test Again

1. Make sure MySQL is running (green in Laragon)
2. Test API: `http://localhost/ecommercephp-api/controllers/auth.php?action=getUser&firebase_uid=test`
3. Should see JSON response (even if error, that's OK - means connection works!)

## Still Getting Error?

1. **Check MySQL is running**: Laragon should show green MySQL icon
2. **Check database exists**: Go to phpMyAdmin, see if `drone_ecommerce` is in the list
3. **Check credentials**: Default Laragon uses `root` with empty password
4. **Check Laragon port**: Default is 3306, but check if yours is different

## Quick Test

Run this in browser to test connection:
```
http://localhost/ecommercephp-api/controllers/auth.php?action=getUser&firebase_uid=test
```

If you see JSON (even with error message), connection is working!
If you see "Database connection failed", MySQL is not running or database doesn't exist.

