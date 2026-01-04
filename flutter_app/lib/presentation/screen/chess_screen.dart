import 'package:chess_rps/common/asset_url.dart';
import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/logger.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/presentation/controller/stats_controller.dart';
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/utils/app_router.dart';
import 'package:chess_rps/presentation/utils/avatar_utils.dart';
import 'package:chess_rps/presentation/utils/piece_pack_utils.dart';
import 'package:chess_rps/presentation/screen/main_navigation_screen.dart';
import 'package:chess_rps/presentation/screen/play_flow_screen.dart';
import 'package:chess_rps/presentation/widget/board_widget.dart';
import 'package:chess_rps/presentation/widget/captured_pieces_widget.dart';
import 'package:chess_rps/presentation/widget/finish_game_dialog.dart';
import 'package:chess_rps/presentation/widget/game_loading_screen.dart';
import 'package:chess_rps/presentation/widget/game_over_dialog.dart';
import 'package:chess_rps/presentation/widget/move_history_widget.dart';
import 'package:chess_rps/presentation/widget/player_side_selection_dialog.dart';
import 'package:chess_rps/presentation/widget/rps_overlay.dart';
import 'package:chess_rps/presentation/widget/rps_result_display.dart';
import 'package:chess_rps/presentation/widget/timer_widget.dart';
import 'package:chess_rps/presentation/widget/user_avatar_widget.dart';
import 'package:chess_rps/presentation/utils/effect_event.dart';
import 'package:chess_rps/presentation/utils/game_effect_handler.dart';
import 'package:chess_rps/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';

class ChessScreen extends HookConsumerWidget {
  static const routeName = '/Chess';

  const ChessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAIGame = GameModesMediator.opponentMode.isAI;
    
    // Check if side was set via query parameter (from router) - check in build, not useEffect
    Side? sideFromRoute;
    try {
      final currentRoute = GoRouterState.of(context).uri;
      final sideParam = currentRoute.queryParameters['side'];
      if (sideParam != null) {
        sideFromRoute = sideParam == 'dark' ? Side.dark : Side.light;
      }
    } catch (e) {
      // If we can't access route yet, assume no side parameter
      sideFromRoute = null;
    }
    
    // Track if side selection dialog has been shown for AI games
    final sideSelectionShown = useRef(false);
    
