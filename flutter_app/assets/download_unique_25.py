"""
Download 25 truly unique chess piece sets from various public sources.
No variations - only different base sets.
"""

import urllib.request
import urllib.error
from pathlib import Path
import time

# Try multiple different piece styles from Chess.com and other sources
UNIQUE_CHESS_SETS = {
    "neo": {"theme": "neo", "desc": "Neo style"},
    "marble": {"theme": "marble", "desc": "Marble style"},
    "alpha": {"theme": "alpha", "desc": "Alpha/Ornate style"},
    "wood": {"theme": "wood", "desc": "Wooden style"},
    "staunton": {"theme": "staunton", "desc": "Staunton style"},
    "cburnett": {"theme": "cburnett", "desc": "CBurnett style"},
    "merida": {"theme": "merida", "desc": "Merida style"},
    "pirouetti": {"theme": "pirouetti", "desc": "Pirouetti style"},
    "leipzig": {"theme": "leipzig", "desc": "Leipzig style"},
    "fresca": {"theme": "fresca", "desc": "Fresca style"},
    "cardinal": {"theme": "cardinal", "desc": "Cardinal style"},
    "gioco": {"theme": "gioco", "desc": "Gioco style"},
    "california": {"theme": "california", "desc": "California style"},
    "horsey": {"theme": "horsey", "desc": "Horsey style"},
    "spatial": {"theme": "spatial", "desc": "Spatial 3D style"},
    "tournament": {"theme": "tournament", "desc": "Tournament style"},
    "regency": {"theme": "regency", "desc": "Regency style"},
    "condal": {"theme": "condal", "desc": "Condal style"},
    "dubrovny": {"theme": "dubrovny", "desc": "Dubrovny style"},
    "kosal": {"theme": "kosal", "desc": "Kosal style"},
    "riohacha": {"theme": "riohacha", "desc": "Riohacha style"},
    "tigershark": {"theme": "tigershark", "desc": "Tigershark style"},
    "celtic": {"theme": "celtic", "desc": "Celtic style"},
    "shapes": {"theme": "shapes", "desc": "Shapes geometric style"},
    "letter": {"theme": "letter", "desc": "Letter/text style"},
    "royal": {"theme": "royal", "desc": "Royal style"},
    "modern": {"theme": "modern", "desc": "Modern style"},
    "ancient": {"theme": "ancient", "desc": "Ancient style"},
    "classic": {"theme": "classic", "desc": "Classic style"},
    "vintage": {"theme": "vintage", "desc": "Vintage style"},
    "glass": {"theme": "glass", "desc": "Glass style"},
    "metal": {"theme": "metal", "desc": "Metal style"},
    "stone": {"theme": "stone", "desc": "Stone style"},
    "plastic": {"theme": "plastic", "desc": "Plastic style"},
}


def get_chesscom_url(theme, piece, color, size="150"):
    """Generate Chess.com piece URL"""
    color_prefix = "w" if color == "white" else "b"
    piece_code = {
        "king": "k", "queen": "q", "rook": "r",
        "bishop": "b", "knight": "n", "pawn": "p"
    }[piece]
    return f"https://images.chesscomfiles.com/chess-themes/pieces/{theme}/{size}/{color_prefix}{piece_code}.png"


def download_file(url, destination, max_size_mb=10, retries=1):
    """Download a file with retries"""
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            })
            with urllib.request.urlopen(req, timeout=10) as response:
                size = int(response.headers.get('Content-Length', 0))
                if size > max_size_mb * 1024 * 1024:
                    return False
                with open(destination, 'wb') as f:
                    f.write(response.read())
            return True
        except (urllib.error.HTTPError, urllib.error.URLError, Exception):
            if attempt < retries:
                time.sleep(0.5)
                continue
            return False
    return False


def download_set(set_name, config, base_path):
    """Download a complete chess piece set"""
    pieces = ["king", "queen", "rook", "bishop", "knight", "pawn"]
    colors = ["white", "black"]
    
    # Create directories
    for color in colors:
        (base_path / set_name / color).mkdir(parents=True, exist_ok=True)
    
    downloaded = 0
    sizes_to_try = ["150", "88", "128", "200"]
    
    for color in colors:
        for piece in pieces:
            dest = base_path / set_name / color / f"{piece}.png"
            
            if dest.exists():
                downloaded += 1
                continue
            
            # Try different sizes
            success = False
            for size in sizes_to_try:
                url = get_chesscom_url(config["theme"], piece, color, size)
                if download_file(url, dest):
                    downloaded += 1
                    success = True
                    break
            
            if not success:
                # Try alternative naming or different sources
                pass
    
    return downloaded >= 10


def main():
    script_dir = Path(__file__).parent
    assets_path = script_dir / "images" / "figures"
    
    # Get existing sets (excluding variations)
    existing = []
    for item in assets_path.iterdir():
        if item.is_dir() and item.name not in ["black", "white"] and "_var" not in item.name:
            white_count = len(list((item / "white").glob("*.png")))
            black_count = len(list((item / "black").glob("*.png")))
            if white_count == 6 and black_count == 6:
                existing.append(item.name)
    
    print("=" * 60)
    print("Downloading Unique Chess Piece Sets")
    print("=" * 60)
    print(f"Existing unique sets: {len(existing)}")
    print(f"Target: 25 unique sets")
    print(f"Need: {max(0, 25 - len(existing))} more")
    print()
    
    successful = []
    failed = []
    
    # Try to download new sets
    for set_name, config in UNIQUE_CHESS_SETS.items():
        if len(existing) + len(successful) >= 25:
            break
        
        # Skip if already exists
        if set_name in existing:
            continue
        
        print(f"Trying: {set_name} ({config['desc']})...", end=" ")
        
        try:
            if download_set(set_name, config, assets_path):
                successful.append(set_name)
                print("[OK]")
            else:
                failed.append(set_name)
                print("[FAIL]")
        except Exception as e:
            failed.append(set_name)
            print(f"[ERROR: {e}]")
        
        time.sleep(0.3)
    
    total_unique = len(existing) + len(successful)
    print()
    print("=" * 60)
    print("Summary")
    print("=" * 60)
    print(f"Previously existing: {len(existing)}")
    print(f"Newly downloaded: {len(successful)}")
    print(f"Total unique sets: {total_unique}")
    print(f"Target: 25 sets")
    
    if total_unique >= 25:
        print("\n[SUCCESS] Reached target of 25 unique sets!")
    else:
        print(f"\n[INFO] Have {total_unique} unique sets, need {25 - total_unique} more")
    
    if successful:
        print("\nNewly downloaded sets:")
        for s in successful:
            print(f"  - {s}")


if __name__ == "__main__":
    main()

