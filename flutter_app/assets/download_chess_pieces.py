"""
Script to download chess piece assets from various sources.
This script provides functionality to download and organize chess piece images.
"""

import os
import urllib.request
from pathlib import Path

# Base URL for chess pieces from a reliable source
# Note: You'll need to update these URLs with actual working download links
CHESS_PIECE_SETS = {
    "classic_2d": {
        "url_template": "https://opengameart.org/sites/default/files/styles/medium/public/{piece}_{color}.png",
        "pieces": ["pawn", "rook", "knight", "bishop", "queen", "king"],
        "colors": ["white", "black"]
    },
    "modern_3d": {
        "url_template": "https://raw.githubusercontent.com/niklasf/chessground/master/src/assets/piece/{piece}_{color}.png",
        "pieces": ["pawn", "rook", "knight", "bishop", "queen", "king"],
        "colors": ["white", "black"]
    }
}

def download_file(url: str, destination: Path) -> bool:
    """Download a file from URL to destination."""
    try:
        print(f"Downloading {url}...")
        urllib.request.urlretrieve(url, destination)
        print(f"✓ Downloaded to {destination}")
        return True
    except Exception as e:
        print(f"✗ Failed to download {url}: {e}")
        return False

def setup_chess_pieces_directory(base_path: Path, set_name: str):
    """Create directory structure for a chess piece set."""
    pieces = ["pawn", "rook", "knight", "bishop", "queen", "king"]
    colors = ["white", "black"]
    
    for color in colors:
        color_dir = base_path / set_name / color
        color_dir.mkdir(parents=True, exist_ok=True)
        print(f"Created directory: {color_dir}")

def download_chess_pieces_set(set_name: str, base_path: Path):
    """Download a complete set of chess pieces."""
    if set_name not in CHESS_PIECE_SETS:
        print(f"Unknown set: {set_name}")
        return False
    
    config = CHESS_PIECE_SETS[set_name]
    setup_chess_pieces_directory(base_path, set_name)
    
    downloaded = 0
    for piece in config["pieces"]:
        for color in config["colors"]:
            filename = f"{piece}.png"
            url = config["url_template"].format(piece=piece, color=color)
            destination = base_path / set_name / color / filename
            
            if download_file(url, destination):
                downloaded += 1
    
    print(f"\nDownloaded {downloaded} files for set '{set_name}'")
    return downloaded > 0

if __name__ == "__main__":
    # Determine the script location and create assets path
    script_dir = Path(__file__).parent
    assets_path = script_dir / "images" / "figures"
    
    print("Chess Piece Asset Downloader")
    print("=" * 50)
    print(f"Target directory: {assets_path}")
    print("\nAvailable sets:")
    for set_name in CHESS_PIECE_SETS.keys():
        print(f"  - {set_name}")
    print("\nNote: You may need to update the URLs in this script")
    print("with actual working download links from chess piece resources.")
    print("\nRecommended sources:")
    print("1. https://opengameart.org/ - Open source game art")
    print("2. https://commons.wikimedia.org/wiki/Category:Chess_pieces - Public domain")
    print("3. https://www.flaticon.com/packs/chess-pieces - Icon packs")
    print("4. Create your own or use the existing pieces in the figures/ directory")

