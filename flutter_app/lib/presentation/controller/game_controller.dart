import 'dart:async';

import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/domain/service/logger.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';
import 'package:chess_rps/presentation/utils/player_side_mediator.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stockfish_interpreter/stockfish_interpreter.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  late final Side _playerSide;

  @protected
  @visibleForTesting
  late final StockfishInterpreter stockfishInterpreter;
  late final Logger actionLogger;

  @override
  GameState build() {
    stockfishInterpreter = StockfishInterpreter(
      parameters: {},
      isLoggerSwitchOn: true,
    );
    actionLogger = ref.read(loggerProvider);
    _playerSide = PlayerSideMediator.playerSide;

    if (!_playerSide.isLight) {
      _makeAIMove();
    }

    final board = Board()..startGame();
    final state = GameState(board: board, playerSide: _playerSide);

    return state;
  }

  Future<void> executeCommand() async {
    await stockfishInterpreter.visualizeBoard();
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

    if (bestMove.isNotNullOrEmpty) {
      final bestAction = bestMove!.split(" ")[1];

      assert(bestAction.length == 4);

      final fromPosition = bestAction.substring(0, 2).convertToPosition();
      final targetPosition = bestAction.substring(2, 4).convertToPosition();

      final fromCell =
          state.board.getCellAt(fromPosition.row, fromPosition.col);
      final targetCell =
          state.board.getCellAt(targetPosition.row, targetPosition.col);

      makeMoveViaAction(bestAction, fromCell, targetCell);
    }
  }

  @protected
  @visibleForTesting
  void makeMove(Cell target, {Cell? from}) async {
    final board = state.board;

    Cell selectedCell;
    if (from == null) {
      final selectedPosition =
          from == null ? state.selectedFigure!.toPosition() : from.position;
      selectedCell =
          board.getCellAt(selectedPosition.row, selectedPosition.col);
    } else {
      selectedCell = from;
    }

    final isMoveAvailable = selectedCell.moveFigure(board, target);

    if (isMoveAvailable) {
      final action =
          '${selectedCell.position.algebraicPosition}${target.position.algebraicPosition}';

      await makeMoveViaAction(action, selectedCell, target);
    }
  }

  Future<void> makeMoveViaAction(
      String action, Cell selectedCell, Cell targetCell) async {
    bool isAvailableForSF = true;
    try {
      await stockfishInterpreter.makeMovesFromCurrentPosition([action]);
    } catch (e) {
      isAvailableForSF = false;
    }

    if (isAvailableForSF) {
      final updatedBoard = state.board
        ..makeMove(selectedCell, targetCell)
        ..removeSelection();

      state = state.copyWith(
        board: updatedBoard,
        selectedFigure: null,
        currentOrder: state.currentOrder.opposite,
      );

      actionLogger.add(action);

      if (state.currentOrder != PlayerSideMediator.playerSide) {
        await _makeAIMove();
      }

      ref.notifyListeners();
    }
  }

  void dispose() {
    PlayerSideMediator.makeByDefault();

    stockfishInterpreter.disposeEngine();
  }
}
