import 'dart:async';

import 'package:stockfish_interpreter/stockfish/constants.dart';
import 'package:stockfish_interpreter/stockfish/extensions.dart';
import 'package:stockfish_interpreter/stockfish/stockfish_handler.dart';

const _readyStatus = 'ready';

class StockfishInterpreter {
  final int depth;
  final Map parameters;
  final bool isTestFlow;

  StockfishInterpreter({
    required this.parameters,
    this.depth = 15,
    bool isImmediatelyStart = true,
    this.isTestFlow = false,
  }) {
    if (isTestFlow) return;

    _stockfishHandler = StockfishHandler();

    print('========= a');
    if (isImmediatelyStart) {
      initEngine();
    }
  }

  late final StockfishHandler _stockfishHandler;
  Map _parametrs = {};

  bool get _isReady => _stockfishHandler.getState() == _readyStatus;
  StreamSubscription<String> get outoutStreamListener =>
      _stockfishHandler.outputStream.listen((event) {
        print('========= output = $event');
      });

  /// Initialize connection to stockfish engine
  /// Need to execute if you pass [isImmediatelyStart] as false
  ///
  void initEngine() async {
    _stockfishHandler.initEngine();

    applyCommand('uci');

    updateEngineParameters(defaultStockfishParams);
    updateEngineParameters(parameters);

    if (await doesCurrentEngineVersionHaveWDLOption()) {
      _setOption(uciShowWDL, true, updateParameters: false);
    }

    _prepareForNewPosition(sendUcinewgameToken: true);

    print('========= paramaters = $_parametrs');
  }

  /// Connector to input of stockfish engine
  ///
  void applyCommand(String command) {
    if (_isReady) {
      _stockfishHandler.setCommand(command);
    }
  }

  /// Update StockFish parameters
  /// Contains (key, value) pairs which will be used to update
  /// the _parameters dictionary.
  void updateEngineParameters(Map params) async {
    if (params.isEmpty) return;

    Map newParams = params.copy();

    if (_parametrs.isNotEmpty) {
      for (final key in newParams.keys) {
        if (!_parametrs.containsKey(key)) {
          throw Exception('$key is not a key that exist');
        }
      }
    }

    if (newParams[skillLevel] != newParams[uciElo] &&
        !newParams.keys.contains(uciLimitStrength)) {
      // This means the user wants to update the Skill Level or UCI_Elo (only one,
      // not both), and that they didn't specify a new value for UCI_LimitStrength.
      // So, update UCI_LimitStrength, in case it's not the right value currently.
      if (newParams.containsKey(skillLevel)) {
        newParams.update(uciLimitStrength, (value) => false);
      } else if (newParams.containsKey(uciElo)) {
        newParams.update(uciLimitStrength, (value) => true);
      }
    }

    if (newParams.containsKey(threads)) {
      final threadValue = newParams[threads];
      newParams.remove(threads);
      var hashValue;
      if (newParams.containsKey(hash)) {
        hashValue = newParams.remove(hash);
      } else {
        hashValue = _parametrs[hash];
      }

      newParams[threads] = threadValue;
      newParams[hash] = hashValue;
    }

    newParams.forEach((key, value) {
      _setOption(key, value, updateParameters: true);
    });
    setFenPosition(
        fenPosition: await getFenPosition(), sendUcinewgameToken: false);
  }

  /// Reset the stockfish parameters
  ///
  void resetEngineParameters() {
    updateEngineParameters(defaultStockfishParams);
  }

  void _setOption(
    String name,
    dynamic value, {
    bool updateParameters = true,
  }) {
    applyCommand('setoption name $name value $value');
    if (updateParameters) {
      if (_parametrs.containsKey(name)) {
        _parametrs.update(name, (_) => value);
      } else {
        _parametrs.addAll({name: value});
      }
    }
    _isReady;
  }

  void _go() {
    applyCommand('go depth $depth');
  }

  void _goTime(int time) {
    applyCommand('go movetime $time');
  }

  void _goRemainingTime(int? wtime, int? btime) {
    String cmd = 'go';

    if (wtime != null) {
      cmd += ' wtime $wtime';
    }

    if (btime != null) {
      cmd += ' btime $btime';
    }

    applyCommand(cmd);
  }

  /// Returns whether the user's version of Stockfish has the option
  /// true is SF has the option, false - otherwise
  ///
  Future<bool> doesCurrentEngineVersionHaveWDLOption() async {
    applyCommand('uci');

    final text = await _stockfishHandler.outputStream.firstWhere((output) {
      // final isEnd = output.startsWith(uckiok);
      final splittedText = output.split(" ");
      return splittedText[0] == uciok || splittedText.contains(uciShowWDL);
    });

    // If we find only uciok, then false
    return !text.startsWith(uciok);
  }