    // Show side selection dialog for AI games if no side is selected
    useEffect(() {
      if (isAIGame && 
          !sideSelectionShown.value && 
          sideFromRoute == null && 
          context.mounted) {
        sideSelectionShown.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showPlayerSideSelectionDialog(context, ref);
          }
        });
      }
      return null;
    }, [isAIGame, sideFromRoute]);
    
    // For AI games, if no side is selected, show loading screen while dialog is shown
    // The dialog will navigate with side parameter, which will create the GameController
    if (isAIGame && sideFromRoute == null) {
      return const GameLoadingScreen();
    }
    
    // Game controller is available, proceed with normal build
    final controller = ref.read(gameControllerProvider.notifier);
    final gameState = ref.watch(gameControllerProvider);
    final settingsAsync = ref.watch(settingsControllerProvider);
    
    // Track image precaching state (use useState to trigger rebuilds)
    final imagesPrecachedState = useState(false);
    final precachingInProgress = useRef(false);
    final lastGameKeyRef = useRef<String?>(null);
    
    // Listen to effect events and apply them
    useEffect(() {
      if (!context.mounted) return null;
      
      final effectSubscription = controller.effectEvents.listen((event) {
        if (!context.mounted) return;
        
        AppLogger.info(
          'Effect event received: ${event.type.name}, effect: ${event.effectName}',
          tag: 'ChessScreen',
        );
        
        if (event.type == EffectEventType.capture) {
          GameEffectHandler.applyCaptureEffect(
            context,
            event.effectName,
            () {
              AppLogger.debug('Capture effect completed', tag: 'ChessScreen');
            },
          );
        } else if (event.type == EffectEventType.move) {
          GameEffectHandler.applyMoveEffect(
            context,
            event.effectName,
            () {
              AppLogger.debug('Move effect completed', tag: 'ChessScreen');
            },
          );
        }
      });
      
      return () {
        effectSubscription.cancel();
      };
    }, []);
    
    // Show loading screen until game is fully initialized
    // Check if board is ready: all pieces must be loaded and board must be properly initialized
    final board = gameState.board;
    final hasBoardCells = board.cells.isNotEmpty && board.cells.length == 8;
    
    // Get current piece set
    String currentPieceSet = 'cardinal'; // Default fallback
    if (settingsAsync.hasValue && settingsAsync.value != null) {
      final requestedPieceSet = settingsAsync.value!.pieceSet;
      if (requestedPieceSet.isNotEmpty) {
        final knownPacks = PiecePackUtils.getKnownPiecePacks();
        currentPieceSet = knownPacks.contains(requestedPieceSet) 
            ? requestedPieceSet 
            : 'cardinal';
      }
    }
    
    // Count pieces to ensure all are loaded (should be 32 pieces total: 16 per side)
    int pieceCount = 0;
    if (hasBoardCells) {
      for (final row in board.cells) {
        for (final cell in row) {
          if (cell.figure != null) {
            pieceCount++;
          }
        }
      }
    }
    
    // Create a unique game key that changes when a new game starts
    // This key is based on: piece set and move history length
    // Note: We DON'T include timer values because timers tick during gameplay,
    // which would cause false "new game" detections. Timers are not part of game identity.
    final currentMoveHistoryLength = gameState.moveHistory.length;
    // Check for fresh game - in RPS mode, initial time is 300 seconds, in classical mode it's 600 seconds
    final expectedInitialTime = GameModesMediator.gameMode == GameMode.rps ? 300 : 600;
    final isFreshGame = pieceCount == 32 && 
                        currentMoveHistoryLength == 0 && 
                        gameState.lightPlayerTimeSeconds == expectedInitialTime &&
                        gameState.darkPlayerTimeSeconds == expectedInitialTime;
    
    // GameKey should only change when piece set or move count changes
    // NOT when timers tick (that's normal gameplay)
    final currentGameKey = '${currentPieceSet}_${currentMoveHistoryLength}';
    
    // Reset precaching state when a new game is detected
    // A new game is detected when:
    // 1. Game key changes (different piece set OR move count changed from >0 to 0)
    // 2. AND we have a fresh game state (32 pieces, no moves, 600s timers)
    //    OR the previous game had moves and now we're at 0 moves (game reset)
    // For online games, don't treat piece set loading as a new game
    int previousMoveHistoryLength = -1;
    String? previousPieceSet;
    if (lastGameKeyRef.value != null) {
      final parts = lastGameKeyRef.value!.split('_');
      if (parts.isNotEmpty) {
        previousPieceSet = parts[0];
      }
      if (parts.length >= 2) {
        previousMoveHistoryLength = int.tryParse(parts[1]) ?? -1;
      }
    }
    
    // For online games, if only the piece set changed (from default 'cardinal' to actual piece set),
    // and we're still at 0 moves, don't treat it as a new game - it's just settings loading
    final isOnlyPieceSetChange = GameModesMediator.opponentMode == OpponentMode.socket &&
                                 lastGameKeyRef.value != null &&
                                 previousPieceSet != null &&
                                 previousPieceSet != currentPieceSet &&
                                 currentMoveHistoryLength == 0 &&
                                 previousMoveHistoryLength == 0;
    
    // A new game is detected if:
    // 1. GameKey changed (piece set or move count changed)
    // 2. AND it's either:
    //    - A fresh game (0 moves, 600s timers, 32 pieces) - new game started
    //    - Move count reset from >0 to 0 - game was reset
    final isNewGame = !isOnlyPieceSetChange &&
                      lastGameKeyRef.value != null && 
                      lastGameKeyRef.value != currentGameKey &&
                      (isFreshGame || (previousMoveHistoryLength > 0 && currentMoveHistoryLength == 0));
    
    // Reset precaching state for new game
    useEffect(() {
      if (isNewGame || (lastGameKeyRef.value == null && isFreshGame)) {
        AppLogger.info(
          'New game detected: gameKey=${lastGameKeyRef.value} -> $currentGameKey. Resetting image precaching state.',
          tag: 'ChessScreen'
        );
        imagesPrecachedState.value = false;
        precachingInProgress.value = false;
      }
      lastGameKeyRef.value = currentGameKey;
      return null;
    }, [currentGameKey, isFreshGame, currentMoveHistoryLength]);
    
    // Game is fully ready when ALL of the following are true:
    // 1. Board has 8 rows (full board structure)
    // 2. Timers are initialized (lightPlayerTimeSeconds > 0 indicates game started)
    // 3. Settings are loaded (piece set and board theme available)
    // 4. Game state is initialized (playerSide and currentOrder are set)
    // 5. All images are precached
    // Note: We don't check pieceCount >= 32 because pieces get captured during gameplay,
    // so the count will drop below 32. The board structure being initialized is sufficient.
    final settingsReady = settingsAsync.hasValue && settingsAsync.value != null;
    // playerSide and currentOrder are non-nullable in GameState, so they're always set
    final gameStateReady = true;
    final boardReady = hasBoardCells && 
                       gameState.lightPlayerTimeSeconds > 0 &&
                       gameState.darkPlayerTimeSeconds > 0;
    
    // All active game information must be loaded
    final allGameInfoReady = boardReady && 
                             settingsReady && 
                             gameStateReady;
    
    // Precache all piece images when all game info is ready but images aren't precached yet
    useEffect(() {
      if (allGameInfoReady && !imagesPrecachedState.value && !precachingInProgress.value && context.mounted) {
        precachingInProgress.value = true;
        AppLogger.info('Starting image precaching...', tag: 'ChessScreen');
        
        // Use current piece set (already determined above)
        final pieceSet = currentPieceSet;
        
        // Collect all unique piece image URLs needed (all 6 piece types for both sides)
        final Set<String> imageUrls = {};
        // Add all piece types for both sides to ensure complete precaching
        final pieceTypes = ['king', 'queen', 'rook', 'bishop', 'knight', 'pawn'];
        final sides = ['white', 'black'];
        for (final side in sides) {
          for (final pieceType in pieceTypes) {
            final imageUrl = AssetUrl.getChessPieceUrl(pieceSet, side, pieceType);
            imageUrls.add(imageUrl);
          }
        }
        
        AppLogger.info(
          'Precaching ${imageUrls.length} piece images for piece set: $pieceSet',
          tag: 'ChessScreen'
        );
        
        // Precache all images
        Future(() async {
          try {
            int successCount = 0;
            int failCount = 0;
            for (final imageUrl in imageUrls) {
              try {
                await precacheImage(NetworkImage(imageUrl), context);
                successCount++;
              } catch (e) {
                failCount++;
                AppLogger.warning(
                  'Failed to precache image: $imageUrl - $e',
                  tag: 'ChessScreen'
                );
              }
            }
            AppLogger.info(
              'Image precaching complete: $successCount succeeded, $failCount failed',
              tag: 'ChessScreen'
            );
            if (context.mounted) {
              imagesPrecachedState.value = true;
            }
            precachingInProgress.value = false;
          } catch (e) {
            AppLogger.error(
              'Error during image precaching: $e',
              tag: 'ChessScreen',
              error: e,
            );
            // Still mark as precached to avoid infinite loading
            if (context.mounted) {
              imagesPrecachedState.value = true;
            }
            precachingInProgress.value = false;
          }
        });
      }
      return null;
    }, [allGameInfoReady]);
    
    // Watch for game over state FIRST - check this before rendering game board
    final gameOver = gameState.gameOver;
    final winner = gameState.winner;
    final isCheckmate = gameState.isCheckmate;
    final isStalemate = gameState.isStalemate;
    final playerSide = gameState.playerSide;
    
    // Track if dialog has been shown to prevent multiple showings
    final dialogShown = useRef(false);
    final previousGameOver = useRef(false);
    
    // Capture context for use in useEffect
    final buildContext = context;
    
    // Show game over dialog IMMEDIATELY when game ends (only once)
    // This must happen FIRST, before any other UI updates or game board rendering
    useEffect(() {
      // Reset dialogShown when gameOver transitions from true to false (new game started)
      if (previousGameOver.value && !gameOver) {
        AppLogger.info(
          'GameOver state reset - resetting dialogShown flag for new game',
          tag: 'ChessScreen'
        );
        dialogShown.value = false;
      }
      previousGameOver.value = gameOver;
      
      if (gameOver && !dialogShown.value && buildContext.mounted) {
        dialogShown.value = true;
        AppLogger.info(
          'Game ended - showing win/loss dialog immediately. '
          'winner=${winner?.name}, playerSide=${playerSide.name}, '
          'isCheckmate=$isCheckmate, isStalemate=$isStalemate',
          tag: 'ChessScreen'
        );
        // Use WidgetsBinding to ensure dialog shows even during build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (buildContext.mounted) {
            _showGameOverDialog(
              buildContext,
              controller,
              ref,
              winner: winner,
              playerSide: playerSide,
              isCheckmate: isCheckmate,
              isStalemate: isStalemate,
            );
          }
        });
      }
      return null;
    }, [gameOver, winner, playerSide, isCheckmate, isStalemate]);
    
    // Game is ready when all information is loaded AND images are precached
    final isReady = allGameInfoReady && imagesPrecachedState.value;
    
    if (!isReady) {
      AppLogger.debug(
        'Game not ready yet: '
        'hasBoardCells=$hasBoardCells, '
        'pieceCount=$pieceCount, '
        'lightTime=${gameState.lightPlayerTimeSeconds}, '
        'darkTime=${gameState.darkPlayerTimeSeconds}, '
        'settingsReady=$settingsReady, '
        'gameStateReady=$gameStateReady, '
        'imagesPrecached=${imagesPrecachedState.value}',
        tag: 'ChessScreen'
      );
      return const GameLoadingScreen();
    }
    
    final showRpsOverlay = gameState.showRpsOverlay;
    final waitingForRpsResult = gameState.waitingForRpsResult;
    final playerRpsChoice = gameState.playerRpsChoice;
    final opponentRpsChoice = gameState.opponentRpsChoice;
    final playerWonRps = gameState.playerWonRps;
    final isRpsTie = gameState.isRpsTie;
    final lightPlayerTime = gameState.lightPlayerTimeSeconds;
    final darkPlayerTime = gameState.darkPlayerTimeSeconds;
    final currentOrder = gameState.currentOrder;
    // CRITICAL FIX: Use backup move history if state is empty or stale
    // This ensures the UI always shows the correct move history even if state hasn't propagated
    final stateMoveHistory = gameState.moveHistory;
    final backupMoveHistory = controller.moveHistoryBackup;
    final moveHistory = backupMoveHistory.length > stateMoveHistory.length
        ? backupMoveHistory
        : (stateMoveHistory.isNotEmpty || backupMoveHistory.isEmpty
            ? stateMoveHistory
            : backupMoveHistory);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Palette.background,
              Palette.backgroundSecondary,
              Palette.backgroundTertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // RPS Result Display (only show in RPS mode and when choices are made)
                  if (GameModesMediator.gameMode == GameMode.rps)
                    RpsResultDisplay(
                      playerChoice: playerRpsChoice,
                      opponentChoice: opponentRpsChoice,
                      playerWon: playerWonRps,
                    ),
                  // Top bar with finish button and timers in one row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        // Status text row (only show if not in RPS mode or if RPS result not shown)
                        if (GameModesMediator.gameMode != GameMode.rps ||
                            (playerRpsChoice == null && opponentRpsChoice == null))
                          Center(
                            child: _buildStatusText(context, playerWonRps),
                          ),
                        if (GameModesMediator.gameMode != GameMode.rps ||
                            (playerRpsChoice == null && opponentRpsChoice == null))
                          const SizedBox(height: 12),
                        // Timer widget with finish button
                        TimerWidget(
                          lightPlayerTimeSeconds: lightPlayerTime,
                          darkPlayerTimeSeconds: darkPlayerTime,
                          currentTurn: currentOrder,
                          onFinishGame: () => _showFinishGameDialog(context, controller, ref),
                        ),
                      ],
                    ),
                  ),
                  // Opponent's captured pieces (above board)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Opponent avatar
                            UserAvatarByIconWidget(
                              avatarIconName: _getOpponentAvatarIconName(),
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Opponent\'s Captures',
                              style: TextStyle(
                                color: Palette.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CapturedPiecesWidget(
                          board: board,
                          isLightSide: !playerSide.isLight,
                        ),
                      ],
                    ),
                  ),
                  // Board area
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BoardWidget(board: board),
                    ),
                  ),
                  // Player's captured pieces (below board)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Current user avatar
                            UserAvatarWidget(
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Your Captures',
                              style: TextStyle(
                                color: Palette.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        CapturedPiecesWidget(
                          board: board,
                          isLightSide: playerSide.isLight,
                        ),
                      ],
                    ),
                  ),
                  // Move history at the bottom
                  Container(
                    height: 200,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: MoveHistoryWidget(
                      moveHistory: moveHistory,
                      board: board,
                    ),
                  ),
                  ],
                ),
              ),
              if (showRpsOverlay)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: RpsOverlay(
                    key: ValueKey('rps_overlay_${showRpsOverlay}_${isRpsTie}'),
                    onChoiceSelected: (choice) async {
                      // Hide overlay immediately when choice is selected
                      // During tie, this will show the overlay again after processing
                      controller.hideRpsOverlayImmediately();
                      // Then handle the RPS choice
                      // If it's a tie, handleRpsChoice will show the overlay again
                      await controller.handleRpsChoice(choice);
                    },
                    isWaitingForOpponent: waitingForRpsResult,
                    opponentChoice: opponentRpsChoice?.displayName,
                    isTie: isRpsTie,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, bool? playerWonRps) {
    final l10n = AppLocalizations.of(context)!;
    if (playerWonRps == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Palette.success.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Palette.success.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 18,
              color: Palette.success,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.youWonRps,
              style: TextStyle(
                color: Palette.success,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else if (playerWonRps == false) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Palette.warning.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Palette.warning.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 18,
              color: Palette.warning,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.opponentWonRps,
              style: TextStyle(
                color: Palette.warning,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  void _showFinishGameDialog(BuildContext context, GameController controller, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return FinishGameDialog(
          onCancel: () {
            Navigator.of(dialogContext).pop();
          },
          onConfirm: () async {
            Navigator.of(dialogContext).pop();
            
            // If online mode, send surrender message to opponent
            if (GameModesMediator.opponentMode == OpponentMode.socket) {
              try {
                AppLogger.info('Sending surrender message to opponent', tag: 'ChessScreen');
                await controller.sendSurrender();
              } catch (e) {
                AppLogger.error('Failed to send surrender message: $e', tag: 'ChessScreen', error: e);
                // Continue even if sending fails
              }
            }
            
            // Dispose controller and navigate to menu with play tab selected
            controller.dispose();
            if (context.mounted) {
              // Reset play flow state to mode selector
              ref.read(playFlowStateProvider.notifier).reset();
              // Navigate to main menu with play tab (index 2) selected
              ref.read(navigationIndexProvider.notifier).setIndex(2);
              context.go(AppRoutes.mainMenu);
            }
          },
        );
      },
    );
  }

  Future<void> _showGameOverDialog(
    BuildContext context,
    GameController controller,
    WidgetRef ref, {
    required Side? winner,
    required Side playerSide,
    required bool isCheckmate,
    required bool isStalemate,
  }) async {
    // Prevent showing dialog multiple times
    if (!context.mounted) {
      AppLogger.warning(
        'Cannot show game over dialog - context not mounted',
        tag: 'ChessScreen'
      );
      return;
    }
    
    AppLogger.info(
      'Showing game over dialog: winner=${winner?.name}, playerSide=${playerSide.name}, isCheckmate=$isCheckmate, isStalemate=$isStalemate',
      tag: 'ChessScreen'
    );
    
    // Record game result first to get XP and rating changes
    int? xpGained;
    int? ratingChange;
    final isOnlineGame = GameModesMediator.opponentMode.isRealOpponent;
    
    try {
      // Determine game result
      final playerWon = winner == playerSide;
      final isDraw = isStalemate || winner == null;
      final result = isDraw ? "draw" : (playerWon ? "win" : "loss");
      
      // Determine end type
      String? endType;
      if (isCheckmate) {
        endType = "checkmate";
      } else if (isStalemate) {
        endType = "stalemate";
      }
      
      // Get game mode
      final gameMode = GameModesMediator.gameMode.name; // "classical" or "rps"
      final opponentMode = GameModesMediator.opponentMode.name; // "ai" or "socket"
      
      // Record game result to get stats update
      final statsController = ref.read(statsControllerProvider.notifier);
      final statsUpdate = await statsController.recordGameResult(
        result: result,
        gameMode: gameMode,
        endType: endType,
        opponentMode: opponentMode,
      );
      
      xpGained = statsUpdate.xpGained;
      ratingChange = statsUpdate.ratingChange;
      
      AppLogger.info(
        'Game result recorded: XP=$xpGained, Rating=$ratingChange (online=$isOnlineGame)',
        tag: 'ChessScreen'
      );
      
      // Invalidate leaderboard to refresh with updated ratings
      ref.invalidate(leaderboardProvider(3));
      ref.invalidate(leaderboardProvider(10));
      ref.invalidate(leaderboardProvider(50));
    } catch (e) {
      AppLogger.error(
        'Failed to record game result before showing dialog: $e',
        tag: 'ChessScreen',
        error: e,
      );
      // Continue to show dialog even if stats recording fails
    }
    
    try {
      // Show dialog with highest priority - it blocks all other interactions
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        barrierColor: Colors.black.withValues(alpha: 0.7), // Dark overlay to focus attention
        useSafeArea: true, // Ensure dialog is within safe area
        builder: (BuildContext dialogContext) {
          return GameOverDialog(
            winner: winner,
            playerSide: playerSide,
            isCheckmate: isCheckmate,
            isStalemate: isStalemate,
            xpGained: xpGained,
            ratingChange: ratingChange,
            isOnlineGame: isOnlineGame,
            onReturnToMenu: () {
              _handleGameOver(context, controller, ref, winner, playerSide, isCheckmate, isStalemate);
            },
          );
        },
      );
      AppLogger.info('Game over dialog shown successfully', tag: 'ChessScreen');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to show game over dialog: $e',
        tag: 'ChessScreen',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _handleGameOver(
    BuildContext context,
    GameController controller,
    WidgetRef ref,
    Side? winner,
    Side playerSide,
    bool isCheckmate,
    bool isStalemate,
  ) async {
    // Determine game result
    final playerWon = winner == playerSide;
    final isDraw = isStalemate || winner == null;
    final result = isDraw ? "draw" : (playerWon ? "win" : "loss");
    
    // Determine end type
    String? endType;
    if (isCheckmate) {
      endType = "checkmate";
    } else if (isStalemate) {
      endType = "stalemate";
    }
    
    // Get game mode
    final gameMode = GameModesMediator.gameMode.name; // "classical" or "rps"
    
    AppLogger.info(
      'Game Over Analytics:',
      tag: 'ChessScreen',
    );
    AppLogger.info(
      '  - Result: $result',
      tag: 'ChessScreen',
    );
    AppLogger.info(
      '  - End Type: $endType',
      tag: 'ChessScreen',
    );
    AppLogger.info(
      '  - Game Mode: $gameMode',
      tag: 'ChessScreen',
    );
    
    // Game result was already recorded in _showGameOverDialog
    // No need to record again here
    AppLogger.info('Game over handled - stats already recorded', tag: 'ChessScreen');
    
    // Dispose controller and navigate to main menu with play tab selected
    controller.dispose();
    if (context.mounted) {
      // Reset play flow state to mode selector
      ref.read(playFlowStateProvider.notifier).reset();
      // Navigate to main menu with play tab (index 2) selected
      ref.read(navigationIndexProvider.notifier).setIndex(2);
      context.go(AppRoutes.mainMenu);
    }
  }

  /// Get opponent avatar icon name
  /// For AI, returns a consistent avatar (avatar_2 for AI)
  /// For real opponent, returns the opponent's equipped avatar from backend
  static String? _getOpponentAvatarIconName() {
    if (GameModesMediator.opponentMode.isAI) {
      // Use a consistent avatar for AI (avatar_2 - "Cool Dude")
      return AvatarUtils.getAvatarIconName(2);
    }
    // For real opponents, get avatar from stored opponent info
    final opponentInfo = GameModesMediator.opponentInfo;
    if (opponentInfo != null && opponentInfo['avatar_icon'] != null) {
      final avatarIcon = opponentInfo['avatar_icon'] as String;
      // avatarIcon is in format "avatar_X", extract number
      final match = RegExp(r'avatar_(\d+)').firstMatch(avatarIcon);
      if (match != null) {
        final avatarIndex = int.tryParse(match.group(1) ?? '3');
        if (avatarIndex != null) {
          return AvatarUtils.getAvatarIconName(avatarIndex);
        }
      }
    }
    // Fallback to default avatar if opponent info not available
    return AvatarUtils.getAvatarIconName(3);
  }

  void _showPlayerSideSelectionDialog(BuildContext context, WidgetRef ref) {
    if (!context.mounted) return;
    
    AppLogger.info(
      'Showing player side selection dialog for AI game',
      tag: 'ChessScreen'
    );
    
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing - must select a side
      builder: (BuildContext dialogContext) {
        return PlayerSideSelectionDialog(
          onSideSelected: (Side selectedSide) {
            AppLogger.info(
              'Player selected side: ${selectedSide.name}',
              tag: 'ChessScreen'
            );
            
            // Close the dialog
            Navigator.of(dialogContext).pop();
            
            // Navigate to chess screen with side parameter
            // This will create the GameController with the selected side
            final sideParam = selectedSide == Side.light ? 'light' : 'dark';
            if (context.mounted) {
              context.go('${AppRoutes.chess}?side=$sideParam');
              AppLogger.info(
                'Navigated to chess screen with side: ${selectedSide.name}',
                tag: 'ChessScreen'
              );
            }
          },
        );
      },
    );
  }
}
