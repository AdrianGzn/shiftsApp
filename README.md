# Transaccional App

A modern Flutter application designed for shift management, access logging, visitor management, and user authentication.

## Features

- **Authentication**: Secure and seamless authentication using Google accounts (`google_sign_in`).
- **Shift & Access Log Management**: Track and manage user access logs and shifts.
- **Visitor Management & QR Codes**: 
  - Manage visitor access.
  - Scan QR codes using `mobile_scanner`.
  - Generate QR codes using `qr_flutter`.
- **Organization & User Profiles**: Manage organization details and user profiles.
- **State Management**: Uses `provider` for simple and scalable state management.
- **API Integration**: Connects to remote data sources using `http`.
- **Internationalization & Formatting**: Uses `intl` for date and number formatting.

## Prerequisites

- Flutter SDK (>= 3.5.4)
- Dart SDK
- Android Studio or Xcode (for iOS development)


## Project Structure

The project follows a clean, feature-driven architecture. The main features are located under `lib/features/`:

- `auth/`: Authentication logic and UI.
- `home/`: Main dashboard.
- `organization/`: Organization details management.
- `shifts/`: Shift schedules and access log management.
- `user/`: User profile management.
- `visitors/`: Visitor access and QR generation/scanning.

## Key Dependencies

- [provider](https://pub.dev/packages/provider) - State management
- [http](https://pub.dev/packages/http) - Network requests
- [google_sign_in](https://pub.dev/packages/google_sign_in) - Authentication
- [qr_flutter](https://pub.dev/packages/qr_flutter) - QR code generation
- [mobile_scanner](https://pub.dev/packages/mobile_scanner) - QR code scanning
- [intl](https://pub.dev/packages/intl) - Formatting dates and numbers
