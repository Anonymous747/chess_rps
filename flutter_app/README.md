# Chess RPS - Flutter Mobile Application

A cross-platform chess game application built with Flutter, featuring Rock Paper Scissors mechanics integrated into chess gameplay.

## Prerequisites

- **Flutter SDK**: 3.0.6 or higher
- **Dart SDK**: 3.0.6 or higher
- **Platform-specific requirements** (see below)

### Platform-Specific Requirements

#### Android
- Android Studio or Android SDK
- JDK 11 or higher
- Android SDK (minimum SDK version: 21)

#### iOS
- macOS with Xcode
- CocoaPods (`sudo gem install cocoapods`)
- iOS Simulator or physical device

#### Web
- Chrome (recommended for development)

#### Windows
- Visual Studio with C++ development tools
- Windows 10/11 SDK

#### Linux
- CMake
- GTK development libraries
- pkg-config

#### macOS
- Xcode
- CocoaPods

## Getting Started

### Installation

1. **Clone the repository** (if not already done):
   ```bash
   git clone <repository-url>
   cd chess_rps/flutter_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run code generation** (required for Riverpod, Freezed, JSON serialization):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Running the App

#### Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run in debug mode with hot reload
flutter run --debug

# Run in release mode (faster performance)
flutter run --release
```

#### Platform-Specific Run Commands

**Android:**
```bash
flutter run -d android
# Or specify an Android device
flutter run -d <android-device-id>
```

**iOS:**
```bash
flutter run -d ios
# Or specify an iOS device/simulator
flutter run -d <ios-device-id>
```

**Web:**
```bash
flutter run -d chrome
# Or
flutter run -d web-server --web-port 8080
```

**Windows:**
```bash
flutter run -d windows
```

**Linux:**
```bash
flutter run -d linux
```

**macOS:**
```bash
flutter run -d macos
```

## Building the Application

### Android

#### APK (Android Package)

**Debug APK:**
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

**Release APK:**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Split APKs by ABI (smaller file size):**
```bash
flutter build apk --split-per-abi
```
Output: Multiple APKs in `build/app/outputs/flutter-apk/`:
- `app-armeabi-v7a-release.apk`
- `app-arm64-v8a-release.apk`
- `app-x86_64-release.apk`

#### App Bundle (for Google Play Store)

**Release App Bundle:**
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

**Note**: App bundles are required for publishing to Google Play Store.

### iOS

#### Build for Simulator

```bash
flutter build ios --simulator
```

#### Build for Device

```bash
# Build iOS app
flutter build ios --release

# Then open in Xcode for signing and archiving
open ios/Runner.xcworkspace
```

**Xcode Steps:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your development team in Signing & Capabilities
3. Product → Archive
4. Distribute App (for App Store or Ad Hoc distribution)

**Note**: iOS builds require macOS and Xcode. You cannot build iOS apps on Windows or Linux.

### Web

#### Development Build

```bash
flutter build web
```
Output: `build/web/`

**With release optimizations:**
```bash
flutter build web --release
```

**Host the web app:**
```bash
# Using Python's HTTP server
cd build/web
python -m http.server 8000

# Or using Flutter's built-in server
flutter run -d chrome --web-port 8080
```

**Deploy to hosting:**
- Copy contents of `build/web/` to your web server
- Configure your server to serve `index.html` for all routes (for Flutter web routing)

### Windows

#### Build Executable

**Debug build:**
```bash
flutter build windows --debug
```
Output: `build/windows/x64/runner/Debug/`

**Release build:**
```bash
flutter build windows --release
```
Output: `build/windows/x64/runner/Release/chess_rps.exe`

**Create installer:**
- Use tools like Inno Setup or NSIS to create an installer from the release build

### Linux

#### Build Application

**Debug build:**
```bash
flutter build linux --debug
```
Output: `build/linux/x64/debug/bundle/`

**Release build:**
```bash
flutter build linux --release
```
Output: `build/linux/x64/release/bundle/`

**Create AppImage or Snap:**
- Use tools like `linuxdeploy` or `snapcraft` to package the release build

### macOS

#### Build Application

**Debug build:**
```bash
flutter build macos --debug
```
Output: `build/macos/Build/Products/Debug/chess_rps.app`

