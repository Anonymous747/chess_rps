import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
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

class Root extends ConsumerWidget {
  const Root({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final authState = ref.watch(authControllerProvider);
    
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
        // Show loading screen while checking auth
        if (authState.isLoading) {
          return MaterialApp(
            theme: Theme.of(context),
            home: Scaffold(
              backgroundColor: Palette.background,
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Palette.accent),
                ),
              ),
            ),
          );
        }
        
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
