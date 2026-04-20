# Uber Passenger App

A Flutter application for passengers — the companion app to the [Uber Driver App](https://github.com/NajamL96/uber-driver-app).

## Features

- User registration & login (Firebase Auth + Google Sign-In + Facebook Auth)
- Search pickup & dropoff locations with Places Autocomplete
- Real-time map showing nearby available drivers (GeoFire)
- Request a ride and get matched with the nearest driver
- Live driver tracking on the map
- Fare estimation before booking
- Payment screen
- Trip history
- Rate your driver
- Multi-language support (i18n)
- Push notifications for ride status updates

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| Auth | Firebase Authentication |
| Database | Firebase Realtime Database + Cloud Firestore |
| Maps | Google Maps Flutter |
| Location | Geolocator + GeoFire |
| Notifications | Firebase Cloud Messaging |
| Payments | Flutter Stripe |
| State Management | Provider |
| i18n | Flutter Localizations |

## Getting Started

### Prerequisites

- Flutter SDK `>=2.16.2 <3.0.0`
- A Firebase project (same project as the driver app)
- Google Maps API key with the following APIs enabled:
  - Maps SDK for Android / iOS
  - Directions API
  - Geocoding API
  - Places API
- Stripe account (for payments)

### Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/NajamL96/uber-passenger-app.git
   cd uber-passenger-app
   ```

2. **Add Firebase config files** (not included — create your own Firebase project)
   - Android: place `google-services.json` at `android/app/google-services.json`
   - iOS: place `GoogleService-Info.plist` at `ios/Runner/GoogleService-Info.plist`

3. **Add your Google Maps API key**

   Create `lib/global/map_key.dart`:
   ```dart
   String mapKey = "YOUR_GOOGLE_MAPS_API_KEY";
   ```

   Also add the key to:
   - Android: `android/app/src/main/AndroidManifest.xml` — replace `YOUR_GOOGLE_MAPS_API_KEY`
   - iOS: `ios/Runner/AppDelegate.swift` or `Info.plist`

4. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

5. **Install Firebase Functions dependencies** (optional)
   ```bash
   cd functions && npm install
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── assistants/         # Helper methods (map logic, geofire, API calls)
├── authentication/     # Login & registration screens
├── global/             # Global variables & map key
├── l10n/               # Localization files
├── mainScreens/        # Main app screens (search, map, payment, history, etc.)
├── models/             # Data models
├── push_notifications/ # FCM notification handler
├── splashScreen/       # Splash screen
├── tabPages/           # Bottom tab pages
├── widgets/            # Reusable UI widgets
└── main.dart
functions/              # Firebase Cloud Functions
```

## Related

- [Uber Driver App](https://github.com/NajamL96/uber-driver-app) — the driver-side companion app

## License

This project is for educational purposes.
