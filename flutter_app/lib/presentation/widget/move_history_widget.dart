import 'package:chess_rps/common/palette.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoveHistoryWidget extends StatefulWidget {
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
  State<MoveHistoryWidget> createState() => _MoveHistoryWidgetState();
}

class _MoveHistoryWidgetState extends State<MoveHistoryWidget> {
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

  /// Convert algebraic notation (e2e4) to standard chess notation (e4, Nf3, etc.)
  /// Simplified version - shows destination square for now
  /// Full implementation would detect piece type, captures, special moves
  String _convertToStandardNotation(String algebraicMove, {bool isWhiteMove = true}) {
    if (algebraicMove.length != 4) return algebraicMove;
    
    final from = algebraicMove.substring(0, 2);
    final to = algebraicMove.substring(2, 4);
    
    // For castling (king moves more than 1 square horizontally)
    if (from[0] == 'e' && to[0] == 'g' && from[1] == to[1]) {
      return 'O-O'; // Kingside castling
    }
    if (from[0] == 'e' && to[0] == 'c' && from[1] == to[1]) {
      return 'O-O-O'; // Queenside castling
    }
    
    // For now, show destination square
    // TODO: Enhance to show piece symbols (N, B, R, Q, K) and detect captures
    return to;
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
        buffer.write(_convertToStandardNotation(moveHistory[i], isWhiteMove: true));
      }
      
      // Black move
      if (i + 1 < moveHistory.length) {
        buffer.write(' ${_convertToStandardNotation(moveHistory[i + 1], isWhiteMove: false)}');
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
    // final board = widget.board; // Reserved for future full notation conversion
    final currentMoveIndex = widget.currentMoveIndex;
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
                      
                      final whiteMove = whiteMoveIndex < moveHistory.length
                          ? _convertToStandardNotation(moveHistory[whiteMoveIndex], isWhiteMove: true)
                          : null;
                      final blackMove = blackMoveIndex < moveHistory.length
                          ? _convertToStandardNotation(moveHistory[blackMoveIndex], isWhiteMove: false)
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
                                child: Text(
                                  whiteMove ?? '-',
                                  style: TextStyle(
                                    color: Palette.textPrimary,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        blackMove ?? '-',
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
