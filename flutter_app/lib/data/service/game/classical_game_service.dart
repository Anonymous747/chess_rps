import 'package:chess_rps/domain/model/cell.dart';
import 'package:chess_rps/domain/service/game_service.dart';
import 'package:chess_rps/presentation/controller/game_controller.dart';

class ClassicalGameService extends GameService {
  ClassicalGameService(GameController controller) : super(controller) {
    initialAction();
  }

  @override
  Future<void> initialAction() async {
    if (!isUsersMove) {
      await controller.makeOpponentsMove();
    }
  }

  @override
  Future<void> onPressed(Cell pressedCell) async {
    super.onPressed(pressedCell);
  }
}
