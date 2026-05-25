# Transaccional App

A modern Flutter application designed for shift management, access logging, and user authentication.

## Features

- **Google Sign-In**: Secure and seamless authentication using Google accounts.
- **QR Code Integration**: 
  - Scan QR codes using `mobile_scanner`.
  - Generate QR codes using `qr_flutter`.
- **Shift & Access Log Management**: Track and manage user access logs and shifts.
- **State Management**: Uses `provider` for simple and scalable state management.
- **API Integration**: Connects to remote data sources using `http`.
- **Internationalization & Formatting**: Uses `intl` for date and number formatting.

## Prerequisites

- Flutter SDK (>= 3.5.4)
- Dart SDK
- Android Studio or Xcode (for iOS development)

## Getting Started

1. **Clone the repository** (if you haven't already).
2. **Navigate to the app directory**:
   ```bash
   cd /Users/adriang/Desktop/Adri/9no/transaccional/app
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the app**:
   ```bash
   flutter run
   ```

## Project Structure

The project follows a feature-driven architecture. For example, access log management and remote data sources can be found under `lib/features/shifts/data/datasources/`.

## Key Dependencies

- [provider](https://pub.dev/packages/provider) - State management
- [http](https://pub.dev/packages/http) - Network requests
- [google_sign_in](https://pub.dev/packages/google_sign_in) - Authentication
- [qr_flutter](https://pub.dev/packages/qr_flutter) - QR code generation
- [mobile_scanner](https://pub.dev/packages/mobile_scanner) - QR code scanning
- [intl](https://pub.dev/packages/intl) - Formatting dates and numbers
