# Point of Sale — Flutter App

A fully-featured mobile **Point of Sale (POS)** system built with Flutter and Firebase. Designed for small businesses to manage products, generate bills, track daily sales, and print receipts via Bluetooth thermal printer.

---

## Features

### Authentication
- Email/Password login & registration with full error handling
- Google Sign-In
- Forgot password via email reset
- Auto-login on app relaunch (session persisted)

### Dashboard
- Today's revenue with animated counter
- Invoice count for the day
- Payment breakdown — Cash / Online / Card (each with live counter)
- Pull-to-refresh

### Product Management
- Add products via URL (`new-upload`) or Camera (`New-Items` — uploads to Firebase Storage)
- View all products in a grid (`My Store`)
- Delete products with confirmation dialog

### Bill Generation
- Browse & search products
- Add items to cart with quantity tracking
- Cart badge shows per-item quantity
- Payment method selection (Cash / Online / Card)
- Prints receipt + KOT via Bluetooth thermal printer (ESC/POS)
- Bill saved to Firestore on successful print

### Receipts
- Full receipt history screen with date picker
- Expandable receipt cards showing itemized breakdown

### Printer Settings
- Bluetooth MAC address stored in SharedPreferences
- Auto-connects to printer on dashboard load

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart ≥ 3.1.5, Material 3) |
| Backend | Firebase (Auth, Firestore, Storage) |
| Auth | Firebase Auth + Google Sign-In |
| Animations | flutter_animate ^4.5.0 |
| Printing | esc_pos_utils_plus, print_bluetooth_thermal |
| Local Storage | shared_preferences |
| Charts | pie_chart |
| Image Picker | image_picker, file_picker |

---

## Project Structure

```
lib/
├── main.dart                        # App entry, theme, splash
├── firebase_options.dart            # Firebase config
├── theme/
│   └── app_theme.dart               # AppColors, AppTheme, GradientButton
├── Backend/
│   └── Google-Services.dart         # Google Sign-In logic
├── Frontend/UX/
│   └── textField.dart               # Reusable text field widgets
└── Screen/
    ├── Splash/
    │   └── splash_screen.dart       # Animated splash + auto-login
    ├── DashBoard/
    │   ├── login-page.dart
    │   ├── SignUp.dart
    │   ├── dashboard.dart
    │   └── Forget-Password.dart
    ├── Invoice-Generator/
    │   ├── Billing.dart             # Product selection screen
    │   └── cart.dart                # Checkout + print
    ├── Products-Section/
    │   ├── MyStore.dart             # View/delete products
    │   ├── new-upload.dart          # Add product via URL
    │   └── New-Items.dart           # Add product via camera
    ├── Receipts/
    │   └── receipts.dart            # Receipt history
    └── MenuDrawer/
        └── MenuDrawer.dart          # Side navigation drawer
```

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.1.5
- A Firebase project with **Auth**, **Firestore**, and **Storage** enabled
- Android device or emulator (Bluetooth printing is Android-only)

### Setup

1. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd pos
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Add an Android app and download `google-services.json` → place in `android/app/`
   - Enable Email/Password and Google sign-in providers in Firebase Auth
   - Enable Firestore and Firebase Storage

4. **Run the app**
   ```bash
   flutter run
   ```

---

## Firestore Data Structure

```
Users/
  {uid}/
    name: string

Products/
  {uid}/
    Products1/
      {docId}/
        Name: string
        Price: string
        Url: string

Receipt/
  {uid}/
    {DD-MM-YYYY}/
      {receiptId}/
        Receipt id: int
        Items: [string]
        Quantity: [int]
        Price: [dynamic]
        Mode of Payment: string   // "Cash" | "Online" | "Card"
        Total: int
        Bill Time: string
```

---

## UI Highlights

- **Animated Splash Screen** — pulsing glow rings, Hero logo transition, staggered text fade-in
- **Dark Gradient Theme** — deep indigo-to-purple header across all screens
- **Counter Animations** — `TweenAnimationBuilder<int>` on all sales figures
- **Staggered Entry** — every list/grid animates in with per-index delays
- **Hero Transition** — logo shared between splash and login screens
- **AnimatedSwitcher** — smooth quantity and total updates in cart

---

## Known Limitations

- Bluetooth printing is Android-only
- Sales Analysis, History, and About Us screens are placeholders (coming soon)
- No multi-user / role-based access control

---

## License

This project was developed as a final year project by students of RC Technical Institute.
