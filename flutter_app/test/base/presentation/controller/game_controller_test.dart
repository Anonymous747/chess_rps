import 'package:chess_rps/common/enum.dart';
import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/model/position.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';
import 'package:chess_rps/presentation/state/game_state.dart';
import 'package:chess_rps/presentation/mediator/player_side_mediator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test/riverpod_test.dart';

import '../../../mocks/controller.dart';

void main() {
  group('Correct positioning of', () {
    testResultProvider(
      'Black pawn test',
      provider: gameControllerProvider,
      overrides: [
        gameControllerProvider.overrideWith(() => GameControllerMock())
      ],
      act: (c) => c.board.getCellAt(1, 1),
      expect: () {
        const position = Position(row: 1, col: 1);

        return [
          isA<Cell>()
              .having((c) => c.side, 'c.side', Side.light)
              .having((c) => c.isOccupied, 'c.isOccupied', true)
              .having((c) => c.figure?.side, 'c.figure.side', Side.dark)
              .having((c) => c.position.row, 'c.position.row', position.row)
              .having((c) => c.figure?.role, 'c.figure.role', Role.pawn),
        ];
      },
    );

    testResultProvider(
      'Black king test',
      provider: gameControllerProvider,
      overrides: [
        gameControllerProvider.overrideWith(() => GameControllerMock())
      ],
      act: (c) => c.board.getCellAt(0, 4),
      expect: () {
        const position = Position(row: 0, col: 4);

        return [
          isA<Cell>()
              .having((c) => c.side, 'c.side', Side.light)
              .having((c) => c.figure?.side, 'c.figure.side', Side.dark)
              .having((c) => c.position.row, 'c.position.row', position.row)
              .having((c) => c.figure?.role, 'c.figure.role', Role.king),
        ];
      },
    );

    testResultProvider(
      'White queen test',
      provider: gameControllerProvider,
      overrides: [
        gameControllerProvider.overrideWith(() => GameControllerMock())
      ],
      act: (c) => c.board.getCellAt(7, 3),
      expect: () {
        const position = Position(row: 7, col: 3);

        return [
          isA<Cell>()
              .having((c) => c.side, 'c.side', Side.light)
              .having((c) => c.figure?.side, 'c.figure.side', Side.light)
              .having((c) => c.figure?.position.row, 'c.figure.position.row',
                  position.row)
              .having((c) => c.figure?.role, 'c.figure.role', Role.queen),
        ];
      },
    );

    testResultProvider(
      'White rook after change player side to dark test',
      provider: gameControllerProvider,
      overrides: [
        gameControllerProvider.overrideWith(() => GameControllerMock())
      ],
      setUp: () => PlayerSideMediator.changePlayerSide(Side.dark),
      tearDown: (s) => PlayerSideMediator.makeByDefault(),
      act: (c) => c.board.getCellAt(0, 7),
      expect: () {
        const position = Position(row: 0, col: 7);

        return [
          isA<Cell>()
              .having((c) => c.side, 'c.side', Side.dark)
              .having((c) => c.figure?.side, 'c.figure.side', Side.light)
              .having((c) => c.figure?.position.row, 'c.figure.position.row',
                  position.row)
              .having((c) => c.figure?.role, 'c.figure.role', Role.rook),
        ];
      },
    );
  });

  group('Available actions check', () {
    testNotifier(
      'for pawn test',
      provider: gameControllerProvider,
      overrides: [
        gameControllerProvider.overrideWith(() => GameControllerMock())
      ],
      act: (c) {
        final fromCell = c.state.board.getCellAt(6, 3);
        c.showAvailableActions(fromCell);

        return c;
      },
      expect: () {
        return [
          isA<GameState>()
              .having((s) => s.selectedFigure, 'c.state.selectedFigure', '6-3')
              .having((s) => s.board.getCellAt(5, 3).isAvailable,
                  's.board.getCellAt(5, 3).isAvailable', true)
              .having((s) => s.board.getCellAt(3, 3).isAvailable,
                  's.board.getCellAt(3, 3).isAvailable', false)
              .having((s) => s.board.getCellAt(5, 4).isAvailable,
                  's.board.getCellAt(5, 4).isAvailable', false),
        ];
      },
    );

    testNotifier(
      'for knight after move test',
      provider: gameControllerProvider,
      overrides: [
        gameControllerProvider.overrideWith(() => GameControllerMock())
      ],
      setUp: () {
        PlayerSideMediator.changePlayerSide(Side.dark);
      },
      tearDown: () => PlayerSideMediator.makeByDefault(),
      act: (c) {
        final fromCell = c.state.board.getCellAt(0, 6);
        final targetCell = c.state.board.getCellAt(2, 5);

        c.showAvailableActions(fromCell);
        c.makeMove(targetCell);

        return c.state;
      },
      expect: () {
        return [
          isA<GameState>()
              .having((s) => s.selectedFigure, 's.selectedFigure', '0-6')
              .having((s) => s.board.getCellAt(0, 6).isOccupied,
                  's.board.getCellAt(0, 6).isOccupied', true)
              .having((s) => s.board.getCellAt(3, 7).isAvailable,
                  's.board.getCellAt(3, 7).isAvailable', false)
              .having((s) => s.board.getCellAt(1, 1).isAvailable,
                  's.board.getCellAt(1, 1).isAvailable', false),
        ];
      },
    );
  });
}