  /// Sets current board position in Forsyth-Edwards notation (FEN).
  /// [fenPosition] is a string of board position
  /// [sendUcinewgameToken] Whether to send the "ucinewgame" token to the Stockfish engine.
  /// The most prominent effect this will have is clearing Stockfish's transporation table,
  /// which should be done if the new position is unrelated to current position
  ///
  void setFenPosition(
      {required String fenPosition, bool sendUcinewgameToken = true}) {
    _prepareForNewPosition(sendUcinewgameToken: sendUcinewgameToken);
    applyCommand('position fen $fenPosition');
  }

  /// Sets current board position
  ///
  void setPosition(List<String> moves) {
    setFenPosition(
      fenPosition: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      sendUcinewgameToken: true,
    );
    makeMovesFromCurrentPosition(moves: moves);
  }

  /// Sets current skill level of stockfish engine
  ///
  void setSkillLevel({int skillLevel = 20}) {
    updateEngineParameters({uciLimitStrength: false, skillLevel: skillLevel});
  }

  /// Sets current elo rating of stockfish engine, ignoring skill level
  ///
  void setEloRating({int eloRating = 1350}) {
    updateEngineParameters({uciLimitStrength: true, uciElo: eloRating});
  }

  /// Sets a new position by playing the moves from the current position
  /// [moves] is a list of moves to play in the current position, in order
  /// to reach a new position. Must be in full algebraic notation.
  /// Example: ["g4d7", "a8b8", "f1d1"]
  ///
  void makeMovesFromCurrentPosition({List<String> moves = const []}) async {
    if (moves.isEmpty) return;

    for (final move in moves) {
      if (!await isMoveCorrect(move)) {
        throw Exception('Can\'t make move: $move');
      }

      final fenPosition = await getFenPosition();
      applyCommand('position fen $fenPosition moves $move');
    }
  }

  /// Returns current board position in Forsyth-Edwards notation (FEN).
  /// Returns string with current position on Forsyth-Edwards notation (FEN).
  ///
  Future<String> getFenPosition() async {
    applyCommand('d');

    String fen = '';
    StreamSubscription<String>? subscriber;
    subscriber = _stockfishHandler.outputStream.distinct().listen((output) {
      if (output.startsWith('Fen:')) {
        fen = output;
      } else if (output.startsWith('Checker')) {
        subscriber?.cancel();
      }
    });

    return fen;
  }

  void _prepareForNewPosition({bool sendUcinewgameToken = true}) {
    if (sendUcinewgameToken) {
      applyCommand('ucinewgame');
    }
  }

  /// Code for this function taken from: https://gist.github.com/Dani4kor/e1e8b439115878f8c6dcf127a4ed5d3e
  /// Some small changes have been made to the code.
  ///
  bool _isFenSyntaxValide(String fen) {
    bool isRegexMatch = RegExp(
      r"\s*^(((?:[rnbqkpRNBQKP1-8]+\/){7})[rnbqkpRNBQKP1-8]+)\s([b|w])\s(-|[K|Q|k|q]{1,4})\s(-|[a-h][1-8])\s(\d+\s\d+)$",
    ).hasMatch(fen);

    if (!isRegexMatch) return false;

    // TODO: Finish fen check impl

    return true;
  }

  /// Checks new move
  /// [move] - New move value in algebraic notation
  ///
  Future<bool> isMoveCorrect(String move) async {
    applyCommand('go depth 1 searchmoves $move');

    final isMoveAvailable = await _getBestMoveFromSfPopenProcess() != null;

    return isMoveAvailable;
  }

  /// Returns best move with current position on the board.
  /// [wtime] and [btime] arguments influence the search only if provided.
  ///
  Future<String?> getBestMove({int? wtime, int? btime}) async {
    if (wtime != null && btime != null) {
      _goRemainingTime(wtime, btime);
    } else {
      _go();
    }

    return _getBestMoveFromSfPopenProcess();
  }

  /// Returns best move with current position on the board after a determined time
  /// Time for stockfish to determine best move in milliseconds
  ///
  Future<String?> getBestMoveTime({int time = 1000}) async {
    _goTime(time);
    return _getBestMoveFromSfPopenProcess();
  }

  /// Precondition - a "go" command must have been sent to SF before calling this function.
  /// This function needs existing output to read from the SF popen process.
  ///
  Future<String?> _getBestMoveFromSfPopenProcess() async {
    final fen = await _stockfishHandler.outputStream
        .firstWhere((output) => output.startsWith('bestmove'));

    // In case of unavailable move we'll get
    // bestmove (none)
    if (fen.split(" ").last == '(none)') {
      return null;
    }

    return fen;
  }

  /// Close connection to stockfish engine
  ///
  void disposeEngine() {
    outoutStreamListener.cancel();
    _stockfishHandler.disposeEngine();
  }
}