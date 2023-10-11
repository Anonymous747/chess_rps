import 'dart:async';

import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:chess_rps/domain/service/logger.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/presentation/utils/action_checker.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  @protected
  @visibleForTesting
  late final ActionHandler actionHandler;
  @protected
  @visibleForTesting
  late final Logger actionLogger;

  @override
  GameState build() {
    actionHandler = ref.read(actionHandlerProvider);
    actionLogger = ref.read(loggerProvider);

    final playerSide = PlayerSideMediator.playerSide;

    final board = Board()..startGame();
    final state = GameState(board: board, playerSide: playerSide);

    if (!playerSide.isLight) {
      _makeAIMove();
    }

    return state;
  }

  Future<void> executeCommand() async {
    await actionHandler.visualizeBoard();
  }

  void onPressed(Cell pressedCell) {
    final currentOrder = state.currentOrder;

    if (pressedCell.isAvailable || pressedCell.canBeKnockedDown) {
      assert(state.selectedFigure != null, "Figure should be chosen");
      makeMove(pressedCell);
    }

    if (pressedCell.isOccupied &&
        pressedCell.figureSide == currentOrder &&
        pressedCell.figure!.side == PlayerSideMediator.playerSide) {
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
    final bestMove = await actionHandler.getOpponentsMove();

    if (bestMove.isNotNullOrEmpty) {
      final bestAction = bestMove!.split(" ")[1];

      assert(bestAction.length == 4);

      final fromPosition = bestAction.substring(0, 2).convertToPosition();
      final targetPosition = bestAction.substring(2, 4).convertToPosition();

      final fromCell =
          state.board.getCellAt(fromPosition.row, fromPosition.col);
      final targetCell =
          state.board.getCellAt(targetPosition.row, targetPosition.col);

      await _makeMoveViaAction(bestAction, fromCell, targetCell);
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

      await _makeMoveViaAction(action, selectedCell, target);
    }
  }

  Future<void> _makeMoveViaAction(
      String action, Cell selectedCell, Cell targetCell) async {
    bool isAvailableForOpponent = true;
    try {
      await actionHandler.makeMove(action);
    } catch (e) {
      isAvailableForOpponent = false;
    }

    if (isAvailableForOpponent) {
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

    actionHandler.dispose();
  }
}
