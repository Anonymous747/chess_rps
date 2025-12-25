import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/widget/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  AppLogger.info('Starting Chess RPS application', tag: 'Main');
  runApp(
    const ProviderScope(
      child: Root(),
    ),
  );
}

class Root extends ConsumerStatefulWidget {
  const Root({Key? key}) : super(key: key);

  @override
  ConsumerState<Root> createState() => _RootState();
}

class _RootState extends ConsumerState<Root> {
  bool _showLoadingScreen = true;

  @override
  void initState() {
    super.initState();
    // Ensure loading screen shows for at least 1.5 seconds after native splash
    // This gives time for the native splash to transition smoothly to Flutter loading screen
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showLoadingScreen = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authControllerProvider);
    
    // Show loading screen if auth is loading OR if minimum display time hasn't passed
    final shouldShowLoading = _showLoadingScreen || authState.isLoading;
    
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Palette.accent,
        scaffoldBackgroundColor: Palette.background,
        colorScheme: ColorScheme.dark(
          primary: Palette.accent,
          secondary: Palette.purpleAccent,
          surface: Palette.backgroundTertiary,
          error: Palette.error,
          onPrimary: Palette.textPrimary,
          onSecondary: Palette.textPrimary,
          onSurface: Palette.textPrimary,
          onError: Palette.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Palette.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Palette.accent,
            foregroundColor: Palette.background,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Palette.backgroundTertiary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Palette.glassBorder,
              width: 1,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Palette.backgroundSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Palette.glassBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Palette.glassBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Palette.accent, width: 2),
          ),
        ),
      ),
      builder: (context, child) {
        // Show loading screen while checking auth or during minimum display time
        if (shouldShowLoading) {
          return MaterialApp(
            theme: Theme.of(context),
            home: const AppLoadingScreen(),
          );
        }
        
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
