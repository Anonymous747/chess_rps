import 'dart:async';

import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stockfish_interpreter/stockfish_interpreter.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  // late final AIHandler _stockfishHandler;
  @protected
  @visibleForTesting
  late final StockfishInterpreter stockfishInterpreter;

  @override
  GameState build() {
    // _stockfishHandler = ref.read(createAIHandlerProvider)..initEngine();
    stockfishInterpreter = StockfishInterpreter(parameters: {});

    final board = Board()..startGame();
    final state = GameState(board: board);

    // stockfishInterpreter.outoutStreamListener;
    return state;
  }

  Future<void> executeCommand(String command) async {
    // _stockfishHandler.setCommand(command);
    stockfishInterpreter.applyCommand(command);

    // final a = await stockfishInterpreter.getFenPosition();
    // print('========= a = $a');
    // stockfishInterpreter.isMoveCorrect('e2e4');
  }

  @protected
  void makeMove(Cell target) {
    final selectedPosition = state.selectedFigure!.toPosition();
    final board = state.board;
    final selectedCell =
        board.getCellAt(selectedPosition.row, selectedPosition.col);

    final isMoveAvailable = selectedCell.moveFigure(board, target);

    if (isMoveAvailable) {
      final updatedBoard = board
        ..makeMove(selectedCell, target)
        ..removeSelection();

      state = state.copyWith(
        board: updatedBoard,
        selectedFigure: null,
        currentOrder: state.currentOrder.opposite,
      );

      ref.notifyListeners();
    }
  }

  void onPressed(Cell pressedCell) {
    final currentOrder = state.currentOrder;

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
        state.board.cells[row][col] =
            state.board.cells[row][col].copyWith(canBeKnockedDown: true);
      } else {
        state.board.cells[row][col] =
            state.board.cells[row][col].copyWith(isAvailable: true);
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

    state.board.cells[fromRow][fromCol] =
        fromCell.copyWith(isSelected: !fromCell.isSelected);
    state = state.copyWith(selectedFigure: fromCell.positionHash);
  }

  void dispose() {
    stockfishInterpreter.disposeEngine();
    // _stockfishHandler.disposeEngine();
  }
}
