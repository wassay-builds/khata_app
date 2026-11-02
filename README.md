# Khata App

A digital *khata* (ledger) built with Flutter and Firebase. The admin gives each user a balance, for example a daily allowance. Users spend it ordering items, and the admin manages the products, tracks every balance and settles accounts.

## Features

**Users**
- Sign in with Google
- Browse available products, pick quantities and add them to a cart
- Place orders that are paid from their balance (orders larger than the balance are blocked)
- Follow order status under *My Orders*
- See their remaining balance update live

**Admin**
- Admin dashboard with every user's balance
- Add a daily amount to all users at once, or assign an amount to one user
- Edit a user's balance, or mark it as paid to clear it
- Add, edit and delete products, and toggle whether each one is available
- See incoming orders and mark them as done

Every balance change is also written to a `transactions` collection, so there is a full history of credits, edits and payments.

## Tech stack

- **Flutter** and **Dart**
- **GetX** for state management and navigation
- **Firebase Auth** with **Google Sign-In**
- **Cloud Firestore** with real-time listeners for products, balances and orders

## Project structure

```
khata_app/lib
├── controller/
│   ├── auth/          # auth, admin and user controllers
│   └── product/       # product CRUD
├── models/            # ProductModel
├── screens/
│   ├── admin/         # admin dashboard
│   ├── product/       # product management
│   ├── user/          # user dashboard and orders
│   └── login_view.dart
├── auth_services.dart # Google sign-in and user documents
└── main.dart
```

## Firestore collections

| Collection | Holds |
|---|---|
| `users` | email, `isAdmin` flag and current `balance` |
| `products` | name, price and availability |
| `orders` | the user's items, total, status (`pending` / `done`) and time |
| `transactions` | every credit, edit and payment |

## Getting started

1. Create a Firebase project and enable **Google** sign-in under Authentication.
2. Add your Android and iOS apps in Firebase and place `google-services.json` and `GoogleService-Info.plist` in the usual folders.
3. Set the admin email in `lib/controller/auth/auth_controller.dart`.
4. Run the app:

```bash
cd khata_app
flutter pub get
flutter run
```

---

Built by [Muhammad Abdul Wassay](https://github.com/wassay-builds)
