import 'dart:async';

import 'package:stockfish_interpreter/stockfish/constants.dart';
import 'package:stockfish_interpreter/stockfish/extensions.dart';
import 'package:stockfish_interpreter/stockfish/stockfish_handler.dart';

class StockfishInterpreter {
  final int depth;
  final Map parameters;
  final bool isTestFlow;
  final bool isLoggerSwitchOn;

  StockfishInterpreter({
    required this.parameters,
    this.depth = 15,
    bool isImmediatelyStart = true,
    this.isTestFlow = false,
    this.isLoggerSwitchOn = false,
  }) {
    if (isTestFlow) return;

    _stockfishHandler = StockfishHandler();

    if (isImmediatelyStart) {
      initEngine();
    }
  }

  /// Wrapper around StockFish plugin
  ///
  late final StockfishHandler _stockfishHandler;

  /// Settings parameters
  ///
  final _parameters = {};

  bool get _isReady => _stockfishHandler.getState() == readyStatus;
  String get state => _stockfishHandler.getState();

  Future<void> _stateListener() async {
    if (_stockfishHandler.getState() == readyStatus) {
      await setupSettings();
    }
  }

  /// Wait for Stockfish to be ready (initialized and settings configured)
  /// This method polls the state until it becomes ready, with a timeout
  /// It also waits a bit after the state becomes ready to ensure setupSettings() completes
  Future<void> waitForReady({Duration timeout = const Duration(seconds: 15)}) async {
    final startTime = DateTime.now();
    
    // Poll the state until ready or timeout
    while (DateTime.now().difference(startTime) < timeout) {
      final currentState = _stockfishHandler.getState();
      
      // Check if state is disposed - this means it was disposed before initialization
      // In this case, we can't recover, so throw an error
      if (currentState == 'disposed') {
        throw Exception('Stockfish was disposed during initialization. State: disposed');
      }
      
      // If ready, wait a bit to ensure setupSettings() has completed
      if (currentState == readyStatus || _isReady) {
        // Give setupSettings() time to complete
        await Future.delayed(const Duration(milliseconds: 500));
        // Verify it's still ready
        if (_stockfishHandler.getState() == readyStatus || _isReady) {
          return;
        }
      }
      
      // Wait before checking again
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    // Timeout reached
    throw Exception('Stockfish did not become ready within ${timeout.inSeconds} seconds. Current state: ${_stockfishHandler.getState()}');
  }

  /// Initialize connection to stockfish engine
  /// Need to execute if you pass [isImmediatelyStart] as false
  ///
  void initEngine() {
    // Remove old listener if engine was already initialized
    // Check state first to see if engine exists
    final currentState = _stockfishHandler.getState();
    if (currentState != 'disposed') {
      try {
        _stockfishHandler.stateListenable.removeListener(_stateListener);
      } catch (e) {
        // Ignore errors - listener might not have been added
      }
    }
    _stockfishHandler.initEngine();
    _stockfishHandler.stateListenable.addListener(_stateListener);
  }

  /// Initialize base settings
  ///
  Future<void> setupSettings() async {
    applyCommand('uci');

    await updateEngineParameters(defaultStockfishParams);
    await updateEngineParameters(parameters);

    if (await doesCurrentEngineVersionHaveWDLOption()) {
      _setOption(uciShowWDL, true, updateParameters: true);
    }

    await setPosition();
    await _prepareForNewPosition(sendUcinewgameToken: true);
  }

  /// Connector to input of stockfish engine
  ///
  void applyCommand(String command) {
    if (_isReady) {
      _stockfishHandler.setCommand(command);
    }
  }

  void _log(String message) {
    if (isLoggerSwitchOn) {
      print('========= $message');
    }
  }

  /// Update StockFish parameters
  /// Contains (key, value) pairs which will be used to update
  /// the _parameters dictionary.
  Future<void> updateEngineParameters(Map params) async {
    if (params.isEmpty) return;

    Map newParams = params.copy();

    if (_parameters.isNotEmpty) {
      for (final key in newParams.keys) {
        if (!_parameters.containsKey(key)) {
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
      dynamic hashValue;
      if (newParams.containsKey(hash)) {
        hashValue = newParams.remove(hash);
      } else {
        hashValue = _parameters[hash];
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
      if (_parameters.containsKey(name)) {
        _parameters.update(name, (_) => value);
      } else {
        _parameters.addAll({name: value});
      }
    }
    _isReady;
  }

  Future<void> _go() async {
    applyCommand('go depth $depth');

    await _stockfishHandler.outputStream.firstWhere((output) {
      _log('_go outout = $output');
      return !output.startsWith('info');
    });
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
  Future<void> setFenPosition(
      {required String fenPosition, bool sendUcinewgameToken = true}) async {
    await _prepareForNewPosition(sendUcinewgameToken: sendUcinewgameToken);
    applyCommand('position fen $fenPosition');
  }

  /// Sets current board position
  ///
  Future<void> setPosition([List<String> moves = const []]) async {
    await setFenPosition(
      fenPosition: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
      sendUcinewgameToken: true,
    );
    await makeMovesFromCurrentPosition(moves);
  }

  /// Sets current skill level of stockfish engine
  ///
  Future<void> setSkillLevel({int skillLevel = 20}) async {
    await updateEngineParameters(
        {uciLimitStrength: false, skillLevel: skillLevel});
  }

  /// Sets current elo rating of stockfish engine, ignoring skill level
  ///
  Future<void> setEloRating({int eloRating = 1350}) async {
    await updateEngineParameters({uciLimitStrength: true, uciElo: eloRating});
  }

  /// Sets a new position by playing the moves from the current position
  /// [moves] is a list of moves to play in the current position, in order
  /// to reach a new position. Must be in full algebraic notation.
  /// Example: ["g4d7", "a8b8", "f1d1"]
  ///
  Future<void> makeMovesFromCurrentPosition(
      [List<String> moves = const []]) async {
    if (moves.isEmpty) {
      await _prepareForNewPosition(sendUcinewgameToken: false);
      return;
    }

    for (final move in moves) {
      try {
        final isCorrect = await isMoveCorrect(move);

        if (!isCorrect) {
          throw Exception('Can\'t make move: $move');
        }
      } catch (e) {
        rethrow;
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

    String fen = await _stockfishHandler.outputStream.firstWhere((output) {
      _log('fenPosition output = $output');
      return output.startsWith('Fen:');
    });
    await _stockfishHandler.outputStream.firstWhere((output) {
      _log('fenPosition output = $output');
      return output.startsWith('Checker');
    });
    final cutFen = fen.replaceFirst('Fen: ', '');

    return cutFen;
  }

  Future<void> _prepareForNewPosition({bool sendUcinewgameToken = true}) async {
    if (sendUcinewgameToken) {
      applyCommand('ucinewgame');

      await _stockfishHandler.outputStream
          .firstWhere((output) => output.startsWith(uciok));
    }
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
      await _go();
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
    final fen = await _stockfishHandler.outputStream.firstWhere((output) {
      _log('bestmove output = $output');
      return output.startsWith('bestmove');
    });

    // In case of unavailable move we'll get
    // bestmove (none)
    if (fen.split(" ").last == '(none)') {
      return null;
    }

    return fen;
  }

  /// Returns a visual representation of the current board position
  /// [isPerspectiveWhite] is a bool that indecateds whether the board should
  /// be displayed from the perspective of white (true: white, false: black)
  ///
  Future<void> visualizeBoard([bool isPerspectiveWhite = true]) async {
    applyCommand("d");

    await _stockfishHandler.outputStream.take(20).forEach((output) {
      _log('visualizeBoard output = $output');
    });
  }

  /// Close connection to stockfish engine
  ///
  void disposeEngine() {
    _stockfishHandler.stateListenable.removeListener(_stateListener);

    _stockfishHandler.disposeEngine();
  }
}
