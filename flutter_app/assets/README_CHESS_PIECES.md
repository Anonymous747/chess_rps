# Chess Piece Assets Organization

This directory contains chess piece images organized by set and color.

## Current Structure

```
assets/images/figures/
├── black/
│   ├── bishop.png
│   ├── king.png
│   ├── knight.png
│   ├── pawn.png
│   ├── queen.png
│   └── rook.png
└── white/
    ├── bishop.png
    ├── king.png
    ├── knight.png
    ├── pawn.png
    ├── queen.png
    └── rook.png
```

## Recommended Structure for Multiple Sets

To support multiple chess piece sets (as referenced in the collection system), you can organize them like this:

```
assets/images/figures/
├── classic_2d/
│   ├── black/
│   │   └── [piece files]
│   └── white/
│       └── [piece files]
├── neon_3d/
│   ├── black/
│   └── white/
├── modern_flat/
│   ├── black/
│   └── white/
└── fantasy_pieces/
    ├── black/
    └── white/
```

## Free Chess Piece Resources

### 1. OpenGameArt.org
- **URL**: https://opengameart.org/content/chess-pieces-and-board-squares-11
- **License**: CC0 (Public Domain)
- **Format**: PNG with transparency

### 2. Wikimedia Commons
- **URL**: https://commons.wikimedia.org/wiki/Category:Chess_pieces
- **License**: Various public domain and CC licenses
- **Format**: SVG, PNG

### 3. Flaticon
- **URL**: https://www.flaticon.com/packs/chess-pieces
- **License**: Free with attribution
- **Format**: PNG, SVG

### 4. Chess.com Assets
- Chess.com provides their piece images (check their terms of service)
- Often available via browser developer tools on chess.com

### 5. Chess.js Repository
- Some chess libraries include piece images
- Check: https://github.com/jhlywa/chess.js (not directly, but related projects)

## Download Instructions

### Manual Download:
1. Visit one of the recommended sources above
2. Download chess piece images (both white and black sets)
3. Name files as: `pawn.png`, `rook.png`, `knight.png`, `bishop.png`, `queen.png`, `king.png`
4. Place them in the appropriate directory structure

### Using the Script:
1. Update `download_chess_pieces.py` with working URLs
2. Run: `python download_chess_pieces.py`
3. Follow the prompts

## Piece Set Requirements

Each piece set should have:
- **6 pieces**: pawn, rook, knight, bishop, queen, king
- **2 colors**: white and black
- **Format**: PNG with transparent background (recommended)
- **Size**: Consistent size across all pieces (recommended: 512x512 or 256x256)

## Integration with Collection System

The collection system references piece sets by name (e.g., "neon_3d", "classic_2d"). Update the asset loading code in `cell_widget.dart` to support multiple sets based on user settings.

