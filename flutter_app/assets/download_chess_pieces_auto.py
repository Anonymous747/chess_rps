"""
Automated script to download chess pieces from reliable sources.
This script attempts to download chess pieces from Wikimedia Commons and other public sources.
"""

import os
import urllib.request
import urllib.error
from pathlib import Path

# Direct PNG URLs for chess pieces (5 different sets)
# Using Chess.com's different piece themes for variety
# Note: These URLs may require checking terms of service for commercial use
CHESS_PIECE_URLS = {
    "classic_2d": {
        "description": "Classic 2D Neo style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/neo/150/bp.png",
            }
        }
    },
    "neon_3d": {
        "description": "Marble style pieces (neon alternative)",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/marble/150/bp.png",
            }
        }
    },
    "modern_flat": {
        "description": "8-bit retro style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/8bit/150/bp.png",
            }
        }
    },
    "fantasy_pieces": {
        "description": "Fantasy/ornate style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/alpha/150/bp.png",
            }
        }
    },
    "wooden_classic": {
        "description": "Wooden classic style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/wood/150/bp.png",
            }
        }
    },
    "staunton_pieces": {
        "description": "Staunton classic style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/staunton/150/bp.png",
            }
        }
    },
    "cburnett_pieces": {
        "description": "CBurnett classic style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/cburnett/150/bp.png",
            }
        }
    },
    "merida_pieces": {
        "description": "Merida style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/merida/150/bp.png",
            }
        }
    },
    "pirouetti_pieces": {
        "description": "Pirouetti style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/pirouetti/150/bp.png",
            }
        }
    },
    "leipzig_pieces": {
        "description": "Leipzig style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/leipzig/150/bp.png",
            }
        }
    },
    "fresca_pieces": {
        "description": "Fresca style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/fresca/150/bp.png",
            }
        }
    },
    "cardinal_pieces": {
        "description": "Cardinal style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/cardinal/150/bp.png",
            }
        }
    },
    "gioco_pieces": {
        "description": "Gioco style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/gioco/150/bp.png",
            }
        }
    },
    "california_pieces": {
        "description": "California style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/california/150/bp.png",
            }
        }
    },
    "horsey_pieces": {
        "description": "Horsey style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/horsey/150/bp.png",
            }
        }
    },
    "spatial_pieces": {
        "description": "Spatial 3D style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/spatial/150/bp.png",
            }
        }
    },
    "tournament_pieces": {
        "description": "Tournament style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/tournament/150/bp.png",
            }
        }
    },
    "regency_pieces": {
        "description": "Regency style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/regency/150/bp.png",
            }
        }
    },
    "condal_pieces": {
        "description": "Condal style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/condal/150/bp.png",
            }
        }
    },
    "dubrovny_pieces": {
        "description": "Dubrovny style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/dubrovny/150/bp.png",
            }
        }
    },
    "kosal_pieces": {
        "description": "Kosal style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/kosal/150/bp.png",
            }
        }
    },
    "riohacha_pieces": {
        "description": "Riohacha style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/riohacha/150/bp.png",
            }
        }
    },
    "tigershark_pieces": {
        "description": "Tigershark style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/tigershark/150/bp.png",
            }
        }
    },
    "celtic_pieces": {
        "description": "Celtic style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/celtic/150/bp.png",
            }
        }
    },
    "shapes_pieces": {
        "description": "Shapes geometric style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/shapes/150/bp.png",
            }
        }
    },
    "letter_pieces": {
        "description": "Letter/text style pieces",
        "pieces": {
            "white": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/wk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/wq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/wr.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/wb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/wn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/wp.png",
            },
            "black": {
                "king": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/bk.png",
                "queen": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/bq.png",
                "rook": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/br.png",
                "bishop": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/bb.png",
                "knight": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/bn.png",
                "pawn": "https://images.chesscomfiles.com/chess-themes/pieces/letter/150/bp.png",
            }
        }
    }
}


def download_file(url: str, destination: Path, max_size_mb: int = 10) -> bool:
    """Download a file from URL to destination with size check."""
    try:
        print(f"Downloading {url}...")
        
        # Create a request with a User-Agent header
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        
        with urllib.request.urlopen(req, timeout=30) as response:
            # Check content size
            size = int(response.headers.get('Content-Length', 0))
            if size > max_size_mb * 1024 * 1024:
                print(f"File too large: {size / 1024 / 1024:.2f} MB")
                return False
            
            # Download the file
            with open(destination, 'wb') as f:
                f.write(response.read())
        
        print(f"Downloaded to {destination}")
        return True
    except urllib.error.HTTPError as e:
        print(f"[ERROR] HTTP Error {e.code}: {e.reason}")
        return False
    except urllib.error.URLError as e:
        print(f"[ERROR] URL Error: {e.reason}")
        return False
    except Exception as e:
        print(f"[ERROR] Failed to download {url}: {e}")
        return False