**Release build:**
```bash
flutter build macos --release
```
Output: `build/macos/Build/Products/Release/chess_rps.app`

**Create DMG or distribute:**
- Use Xcode or tools like `create-dmg` to create distribution packages

## Build Configuration

### Environment Variables

The app may use environment variables for configuration. Check `lib/common/endpoint.dart` for backend endpoint configuration.

### Code Signing

#### Android

1. **Create a keystore** (if you don't have one):
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Create `android/key.properties`**:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

3. **Update `android/app/build.gradle`** to use the keystore (see Flutter documentation)

#### iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target
3. Go to Signing & Capabilities
4. Select your development team
5. For release builds, configure automatic signing or use manual signing

## Build Flags and Options

### Common Build Options

```bash
# Build with specific flavor (if configured)
flutter build apk --flavor production --release

# Build with specific target file
flutter build apk --target lib/main_prod.dart

# Build with specific build number
flutter build apk --build-number=2

# Build with specific version name
flutter build apk --build-name=1.0.1

# Build without tree-shaking (for debugging)
flutter build apk --no-tree-shake-icons

# Build with verbose output
flutter build apk --verbose
```

### Performance Optimizations

**Release builds automatically include:**
- Tree-shaking (removes unused code)
- Minification
- Obfuscation (for Dart code)
- Asset optimization

**Enable obfuscation explicitly:**
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/coordinate_conversion_test.dart

# Run tests in watch mode
flutter test --watch
```

### Code Generation

If you modify models, providers, or other generated code:

```bash
# Generate code once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate automatically
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Troubleshooting

### Common Build Issues

**"No devices found":**
```bash
# Check available devices
flutter devices

# For Android, ensure emulator is running or device is connected
# For iOS, ensure simulator is running
```

**Build errors related to dependencies:**
```bash
# Clean and reinstall dependencies
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Android build errors:**
```bash
# Clean Android build
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**iOS build errors:**
```bash
# Clean iOS build
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

**Web build errors:**
```bash
# Clear Flutter web cache
flutter clean
flutter pub get
```

### Platform-Specific Issues

**Android:**
- Ensure `minSdkVersion` in `android/app/build.gradle` matches your target
- Check that all required permissions are declared in `AndroidManifest.xml`

**iOS:**
- Ensure CocoaPods are up to date: `pod repo update`
- Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Check `ios/Podfile` for any configuration issues

**Web:**
- Ensure Chrome is up to date
- Check browser console for errors
- Verify CORS settings if connecting to a backend API

**Windows/Linux:**
- Ensure all required build tools are installed
- Check that Visual Studio (Windows) or development libraries (Linux) are properly installed

## Project Structure

```
flutter_app/
├── lib/
│   ├── common/          # Shared utilities and constants
│   ├── data/            # Data layer (services, repositories)
│   ├── domain/          # Business logic and models
│   ├── presentation/    # UI layer (screens, widgets, controllers)
│   └── main.dart        # Application entry point
├── assets/              # Images, fonts, and other assets
├── android/             # Android platform-specific code
├── ios/                 # iOS platform-specific code
├── web/                 # Web platform-specific code
├── windows/             # Windows platform-specific code
├── linux/               # Linux platform-specific code
├── macos/               # macOS platform-specific code
├── test/                # Unit and widget tests
└── pubspec.yaml         # Dependencies and project configuration
```

## Dependencies

Key dependencies:
- **Riverpod**: State management
- **Flutter Hooks**: Reactive hooks for Flutter
- **Go Router**: Navigation
- **Dio**: HTTP client
- **Web Socket Channel**: WebSocket support
- **Stockfish**: Chess engine integration
- **Freezed**: Immutable classes and unions
- **JSON Serializable**: JSON serialization

See `pubspec.yaml` for the complete list of dependencies.

## Development Workflow

1. **Make code changes**
2. **Run code generation** (if needed):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```
4. **Test changes** using hot reload (press `r` in terminal) or hot restart (`R`)
5. **Run tests**:
   ```bash
   flutter test
   ```
6. **Build for release** when ready to deploy

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev/)
- [Project Backend Documentation](../BACKEND.md)
- [Project DevOps Documentation](../DEVOPS.md)

## License

[Add your license information here]

