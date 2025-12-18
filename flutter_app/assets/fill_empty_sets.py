"""
Fill empty chess piece sets with pieces from available themes.
"""

import urllib.request
import urllib.error
from pathlib import Path
import time

# Available themes to use for filling empty sets
AVAILABLE_THEMES = [
    "neo", "marble", "alpha", "wood", "staunton", "cburnett", "merida",
    "tournament", "condal", "classic", "modern", "vintage", "glass", "metal"
]


def get_chesscom_url(theme, piece, color, size="150"):
    """Generate Chess.com piece URL"""
    color_prefix = "w" if color == "white" else "b"
    piece_code = {
        "king": "k", "queen": "q", "rook": "r",
        "bishop": "b", "knight": "n", "pawn": "p"
    }[piece]
    return f"https://images.chesscomfiles.com/chess-themes/pieces/{theme}/{size}/{color_prefix}{piece_code}.png"


def download_file(url, destination):
    """Download a file"""
    try:
        req = urllib.request.Request(url, headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        with urllib.request.urlopen(req, timeout=10) as response:
            with open(destination, 'wb') as f:
                f.write(response.read())
        return True
    except:
        return False


def fill_empty_set(set_name, theme, base_path, size="150"):
    """Fill an empty chess piece set"""
    pieces = ["king", "queen", "rook", "bishop", "knight", "pawn"]
    colors = ["white", "black"]
    
    set_path = base_path / set_name
    
    # Ensure directories exist
    for color in colors:
        (set_path / color).mkdir(parents=True, exist_ok=True)
    
    downloaded = 0
    
    for color in colors:
        for piece in pieces:
            dest = set_path / color / f"{piece}.png"
            
            # Skip if already exists
            if dest.exists():
                downloaded += 1
                continue
            
            url = get_chesscom_url(theme, piece, color, size)
            if download_file(url, dest):
                downloaded += 1
    
    return downloaded >= 10


def main():
    script_dir = Path(__file__).parent
    assets_path = script_dir / "images" / "figures"
    
    # Find empty sets
    empty_sets = []
    for item in assets_path.iterdir():
        if item.is_dir() and item.name not in ["black", "white"]:
            white_path = item / "white"
            black_path = item / "black"
            
            if white_path.exists() and black_path.exists():
                white_count = len(list(white_path.glob("*.png")))
                black_count = len(list(black_path.glob("*.png")))
                
                if white_count == 0 or black_count == 0:
                    empty_sets.append(item.name)
    
    print("=" * 60)
    print("Filling Empty Chess Piece Sets")
    print("=" * 60)
    print(f"Found {len(empty_sets)} empty sets")
    print()
    
    if not empty_sets:
        print("No empty sets found!")
        return
    
    print("Empty sets to fill:")
    for s in empty_sets:
        print(f"  - {s}")
    print()
    
    successful = []
    failed = []
    theme_idx = 0
    
    for set_name in empty_sets:
        # Use different themes for different sets to ensure variety
        theme = AVAILABLE_THEMES[theme_idx % len(AVAILABLE_THEMES)]
        theme_idx += 1
        
        print(f"Filling {set_name} with {theme} theme...", end=" ")
        
        try:
            if fill_empty_set(set_name, theme, assets_path):
                successful.append(set_name)
                print("[OK]")
            else:
                failed.append(set_name)
                print("[FAIL]")
        except Exception as e:
            failed.append(set_name)
            print(f"[ERROR: {e}]")
        
        time.sleep(0.2)
    
    print()
    print("=" * 60)
    print("Summary")
    print("=" * 60)
    print(f"Successfully filled: {len(successful)}/{len(empty_sets)} sets")
    
    if successful:
        print("\nFilled sets:")
        for s in successful:
            print(f"  - {s}")
    
    if failed:
        print(f"\nFailed sets ({len(failed)}):")
        for s in failed:
            print(f"  - {s}")


if __name__ == "__main__":
    main()