def setup_directories(base_path: Path, set_name: str):
    """Create directory structure for a chess piece set."""
    pieces = ["pawn", "rook", "knight", "bishop", "queen", "king"]
    colors = ["white", "black"]
    
    for color in colors:
        color_dir = base_path / set_name / color
        color_dir.mkdir(parents=True, exist_ok=True)
        print(f"Created directory: {color_dir}")

def download_chess_pieces(set_name: str, base_path: Path):
    """Download chess pieces from reliable sources."""
    if set_name not in CHESS_PIECE_URLS:
        print(f"Unknown set: {set_name}")
        return False
    
    config = CHESS_PIECE_URLS[set_name]
    setup_directories(base_path, set_name)
    
    downloaded = 0
    
    for color in config["pieces"].keys():
        for piece_name, url in config["pieces"][color].items():
            filename = f"{piece_name}.png"
            destination = base_path / set_name / color / filename
            
            if download_file(url, destination):
                downloaded += 1
    
    print(f"\nDownloaded {downloaded} files for set '{set_name}'")
    return downloaded > 0

if __name__ == "__main__":
    # Determine the script location and create assets path
    script_dir = Path(__file__).parent
    assets_path = script_dir / "images" / "figures"
    
    print("=" * 60)
    print("Chess Piece Asset Downloader")
    print("=" * 60)
    print(f"Target directory: {assets_path.absolute()}")
    print()
    
    # Download chess piece sets to reach 25 unique packs
    print("Downloading chess piece sets to get 25 unique packs...")
    print()
    
    # Skip already downloaded sets: classic_2d, neon_3d, fantasy_pieces, wooden_classic
    # modern_flat is a duplicate, so skip it
    sets_to_download = [
        "staunton_pieces", "cburnett_pieces", "merida_pieces", "pirouetti_pieces", "leipzig_pieces",
        "fresca_pieces", "cardinal_pieces", "gioco_pieces", "california_pieces", "horsey_pieces",
        "spatial_pieces", "tournament_pieces", "regency_pieces", "condal_pieces",
        "dubrovny_pieces", "kosal_pieces", "riohacha_pieces", "tigershark_pieces", "celtic_pieces",
        "shapes_pieces", "letter_pieces"
    ]
    
    successful_downloads = 0
    failed_downloads = []
    
    for set_name in sets_to_download:
        if set_name in CHESS_PIECE_URLS:
            description = CHESS_PIECE_URLS[set_name].get("description", set_name)
            print(f"\n{'='*60}")
            print(f"Downloading set: {set_name}")
            print(f"Description: {description}")
            print(f"{'='*60}")
            try:
                if download_chess_pieces(set_name, assets_path):
                    successful_downloads += 1
                    print(f"[OK] Successfully downloaded {set_name}")
                else:
                    failed_downloads.append(set_name)
                    print(f"[FAIL] Failed to download {set_name}")
            except Exception as e:
                failed_downloads.append(set_name)
                print(f"[ERROR] Error downloading {set_name}: {e}")
        else:
            print(f"[ERROR] Unknown set: {set_name}")
            failed_downloads.append(set_name)
    
    print("\n" + "=" * 60)
    print("Download Summary")
    print("=" * 60)
    print(f"Successfully downloaded: {successful_downloads}/{len(sets_to_download)} sets")
    if failed_downloads:
        print(f"Failed sets: {', '.join(failed_downloads)}")
        print("\nYou may need to manually download chess pieces from:")
        print("  - OpenGameArt.org: https://opengameart.org/content/chess-pieces-and-board-squares-11")
        print("  - Wikimedia Commons: https://commons.wikimedia.org/wiki/Category:Chess_pieces")
    else:
        print("\nAll sets downloaded successfully!")
        print(f"\nFiles saved to: {assets_path.absolute()}/")
        print("Sets available:")
        for set_name in sets_to_download:
            if set_name not in failed_downloads:
                print(f"  - {set_name}/")

