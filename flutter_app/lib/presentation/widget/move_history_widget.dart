import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/common/piece_notation.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/figure.dart';
import 'package:chess_rps/domain/model/figures/bishop.dart';
import 'package:chess_rps/domain/model/figures/king.dart';
import 'package:chess_rps/domain/model/figures/knight.dart';
import 'package:chess_rps/domain/model/figures/pawn.dart';
import 'package:chess_rps/domain/model/figures/queen.dart';
import 'package:chess_rps/domain/model/figures/rook.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/controller/settings_controller.dart';
import 'package:chess_rps/presentation/utils/piece_pack_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MoveHistoryWidget extends ConsumerStatefulWidget {
  final List<String> moveHistory;
  final Board? board; // Optional board for better notation conversion
  final int? currentMoveIndex; // Index of currently selected/highlighted move

  const MoveHistoryWidget({
    required this.moveHistory,
    this.board,
    this.currentMoveIndex,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<MoveHistoryWidget> createState() => _MoveHistoryWidgetState();
}

class _MoveHistoryWidgetState extends ConsumerState<MoveHistoryWidget> {
  static const String _imagesPath = 'assets/images/figures';
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(MoveHistoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to bottom when new moves are added
    if (widget.moveHistory.length > oldWidget.moveHistory.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Parse move string to get piece, from and to positions
  /// Supports both formats: "Pe2e4" (with piece) and "e2e4" (without piece)
  /// For both AI and online games: shows absolute notation (from white's perspective)
  /// This ensures moves are displayed correctly regardless of player side
  Map<String, dynamic> _parseMove(String algebraicMove) {
    final parsed = PieceNotation.parseMoveNotation(algebraicMove);
    final fromAbsolute = parsed['from'] as String;
    final toAbsolute = parsed['to'] as String;
    
    // For both AI and online games, moves are stored in absolute notation
    // (from white's perspective), so we display them as-is
    // This ensures e2e4 is displayed as e2e4 for both white and black players
    final fromDisplay = fromAbsolute;
    final toDisplay = toAbsolute;
    
    return {
      'piece': parsed['piece'],
      'from': fromDisplay,
      'to': toDisplay,
    };
  }

  /// Get piece that was moved
  /// First tries to get from move notation (if piece type is included)
  /// Falls back to current board state if piece type not in notation
  Figure? _getMovedPiece(Role? pieceRole, String fromPos, String toPos, bool isWhiteMove) {
    // If piece role is available from notation, create a figure object
    if (pieceRole != null && widget.board != null) {
      try {
        final side = isWhiteMove ? Side.light : Side.dark;
        // Create a temporary figure object for display purposes
        // We just need the role and side to display the icon
        switch (pieceRole) {
          case Role.pawn:
            return Pawn(side: side, position: Position(row: 0, col: 0));
          case Role.rook:
            return Rook(side: side, position: Position(row: 0, col: 0));
          case Role.knight:
            return Knight(side: side, position: Position(row: 0, col: 0));
          case Role.bishop:
            return Bishop(side: side, position: Position(row: 0, col: 0));
          case Role.queen:
            return Queen(side: side, position: Position(row: 0, col: 0));
          case Role.king:
            return King(side: side, position: Position(row: 0, col: 0));
        }
      } catch (e) {
        // Fall through to board-based lookup
      }
    }

    // Fallback: try to get from current board state at destination
    if (widget.board == null || fromPos.length != 2 || toPos.length != 2) {
      return null;
    }

    try {
      final toPosition = toPos.convertToPosition();

      // Validate position is within board bounds
      if (toPosition.row < 0 || toPosition.row >= 8 || toPosition.col < 0 || toPosition.col >= 8) {
        return null;
      }

      final cell = widget.board!.getCellAt(toPosition.row, toPosition.col);

      // The piece at the destination is the one that moved (unless it was captured)
      if (cell.figure != null && cell.figure!.side.isLight == isWhiteMove) {
        return cell.figure;
      }
    } catch (e) {
      // If we can't determine, return null silently
      // This is expected for older moves where board state has changed
    }

    return null;
  }

  /// Build piece icon widget
  Widget? _buildPieceIcon(Figure? figure, String pieceSet) {
    if (figure == null) return null;

    try {
      final side = figure.side.toString(); // Returns 'black' or 'white'
      final role = figure.role.toString().split('.').last.toLowerCase();
      final safePieceSet = pieceSet.isNotEmpty ? pieceSet : 'cardinal';
      final imagePath = '$_imagesPath/$safePieceSet/$side/$role.png';

      return Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(right: 6),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Return empty container if image fails to load
            return const SizedBox.shrink();
          },
        ),
      );
    } catch (e) {
      // Return null if there's any error building the icon
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final moveHistory = widget.moveHistory;
    final currentMoveIndex = widget.currentMoveIndex;

    // Get piece set from settings
    final settingsAsync = ref.watch(settingsControllerProvider);
    String pieceSet = 'cardinal'; // Default fallback
    if (settingsAsync.hasValue && settingsAsync.value != null) {
      final requestedPieceSet = settingsAsync.value!.pieceSet;
      if (requestedPieceSet.isNotEmpty) {
        final knownPacks = PiecePackUtils.getKnownPiecePacks();
        pieceSet = knownPacks.contains(requestedPieceSet) ? requestedPieceSet : 'cardinal';
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: Palette.backgroundTertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Palette.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Palette.backgroundElevated,
              border: Border(
                bottom: BorderSide(
                  color: Palette.glassBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '#',
                    style: TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'WHITE',
                    style: TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'BLACK',
                    style: TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Moves list
          Expanded(
            child: moveHistory.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No moves yet',
                        style: TextStyle(
                          color: Palette.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.zero,
                    itemCount: (moveHistory.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      final moveNumber = index + 1;
                      final whiteMoveIndex = index * 2;
                      final blackMoveIndex = index * 2 + 1;

                      final whiteMoveStr =
                          whiteMoveIndex < moveHistory.length ? moveHistory[whiteMoveIndex] : null;
                      final blackMoveStr =
                          blackMoveIndex < moveHistory.length ? moveHistory[blackMoveIndex] : null;

                      final whiteMove = whiteMoveStr != null && (whiteMoveStr.length == 4 || whiteMoveStr.length == 5)
                          ? _parseMove(whiteMoveStr)
                          : null;
                      final blackMove = blackMoveStr != null && (blackMoveStr.length == 4 || blackMoveStr.length == 5)
                          ? _parseMove(blackMoveStr)
                          : null;

                      final whiteFrom = whiteMove?['from'] as String? ?? '';
                      final whiteTo = whiteMove?['to'] as String? ?? '';
                      final whitePieceRole = whiteMove?['piece'] as Role?;
                      final whitePiece = whiteMove != null &&
                              whiteFrom.isNotEmpty &&
                              whiteTo.isNotEmpty
                          ? _getMovedPiece(whitePieceRole, whiteFrom, whiteTo, true)
                          : null;
                          
                      final blackFrom = blackMove?['from'] as String? ?? '';
                      final blackTo = blackMove?['to'] as String? ?? '';
                      final blackPieceRole = blackMove?['piece'] as Role?;
                      final blackPiece = blackMove != null &&
                              blackFrom.isNotEmpty &&
                              blackTo.isNotEmpty
                          ? _getMovedPiece(blackPieceRole, blackFrom, blackTo, false)
                          : null;

                      final isCurrentMove = currentMoveIndex != null &&
                          (currentMoveIndex == whiteMoveIndex ||
                              currentMoveIndex == blackMoveIndex);

                      return Container(
                        decoration: BoxDecoration(
                          color:
                              isCurrentMove ? Palette.accent.withValues(alpha: 0.1) : Colors.transparent,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '$moveNumber.',
                                  style: TextStyle(
                                    color: Palette.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: whiteMove != null &&
                                        whiteFrom.isNotEmpty &&
                                        whiteTo.isNotEmpty
                                    ? Row(
                                        children: [
                                          if (_buildPieceIcon(whitePiece, pieceSet) != null)
                                            _buildPieceIcon(whitePiece, pieceSet)!,
                                          Text(
                                            '$whiteFrom → $whiteTo',
                                            style: TextStyle(
                                              color: Palette.textPrimary,
                                              fontSize: 13,
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        '-',
                                        style: TextStyle(
                                          color: Palette.textPrimary,
                                          fontSize: 13,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: blackMove != null &&
                                        blackFrom.isNotEmpty &&
                                        blackTo.isNotEmpty
                                    ? Row(
                                        children: [
                                          if (_buildPieceIcon(blackPiece, pieceSet) != null)
                                            _buildPieceIcon(blackPiece, pieceSet)!,
                                          Text(
                                            '$blackFrom → $blackTo',
                                            style: TextStyle(
                                              color: Palette.textPrimary,
                                              fontSize: 13,
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        '-',
                                        style: TextStyle(
                                          color: Palette.textPrimary,
                                          fontSize: 13,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
