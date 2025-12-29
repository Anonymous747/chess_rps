import 'package:chess_rps/common/asset_url.dart';
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
import 'package:chess_rps/presentation/mediator/game_mode_mediator.dart';
import 'package:chess_rps/presentation/utils/piece_pack_utils.dart';
import 'package:chess_rps/presentation/widget/skeleton_loader.dart';
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

  /// Determine which side made a move by checking the board state or move notation
  /// In RPS mode, this is important because one player can make multiple moves in a row
  /// For online games, moves are stored in absolute notation (from white's perspective),
  /// so we can determine the side from the starting row:
  /// - Moves from rows 1-2 (e2, e3, etc.) are white moves
  /// - Moves from rows 7-8 (e7, e8, etc.) are black moves
  Side? _determineMoveSide(String fromPos, String toPos, Role? pieceRole) {
    if (fromPos.length != 2) {
      return null;
    }

    try {
      // First, try to determine from the starting row (most reliable for online games)
      // Online games store moves in absolute notation from white's perspective
      // Extract row number from algebraic notation (e.g., "e2" -> row 2, "e7" -> row 7)
      final rowChar = fromPos[1];
      final fromRow = int.tryParse(rowChar);
      
      if (fromRow != null) {
        // In absolute notation (white's perspective):
        // - Rows 1-2 are white's starting rows (row 1 = back rank, row 2 = pawn rank)
        // - Rows 7-8 are black's starting rows (row 7 = pawn rank, row 8 = back rank)
        // - Rows 3-6 are middle rows (less reliable, but we can still try based on direction)
        if (fromRow >= 1 && fromRow <= 2) {
          return Side.light; // White move (from white's starting ranks)
        } else if (fromRow >= 7 && fromRow <= 8) {
          return Side.dark; // Black move (from black's starting ranks)
        } else if (fromRow >= 3 && fromRow <= 6) {
          // For middle rows, check if move is going up (white) or down (black)
          // White moves forward (row increases: 2->3->4->5->6->7->8)
          // Black moves forward (row decreases: 7->6->5->4->3->2->1)
          if (toPos.length == 2) {
            final toRowChar = toPos[1];
            final toRow = int.tryParse(toRowChar);
            if (toRow != null) {
              if (toRow > fromRow) {
                // Moving up (row increases) - likely white move
                return Side.light;
              } else if (toRow < fromRow) {
                // Moving down (row decreases) - likely black move
                return Side.dark;
              }
            }
          }
        }
      }

      // Fallback: try to determine from the board state
      if (widget.board != null && toPos.length == 2) {
        // For online games, use convertFromAbsoluteNotation to get the position
        // since moves are stored in absolute notation
        try {
          final toPosition = toPos.convertFromAbsoluteNotation();
          
          if (toPosition.row >= 0 && toPosition.row < 8 && toPosition.col >= 0 && toPosition.col < 8) {
            final cell = widget.board!.getCellAt(toPosition.row, toPosition.col);
            if (cell.figure != null) {
              return cell.figure!.side;
            }
          }

          // Fallback: try to determine from the "from" position
          final fromPosition = fromPos.convertFromAbsoluteNotation();
          if (fromPosition.row >= 0 && fromPosition.row < 8 && fromPosition.col >= 0 && fromPosition.col < 8) {
            final cell = widget.board!.getCellAt(fromPosition.row, fromPosition.col);
            if (cell.figure != null) {
              return cell.figure!.side;
            }
          }
        } catch (e) {
          // If convertFromAbsoluteNotation fails, try convertToPosition as fallback
          try {
            final toPosition = toPos.convertToPosition();
            
            if (toPosition.row >= 0 && toPosition.row < 8 && toPosition.col >= 0 && toPosition.col < 8) {
              final cell = widget.board!.getCellAt(toPosition.row, toPosition.col);
              if (cell.figure != null) {
                return cell.figure!.side;
              }
            }
          } catch (e2) {
            // Ignore errors
          }
        }
      }

      // If we still can't determine, return null
      return null;
    } catch (e) {
      return null;
    }
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
      final imageUrl = AssetUrl.getChessPieceUrl(safePieceSet, side, role);

      return Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(right: 6),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Skeleton(
              width: 20,
              height: 20,
              borderRadius: 2,
            );
          },
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
    final isRpsMode = GameModesMediator.gameMode == GameMode.rps;

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
                if (!isRpsMode) ...[
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
                ] else
                  Expanded(
                    child: Text(
                      'MOVE',
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
                : isRpsMode
                    ? _buildRpsMoveList(moveHistory, currentMoveIndex, pieceSet)
                    : _buildClassicalMoveList(moveHistory, currentMoveIndex, pieceSet),
          ),
        ],
      ),
    );
  }

  /// Build move list for RPS mode (single column, showing all moves sequentially)
  Widget _buildRpsMoveList(List<String> moveHistory, int? currentMoveIndex, String pieceSet) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: moveHistory.length,
      itemBuilder: (context, index) {
        final moveStr = moveHistory[index];
        final move = (moveStr.length == 4 || moveStr.length == 5 || moveStr.length == 6)
            ? _parseMove(moveStr)
            : null;

        if (move == null) {
          return const SizedBox.shrink();
        }

        final from = move['from'] as String? ?? '';
        final to = move['to'] as String? ?? '';
        final pieceRole = move['piece'] as Role?;

        if (from.isEmpty || to.isEmpty) {
          return const SizedBox.shrink();
        }

        // Determine which side made this move
        final moveSide = _determineMoveSide(from, to, pieceRole);
        // If we can't determine the side, default based on starting row
        // For online games, moves are in absolute notation (white's perspective)
        // Rows 1-2 are white's starting ranks, rows 7-8 are black's starting ranks
        final defaultSide = (from.length == 2) ? () {
          final rowChar = from[1];
          final fromRow = int.tryParse(rowChar);
          if (fromRow != null) {
            if (fromRow >= 1 && fromRow <= 2) {
              return Side.light; // White move
            } else if (fromRow >= 7 && fromRow <= 8) {
              return Side.dark; // Black move
            }
          }
          return Side.light; // Default to white if uncertain
        }() : Side.light;
        
        final finalMoveSide = moveSide ?? defaultSide;
        final isWhiteMove = finalMoveSide == Side.light;
        final piece = _getMovedPiece(pieceRole, from, to, isWhiteMove);

        final isCurrentMove = currentMoveIndex != null && currentMoveIndex == index;

        // Determine side label and color
        final sideLabel = finalMoveSide == Side.light ? 'WHITE' : 'BLACK';
        final sideColor = finalMoveSide == Side.light
            ? Palette.textPrimary
            : Palette.textSecondary;

        return Container(
          decoration: BoxDecoration(
            color: isCurrentMove
                ? Palette.accent.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${index + 1}.',
                    style: TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: finalMoveSide == Side.light
                        ? Palette.backgroundElevated
                        : Palette.backgroundTertiary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: finalMoveSide == Side.light
                          ? Palette.glassBorder
                          : Palette.glassBorder.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    sideLabel,
                    style: TextStyle(
                      color: sideColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_buildPieceIcon(piece, pieceSet) != null)
                  _buildPieceIcon(piece, pieceSet)!,
                Text(
                  '$from → $to',
                  style: TextStyle(
                    color: Palette.textPrimary,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build move list for classical mode (two columns, alternating white/black)
  Widget _buildClassicalMoveList(List<String> moveHistory, int? currentMoveIndex, String pieceSet) {
    return ListView.builder(
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

        final whiteMove = whiteMoveStr != null && (whiteMoveStr.length == 4 || whiteMoveStr.length == 5 || whiteMoveStr.length == 6)
            ? _parseMove(whiteMoveStr)
            : null;
        final blackMove = blackMoveStr != null && (blackMoveStr.length == 4 || blackMoveStr.length == 5 || blackMoveStr.length == 6)
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
    );
  }
}
