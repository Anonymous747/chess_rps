// Statuses
const uciok = 'uciok';
const readyStatus = 'ready';

// Params
const debugLogFile = "Debug Log File";
const contempt = "Contempt";
const minSplitDepth = "Min Split Depth";
const threads = "Threads";
const ponder = "Ponder";
const hash = "Hash";
const multiPV = "MultiPV";
const skillLevel = "Skill Level";
const moveOverhead = "Move Overhead";
const minimumThinkingTime = "Minimum Thinking Time";
const slowMover = "Slow Mover";
const uciChess960 = "UCI_Chess960";
const uciLimitStrength = "UCI_LimitStrength";
const uciElo = "UCI_Elo";
const uciShowWDL = "UCI_ShowWDL";

const defaultStockfishParams = {
  debugLogFile: "",
  contempt: 0,
  minSplitDepth: 0,
  threads: 1,
  ponder: false,
  hash: 16,
  multiPV: 1,
  skillLevel: 20,
  moveOverhead: 10,
  minimumThinkingTime: 20,
  slowMover: 100,
  uciChess960: false,
  uciLimitStrength: false,
  uciElo: 1350,
};
