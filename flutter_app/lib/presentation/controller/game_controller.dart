import 'dart:async';

import 'package:chess_rps/common/extension.dart';
import 'package:chess_rps/domain/model/board.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/domain/service/action_handler.dart';
import 'package:chess_rps/domain/service/game_strategy.dart';
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

  @protected
  @visibleForTesting
  late final GameStrategy gameStrategy;

  GameState get currentState => state;

  @override
  GameState build() {
    actionHandler = ref.read(actionHandlerProvider);
    actionLogger = ref.read(loggerProvider);
    gameStrategy = ref.read(gameStrategyProvider);

    final playerSide = PlayerSideMediator.playerSide;

    final board = Board()..startGame();
    final state = GameState(board: board, playerSide: playerSide);

    return state;
  }

  Future<void> onPressed(Cell pressedCell) async {
    await gameStrategy.onPressed(this, state, pressedCell);
  }

  void _displayAvailableCells(Cell fromCell) {
    final availableHashes =
        ActionChecker.getAvailablePositionsHash(state.board, fromCell);

    for (final hash in availableHashes) {
      final position = hash.toPosition();
      final row = position.row;
      final col = position.col;
      final target = state.board.getCellAt(row, col);

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

  /// Return the result is Opponents move has a correct status
  ///
  Future<bool> makeOpponentsMove() async {
    final bestMove = await actionHandler.getOpponentsMove();

    if (bestMove.isNullOrEmpty) return false;

    final bestAction = bestMove!.split(" ")[1];

    assert(bestAction.length == 4);

    final fromPosition = bestAction.substring(0, 2).convertToPosition();
    final targetPosition = bestAction.substring(2, 4).convertToPosition();

    final fromCell = state.board.getCellAt(fromPosition.row, fromPosition.col);
    final targetCell =
        state.board.getCellAt(targetPosition.row, targetPosition.col);

    return await _makeMoveViaAction(bestAction, fromCell, targetCell);
  }

  /// Return the result is Opponents move has a correct status
  ///
  Future<bool> makeMove(Cell target, {Cell? from}) async {
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

    if (!isMoveAvailable) return false;

    final action =
        '${selectedCell.position.algebraicPosition}${target.position.algebraicPosition}';

    return await _makeMoveViaAction(action, selectedCell, target);
  }

  Future<bool> _makeMoveViaAction(
      String action, Cell selectedCell, Cell targetCell) async {
    try {
      await actionHandler.makeMove(action);
    } catch (e) {
      return false;
    }

    final updatedBoard = state.board
      ..makeMove(selectedCell, targetCell)
      ..removeSelection();

    state = state.copyWith(
      board: updatedBoard,
      selectedFigure: null,
      currentOrder: state.currentOrder.opposite,
    );

    actionLogger.add(action);

    return true;
  }

  void dispose() {
    PlayerSideMediator.makeByDefault();

    actionHandler.dispose();
  }

  Future<void> executeCommand() async {
    await actionHandler.visualizeBoard();
  }
}
