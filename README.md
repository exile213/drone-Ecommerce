# Drone E-Commerce Flutter App

A Flutter mobile e-commerce application for buying and selling drone products, featuring Firebase Authentication and MySQL backend via PHP REST API.

## Architecture

- **Frontend**: Flutter (Android & iOS)
- **Authentication**: Firebase Authentication
- **Backend**: PHP REST API (Laragon)
- **Database**: MySQL

## Features

✅ User Registration & Login (Firebase Auth)
✅ Role Selection (Admin/User)
✅ Product Management (CRUD) for Sellers
✅ Product Browsing & Search for Buyers
✅ Shopping Cart
✅ Checkout with Date/Time Picker
✅ Order Management
✅ Order Status Updates
✅ Image Upload

## User Roles

The app uses a hybrid role system:

- **Admin**: Full admin dashboard access with ability to manage all products, orders, and users. Can also browse and purchase products.
- **User (Buyer & Seller)**: Hybrid role that allows users to:
  - **Act as Buyer**: Browse products, add to cart, checkout, view their orders
  - **Act as Seller**: Add/edit/delete products, view incoming orders, update order status

This design is more realistic for a marketplace where users can both buy and sell products with a single account.

## Quick Start

### Prerequisites

- Flutter SDK installed
- Firebase project created
- Laragon (or similar PHP/MySQL server) installed
- MySQL database `drone_ecommerce` created

### Setup Steps

1. **Firebase Setup**:
   - Enable Authentication in Firebase Console
   - Download `google-services.json` → place in `android/app/`
   - Download `GoogleService-Info.plist` → place in `ios/Runner/`
   - Run `flutterfire configure` (optional, if needed)

2. **Laragon/PHP Setup**:
   - Start Laragon (Apache + MySQL)
   - Create API folder: `C:\laragon\www\ecommercephp-api\`
   - Create database: `drone_ecommerce`
   - Create database tables (see SQL in setup guide)
   - Create PHP API controllers

3. **Flutter Setup**:
   ```bash
   flutter pub get
   ```

4. **Run App**:
   ```bash
   flutter run
   ```

## Documentation

- **[SETUP_AND_RUN_GUIDE.md](SETUP_AND_RUN_GUIDE.md)** - Complete step-by-step setup instructions
- **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Testing scenarios and instructions
- **[VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md)** - Verification checklist
- **[SETUP_FIREBASE.md](SETUP_FIREBASE.md)** - Firebase-specific setup
- **[SETUP_LARAGON.md](SETUP_LARAGON.md)** - Laragon-specific setup

## API Configuration

The app automatically detects platform for API URLs:
- **Android Emulator**: `http://10.0.2.2/ecommercephp-api`
- **iOS Simulator**: `http://localhost/ecommercephp-api`
- **Physical Device**: Configure with your computer's IP address

## Project Structure

```
lib/
├── models/          # Data models (User, Product, Order, Cart)
├── services/        # API services (Auth, Product, Cart, Order, Storage)
├── screens/         # UI screens (Auth, Buyer, Seller)
├── providers/       # State management (Auth, Cart)
└── utils/           # Constants and utilities
```

## Testing

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for complete testing scenarios.

## Troubleshooting

See [SETUP_AND_RUN_GUIDE.md](SETUP_AND_RUN_GUIDE.md) troubleshooting section.

## License

This project is for educational purposes.
