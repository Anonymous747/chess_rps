# Flutter Flavors Configuration

This project uses Flutter flavors to support different backend environments:
- **dev**: Development environment using localhost backend
- **prod**: Production environment using gamerbot.pro backend

## Quick Start

### Running the App

#### Using Android Studio (Recommended)

The project includes pre-configured run configurations in the `.run` folder. Simply:
1. Open the project in Android Studio
2. Select the desired configuration from the run configuration dropdown:
   - **Dev (Debug)** - Development with localhost backend, debug mode
   - **Dev (Release)** - Development with localhost backend, release mode
   - **Prod (Debug)** - Production with gamerbot.pro backend, debug mode
   - **Prod (Release)** - Production with gamerbot.pro backend, release mode
3. Click Run (▶️) or press `Shift+F10`

#### Using Command Line

**Development (localhost):**
```bash
# Windows
scripts\run_dev.bat

# Linux/Mac
./scripts/run_dev.sh

# Or manually:
flutter run --dart-define=ENV=dev --flavor dev
```

**Production (gamerbot.pro):**
```bash
# Windows
scripts\run_prod.bat

# Linux/Mac
./scripts/run_prod.sh

# Or manually:
flutter run --dart-define=ENV=prod --flavor prod
```

### Building APKs

**Development:**
```bash
# Windows
scripts\build_dev.bat

# Linux/Mac
./scripts/build_dev.sh

# Or manually:
flutter build apk --dart-define=ENV=dev --flavor dev --release
```

**Production:**
```bash
# Windows
scripts\build_prod.bat

# Linux/Mac
./scripts/build_prod.sh

# Or manually:
flutter build apk --dart-define=ENV=prod --flavor prod --release
```

## Backend Configuration

### Dev Environment (localhost)

The dev flavor uses `http://10.0.2.2:8000` by default (for Android emulator).

**For different platforms:**
- **Android Emulator**: `10.0.2.2:8000` (default)
- **iOS Simulator**: Use `localhost:8000` by running:
  ```bash
  flutter run --dart-define=ENV=dev --dart-define=BACKEND_HOST=localhost:8000 --flavor dev
  ```
- **Physical Device**: Use your computer's IP address:
  ```bash
  flutter run --dart-define=ENV=dev --dart-define=BACKEND_HOST=192.168.1.100:8000 --flavor dev
  ```

### Prod Environment

The prod flavor uses `https://gamerbot.pro` (production server with HTTPS).

## How It Works

1. **Environment Variable**: The `ENV` variable is passed via `--dart-define=ENV=dev` or `--dart-define=ENV=prod`
2. **Endpoint Configuration**: `lib/common/endpoint.dart` reads the `ENV` variable and sets the appropriate backend URL
3. **Android Flavors**: The `build.gradle` file defines `dev` and `prod` flavors with different application IDs
4. **App Name**: Dev flavor shows "Chess RPS Dev" in the app launcher, prod shows "Chess RPS"
5. **Android Studio Configurations**: The `.run` folder contains pre-configured run configurations for easy switching between flavors

## Android Flavors

The Android app has two flavors configured:
- **dev**: Application ID suffix `.dev`, version name suffix `-dev`
- **prod**: Standard application ID and version

This allows both flavors to be installed simultaneously on the same device.

## Troubleshooting

### Backend Connection Issues (Dev)

If you can't connect to localhost backend:
1. Ensure your backend server is running on port 8000
2. For Android emulator, verify you're using `10.0.2.2:8000`
3. For iOS simulator, try `localhost:8000`
4. For physical devices, use your computer's local IP address and ensure both devices are on the same network

### Build Errors

If you encounter build errors:
1. Clean the build: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Try building again with the flavor flags

