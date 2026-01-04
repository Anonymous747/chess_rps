import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/auth_controller.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:chess_rps/presentation/screen/chat_screen.dart';
import 'package:chess_rps/presentation/screen/chess_screen.dart';
import 'package:chess_rps/presentation/screen/collection_screen.dart';
import 'package:chess_rps/presentation/screen/events_screen.dart';
import 'package:chess_rps/presentation/screen/friends_screen.dart';
import 'package:chess_rps/presentation/screen/leaderboard_screen.dart';
import 'package:chess_rps/presentation/screen/levels_screen.dart';
import 'package:chess_rps/presentation/screen/login_screen.dart';
import 'package:chess_rps/presentation/screen/main_navigation_screen.dart';
import 'package:chess_rps/presentation/screen/mode_selector.dart';
import 'package:chess_rps/presentation/screen/ai_difficulty_selector.dart';
import 'package:chess_rps/presentation/screen/opponent_selector.dart';
import 'package:chess_rps/presentation/screen/profile_screen.dart';
import 'package:chess_rps/presentation/screen/rating_screen.dart';
import 'package:chess_rps/presentation/screen/settings_screen.dart';
import 'package:chess_rps/presentation/screen/signup_screen.dart';
import 'package:chess_rps/presentation/screen/tournaments_screen.dart';
import 'package:chess_rps/presentation/screen/waiting_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Route paths
class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const mainMenu = '/main-menu';
  static const modeSelector = '/mode-selector';
  static const opponentSelector = '/opponent-selector';
  static const aiDifficultySelector = '/ai-difficulty-selector';
  static const waitingRoom = '/waiting-room';
  static const chess = '/chess';
  static const rating = '/rating';
  static const leaderboard = '/leaderboard';
  static const collection = '/collection';
  static const friends = '/friends';
  static const settings = '/settings';
  static const events = '/events';
  static const chat = '/chat';
  static const profile = '/profile';
  static const levels = '/levels';
  static const tournaments = '/tournaments';
  static const tournamentCreate = '/tournaments/create';
  static const tournamentDetails = '/tournaments/details';
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
    initialLocation: AppRoutes.login, // Always start at login - will redirect if authenticated
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
        AppLogger.info('Redirecting to login - no valid token found', tag: 'AppRouter');
        return AppRoutes.login;
      }
      
      // Redirect to main menu if authenticated and on auth route
      // This handles the case when user opens app with valid token
      if (isAuthenticated && isAuthRoute) {
        AppLogger.info('Redirecting to main menu - authenticated user on auth route', tag: 'AppRouter');
        return AppRoutes.mainMenu;
      }
      
      // ignore: dead_code
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
        path: AppRoutes.mainMenu,
        name: 'main-menu',
        builder: (context, state) => const MainNavigationScreen(),
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
        path: AppRoutes.aiDifficultySelector,
        name: 'ai-difficulty-selector',
        builder: (context, state) => const AIDifficultySelector(),
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
          final sideParam = state.uri.queryParameters['side'];
          
          if (sideParam != null) {
            final playerSide = sideParam == 'dark' ? Side.dark : Side.light;
            PlayerSideMediator.changePlayerSide(playerSide);
            
            // Side is selected, create GameController
            return ProviderScope(
              overrides: [
                gameControllerProvider.overrideWith(() => GameController()),
              ],
              child: const ChessScreen(),
            );
          } else {
            // No side parameter - check if we need side selection for AI games
            final isAIGame = GameModesMediator.opponentMode.isAI;
            
            if (isAIGame) {
              // For AI games without side, show screen which will display side selection dialog
              // Don't create GameController yet - it will be created after side selection
              return const ChessScreen();
            } else {
              // For non-AI games, create GameController immediately
              return ProviderScope(
                overrides: [
                  gameControllerProvider.overrideWith(() => GameController()),
                ],
                child: const ChessScreen(),
              );
            }
          }
        },
      ),
      GoRoute(
        path: AppRoutes.rating,
        name: 'rating',
        builder: (context, state) => const RatingScreen(),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.collection,
        name: 'collection',
        builder: (context, state) => const CollectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.friends,
        name: 'friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.events,
        name: 'events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.levels,
        name: 'levels',
        builder: (context, state) => const LevelsScreen(),
      ),
      GoRoute(
        path: AppRoutes.tournaments,
        name: 'tournaments',
        builder: (context, state) => const TournamentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.tournamentCreate,
        name: 'tournament-create',
        builder: (context, state) => const TournamentsScreen(), // TODO: Create TournamentCreateScreen
      ),
      GoRoute(
        path: AppRoutes.tournamentDetails,
        name: 'tournament-details',
        builder: (context, state) {
          final tournamentId = state.uri.queryParameters['id'];
          if (tournamentId == null) {
            return Scaffold(
              backgroundColor: Palette.background,
              body: Center(
                child: Text(
                  'Tournament ID required',
                  style: TextStyle(color: Palette.textPrimary),
                ),
              ),
            );
          }
          return const TournamentsScreen(); // TODO: Create TournamentDetailsScreen
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
              onPressed: () => context.go(AppRoutes.mainMenu),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
  
  return router;
});






