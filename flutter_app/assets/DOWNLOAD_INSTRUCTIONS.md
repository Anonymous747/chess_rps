# Download Chess Piece Assets

## Quick Start

Since I cannot directly download files from the internet, here are the best resources and steps to get chess piece assets:

## Best Free Resources

### 1. **OpenGameArt.org** (Recommended - CC0 License)
- **URL**: https://opengameart.org/content/chess-pieces-and-board-squares-11
- **License**: CC0 (Public Domain - free to use)
- **Format**: PNG with transparency
- **Steps**:
  1. Visit the link above
  2. Click "Download" button
  3. Extract the ZIP file
  4. Look for chess piece images
  5. Organize them into the directory structure below

### 2. **Wikimedia Commons** (Public Domain)
- **URL**: https://commons.wikimedia.org/wiki/Category:Chess_pieces
- **License**: Public Domain or CC licenses
- **Format**: SVG and PNG
- **Steps**:
  1. Browse the category
  2. Download individual piece images
  3. Convert SVG to PNG if needed (using Inkscape or online converter)

### 3. **Chess.com Piece Sets** (Check License)
- Visit chess.com and inspect their piece images
- Some browsers allow saving images directly
- **Important**: Check their terms of service before commercial use

### 4. **Free Icon Sites**
- **Flaticon**: https://www.flaticon.com/packs/chess-pieces (free with attribution)
- **Icons8**: https://icons8.com/icons/set/chess (free with attribution)

## Directory Structure

After downloading, organize files like this:

```
assets/images/figures/
├── classic_2d/          # Traditional 2D chess pieces
│   ├── black/
│   │   ├── pawn.png
│   │   ├── rook.png
│   │   ├── knight.png
│   │   ├── bishop.png
│   │   ├── queen.png
│   │   └── king.png
│   └── white/
│       ├── pawn.png
│       ├── rook.png
│       ├── knight.png
│       ├── bishop.png
│       ├── queen.png
│       └── king.png
├── neon_3d/             # Neon/glow style pieces
│   ├── black/
│   └── white/
├── modern_flat/         # Flat design pieces
│   ├── black/
│   └── white/
└── fantasy_pieces/      # Fantasy-themed pieces
    ├── black/
    └── white/
```

## File Naming Convention

- Use lowercase: `pawn.png`, not `Pawn.PNG`
- PNG format recommended (supports transparency)
- Consistent sizing (recommended: 256x256 or 512x512 pixels)

## Current Default Pieces

The app currently uses pieces in:
- `assets/images/figures/white/`
- `assets/images/figures/black/`

These are the default pieces. For the collection system to work with different sets, you'll need to create the set directories above.

## Integration

Once you have multiple sets downloaded:
1. Update `cell_widget.dart` to support dynamic piece set selection
2. The piece set will be selected based on user's collection/settings
3. Asset paths should follow: `assets/images/figures/{pieceSet}/{color}/{piece}.png`

## Automated Download (Future)

If you find a reliable public repository with direct download links, update `download_chess_pieces.ps1` with the URLs and run it.

