import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/game_service.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';

class RpsGameService extends GameService {
  final GameController _controller;

  RpsGameService(this._controller) : super(_controller);

  @override
  Future<void> initialAction() async {
    // TODO: implement initialAction
  }

  @override
  void showAvailableActions(Cell fromCell) {
    // TODO: implement showAvailableActions
  }
}
