import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/figure.dart';
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

  /// Parse move string to get from and to positions
  Map<String, String> _parseMove(String algebraicMove) {
    if (algebraicMove.length != 4) {
      return {'from': '', 'to': ''};
    }
    return {
      'from': algebraicMove.substring(0, 2),
      'to': algebraicMove.substring(2, 4),
    };
  }

  /// Get piece that was moved (tries to get from current board state at destination)
  /// Note: This works best for recent moves, as board state changes
  Figure? _getMovedPiece(String fromPos, String toPos, bool isWhiteMove) {
    if (widget.board == null || fromPos.length != 2 || toPos.length != 2) {
      return null;
    }
    
    try {
      final toPosition = toPos.convertToPosition();
      
      // Validate position is within board bounds
      if (toPosition.row < 0 || toPosition.row >= 8 || 
          toPosition.col < 0 || toPosition.col >= 8) {
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

  /// Generate PGN format from move history
  String _generatePGN() {
    final moveHistory = widget.moveHistory;
    if (moveHistory.isEmpty) return '';
    
    final buffer = StringBuffer();
    int moveNumber = 1;
    
    for (int i = 0; i < moveHistory.length; i += 2) {
      buffer.write('$moveNumber. ');
      
      // White move
      if (i < moveHistory.length) {
        final move = _parseMove(moveHistory[i]);
        buffer.write('${move['from']}${move['to']}');
      }
      
      // Black move
      if (i + 1 < moveHistory.length) {
        final move = _parseMove(moveHistory[i + 1]);
        buffer.write(' ${move['from']}${move['to']}');
      }
      
      buffer.write(' ');
      moveNumber++;
    }
    
    return buffer.toString().trim();
  }

  void _exportPGN(BuildContext context) {
    final pgn = _generatePGN();
    if (pgn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No moves to export'),
          backgroundColor: Palette.error,
        ),
      );
      return;
    }
    
    Clipboard.setData(ClipboardData(text: pgn));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('PGN copied to clipboard'),
        backgroundColor: Palette.success,
        duration: const Duration(seconds: 2),
      ),
    );
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
        pieceSet = knownPacks.contains(requestedPieceSet) 
            ? requestedPieceSet 
            : 'cardinal';
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
          // Header with title and export button
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Move History',
                  style: TextStyle(
                    color: Palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _exportPGN(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    backgroundColor: Palette.accent.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'EXPORT PGN',
                    style: TextStyle(
                      color: Palette.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                      
                      final whiteMoveStr = whiteMoveIndex < moveHistory.length
                          ? moveHistory[whiteMoveIndex]
                          : null;
                      final blackMoveStr = blackMoveIndex < moveHistory.length
                          ? moveHistory[blackMoveIndex]
                          : null;
                      
                      final whiteMove = whiteMoveStr != null && whiteMoveStr.length == 4
                          ? _parseMove(whiteMoveStr)
                          : null;
                      final blackMove = blackMoveStr != null && blackMoveStr.length == 4
                          ? _parseMove(blackMoveStr)
                          : null;
                      
                      final whitePiece = whiteMove != null && 
                          whiteMove['from']!.isNotEmpty && whiteMove['to']!.isNotEmpty
                          ? _getMovedPiece(whiteMove['from']!, whiteMove['to']!, true)
                          : null;
                      final blackPiece = blackMove != null && 
                          blackMove['from']!.isNotEmpty && blackMove['to']!.isNotEmpty
                          ? _getMovedPiece(blackMove['from']!, blackMove['to']!, false)
                          : null;
                      
                      final isCurrentMove = currentMoveIndex != null &&
                          (currentMoveIndex == whiteMoveIndex || currentMoveIndex == blackMoveIndex);
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: isCurrentMove
                              ? Palette.accent.withOpacity(0.1)
                              : Colors.transparent,
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
                                    whiteMove['from']!.isNotEmpty && 
                                    whiteMove['to']!.isNotEmpty
                                    ? Row(
                                        children: [
                                          if (_buildPieceIcon(whitePiece, pieceSet) != null)
                                            _buildPieceIcon(whitePiece, pieceSet)!,
                                          Text(
                                            '${whiteMove['from']} → ${whiteMove['to']}',
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
                                    blackMove['from']!.isNotEmpty && 
                                    blackMove['to']!.isNotEmpty
                                    ? Row(
                                        children: [
                                          if (_buildPieceIcon(blackPiece, pieceSet) != null)
                                            _buildPieceIcon(blackPiece, pieceSet)!,
                                          Text(
                                            '${blackMove['from']} → ${blackMove['to']}',
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
