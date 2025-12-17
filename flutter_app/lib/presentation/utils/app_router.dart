import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/screen/chess_screen.dart';
import 'package:chess_rps/presentation/screen/login_screen.dart';
import 'package:chess_rps/presentation/screen/mode_selector.dart';
import 'package:chess_rps/presentation/screen/opponent_selector.dart';
import 'package:chess_rps/presentation/screen/signup_screen.dart';
import 'package:chess_rps/presentation/screen/waiting_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

// Route paths
class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const modeSelector = '/mode-selector';
  static const opponentSelector = '/opponent-selector';
  static const waitingRoom = '/waiting-room';
  static const chess = '/chess';
}

// ValueNotifier to trigger router refresh when auth state changes
final _authRefreshNotifierProvider = Provider<ValueNotifier<void>>((ref) {
  final notifier = ValueNotifier<void>(null);
  
  // Listen to auth state changes and refresh router when auth loads
  // Use ref.listen to set up the listener without creating a dependency
  ref.listen<AsyncValue<dynamic>>(
    authControllerProvider,
    (previous, next) {
      // When auth state changes from loading to loaded, refresh router
      if (previous?.isLoading == true && !next.isLoading) {
        AppLogger.info('Auth state loaded, refreshing router', tag: 'AppRouter');
        notifier.value = null; // Trigger refresh
      }
    },
  );
  
  // Keep the notifier alive
  ref.onDispose(() {
    notifier.dispose();
  });
  
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final refreshNotifier = ref.watch(_authRefreshNotifierProvider);
  
  // Create a router that will redirect based on auth state
  // The redirect function will handle navigation once auth is loaded
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final isLoading = authState.isLoading;
      final isAuthRoute = state.matchedLocation == AppRoutes.login || 
                         state.matchedLocation == AppRoutes.signup;
      
      // Show loading screen while checking auth - don't redirect during loading
      if (isLoading) {
        return null; // Let the loading screen show
      }
      
      // Redirect to login if not authenticated and trying to access protected route
      if (!isAuthenticated && !isAuthRoute) {
        AppLogger.info('Redirecting to login - not authenticated', tag: 'AppRouter');
        return AppRoutes.login;
      }
      
      // Redirect to mode selector if authenticated and on auth route
      // This handles the case when user opens app with valid token
      if (isAuthenticated && isAuthRoute) {
        AppLogger.info('Redirecting to mode selector - authenticated user on auth route', tag: 'AppRouter');
        return AppRoutes.modeSelector;
      }
      
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.modeSelector,
        name: 'mode-selector',
        builder: (context, state) => const ModeSelector(),
      ),
      GoRoute(
        path: AppRoutes.opponentSelector,
        name: 'opponent-selector',
        builder: (context, state) => const OpponentSelector(),
      ),
      GoRoute(
        path: AppRoutes.waitingRoom,
        name: 'waiting-room',
        builder: (context, state) {
          final roomCode = state.uri.queryParameters['roomCode'];
          if (roomCode == null || roomCode.isEmpty) {
            return Scaffold(
              backgroundColor: Palette.background,
              body: Center(
                child: Text(
                  'Invalid room code',
                  style: TextStyle(color: Palette.textPrimary),
                ),
              ),
            );
          }
          return WaitingRoomScreen(roomCode: roomCode);
        },
      ),
      GoRoute(
        path: AppRoutes.chess,
        name: 'chess',
        builder: (context, state) {
          Side playerSide = Side.light;
          
          final sideParam = state.uri.queryParameters['side'];
          if (sideParam != null) {
            playerSide = sideParam == 'dark' ? Side.dark : Side.light;
            PlayerSideMediator.changePlayerSide(playerSide);
          }
          
          return ProviderScope(
            overrides: [
              gameControllerProvider.overrideWith(() => GameController()),
            ],
            child: const ChessScreen(),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Palette.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Palette.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: TextStyle(
                fontSize: 24,
                color: Palette.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: TextStyle(
                fontSize: 16,
                color: Palette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.modeSelector),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
  
  return router;
});






