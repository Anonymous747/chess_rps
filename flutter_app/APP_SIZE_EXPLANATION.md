# Why is the app size so large?

## The Problem

When you build with `flutter build apk --release`, you get a **universal APK** that includes:
- All CPU architectures (armeabi-v7a, arm64-v8a, x86_64)
- All native libraries for each architecture
- The Flutter engine
- Your app code and assets

This results in **~279MB** because it contains 3 copies of native libraries (one per architecture).

## Main Contributors to App Size

1. **Stockfish Chess Engine** (~50-70MB per architecture)
   - Native C++ chess engine library
   - Essential for AI gameplay
   - Included for each CPU architecture

2. **Flutter Engine** (~40-50MB per architecture)
   - The core Flutter runtime
   - Required for all Flutter apps

3. **Multiple Architectures in Universal APK**
   - armeabi-v7a (32-bit ARM)
   - arm64-v8a (64-bit ARM)
   - x86_64 (64-bit x86)

## The Solution: Split APKs

Instead of one universal APK, build separate APKs for each architecture:

```bash
flutter build apk --split-per-abi --release
```

This creates:
- `app-armeabi-v7a-release.apk` (~91.8 MB) - Older Android devices
- `app-arm64-v8a-release.apk` (~94.3 MB) - Most modern devices (95%+)
- `app-x86_64-release.apk` (~95.5 MB) - Emulators and some tablets

**Result: ~66% size reduction** (279MB → ~94MB per device)

## Which APK to Use?

- **For most users**: Use `app-arm64-v8a-release.apk` (94.3 MB)
  - Works on 95%+ of modern Android devices (Android 5.0+)
  - This is what most users will download from Play Store

- **For older devices**: Use `app-armeabi-v7a-release.apk` (91.8 MB)
  - For devices running 32-bit ARM processors

- **For testing/emulators**: Use `app-x86_64-release.apk` (95.5 MB)

## For Google Play Store

**Recommended**: Use App Bundle instead of APK:

```bash
flutter build appbundle
```

App Bundles allow Google Play to:
- Automatically serve the correct APK per device
- Further optimize download size
- Generate device-specific APKs on demand

## Optimizations Already Applied

✅ Code shrinking (`minifyEnabled true`)
✅ Resource shrinking (`shrinkResources true`)
✅ ProGuard/R8 optimization
✅ Font tree-shaking (removes unused icons)
✅ Split APKs by architecture

## Why Can't We Make It Smaller?

The Stockfish chess engine is a large native library (~50-70MB). This is unavoidable if you need:
- Strong AI gameplay
- Local chess engine processing
- Offline AI capabilities

**Alternatives** (if size is critical):
- Use a smaller chess engine (weaker AI)
- Make Stockfish a downloadable add-on
- Use cloud-based chess engine (requires internet)

## Summary

- **Universal APK**: 279MB (all architectures)
- **Split APKs**: ~94MB per architecture (**USE THIS!**)
- **App Bundle**: Best for Play Store distribution

**Always use `--split-per-abi` flag for production builds!**

