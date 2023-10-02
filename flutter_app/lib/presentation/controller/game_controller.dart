import 'dart:async';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';
import 'package:chess_rps/presentation/utils/player_side_mediator.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stockfish_interpreter/stockfish_interpreter.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  @protected
  @visibleForTesting
  late final StockfishInterpreter stockfishInterpreter;

  @override
  GameState build() {
    stockfishInterpreter = StockfishInterpreter(parameters: {});

    final board = Board()..startGame();
    // TODO: Correct define player side
    final state = GameState(board: board, playerSide: Side.light);
    PlayerSideMediator.changePlayerSide(state.playerSide);

    return state;
  }

  Future<void> executeCommand(String command) async {
    // stockfishInterpreter.applyCommand(command);

    await stockfishInterpreter.getBestMove();
    await stockfishInterpreter.visualizeBoard();
  }

  void onPressed(Cell pressedCell) {
    final currentOrder = state.currentOrder;

    print('========= position = ${pressedCell.position.algebraicPosition}');

    if (pressedCell.isAvailable || pressedCell.canBeKnockedDown) {
      assert(state.selectedFigure != null, "Figure should be chosen");
      makeMove(pressedCell);
    }

    if (pressedCell.isOccupied && pressedCell.figureSide == currentOrder) {
      showAvailableActions(pressedCell);
      ref.notifyListeners();
    }
  }

  void _displayAvailableCells(Cell fromCell) {
    final availableHashes =
        ActionChecker.getAvailablePositionsHash(state.board, fromCell);

    for (final hash in availableHashes) {
      final position = hash.toPosition();
      final row = position.row;
      final col = position.col;
      final target = state.board.cells[row][col];

      final canBeKnockedDown = fromCell.calculateCanBeKnockedDown(target);

      // Opposite figure available to knock
      if (canBeKnockedDown) {
        state.board.updateCell(
            row, col, (cell) => cell.copyWith(canBeKnockedDown: true));
      } else {
        state.board
            .updateCell(row, col, (cell) => cell.copyWith(isAvailable: true));
      }
    }
  }

  @protected
  @visibleForTesting
  void showAvailableActions(Cell fromCell) {
    // Wipe selected cells before follow action
    if (state.selectedFigure != null) {
      state = state.copyWith(selectedFigure: null);
      state.board.removeSelection();
    }

    if (!fromCell.isSelected) {
      _displayAvailableCells(fromCell);
    }

    final fromRow = fromCell.position.row;
    final fromCol = fromCell.position.col;

    state.board.updateCell(fromRow, fromCol,
        (cell) => cell.copyWith(isSelected: !fromCell.isSelected));
    state = state.copyWith(selectedFigure: fromCell.positionHash);
  }

  Future<void> _makeAIMove() async {
    await stockfishInterpreter.visualizeBoard();
    final bestMove = await stockfishInterpreter.getBestMove();
    print('========= move = $bestMove');
    if (bestMove.isNotNullOrEmpty) {
      final nextMove = bestMove!.split(" ")[1];

      assert(nextMove.length == 4);

      final fromPosition = nextMove.substring(0, 2);
      final targetPosition = nextMove.substring(2, 4);

      print('========= $fromPosition $targetPosition');

      // makeMove();
    }
  }

  @protected
  void makeMove(Cell target, {Cell? from}) async {
    final selectedPosition =
        from == null ? state.selectedFigure!.toPosition() : from.position;
    final board = state.board;
    final selectedCell =
        board.getCellAt(selectedPosition.row, selectedPosition.col);

    final isMoveAvailable = selectedCell.moveFigure(board, target);

    if (isMoveAvailable) {
      bool isAvailableForSF = true;
      final action =
          '${selectedPosition.algebraicPosition}${target.position.algebraicPosition}';
      try {
        await stockfishInterpreter.makeMovesFromCurrentPosition([action]);
      } catch (e) {
        print('========= This move is forbidden');
        isAvailableForSF = false;
      }

      if (isAvailableForSF) {
        final updatedBoard = board
          ..makeMove(selectedCell, target)
          ..removeSelection();

        state = state.copyWith(
          board: updatedBoard,
          selectedFigure: null,
          currentOrder: state.currentOrder.opposite,
        );

        if (state.currentOrder != PlayerSideMediator.playerSide) {
          await _makeAIMove();
        }

        ref.notifyListeners();
      }
    }
  }

  void dispose() {
    PlayerSideMediator.makeByDefault();
    stockfishInterpreter.disposeEngine();
  }
}
