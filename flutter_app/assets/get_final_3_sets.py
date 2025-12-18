"""
Get the final 3 unique chess piece sets to reach 25 total.
Tries alternative sources and different size variants.
"""

import urllib.request
import urllib.error
from pathlib import Path
import time

# Alternative piece themes and sizes to try
ALTERNATIVE_SETS = [
    {"name": "neo_128", "theme": "neo", "size": "128", "desc": "Neo style 128px"},
    {"name": "marble_200", "theme": "marble", "size": "200", "desc": "Marble style 200px"},
    {"name": "alpha_88", "theme": "alpha", "size": "88", "desc": "Alpha style 88px"},
    {"name": "wood_128", "theme": "wood", "size": "128", "desc": "Wood style 128px"},
    {"name": "tournament_88", "theme": "tournament", "size": "88", "desc": "Tournament style 88px"},
    {"name": "condal_128", "theme": "condal", "size": "128", "desc": "Condal style 128px"},
    {"name": "modern_88", "theme": "modern", "size": "88", "desc": "Modern style 88px"},
    {"name": "classic_200", "theme": "classic", "size": "200", "desc": "Classic style 200px"},
    {"name": "vintage_128", "theme": "vintage", "size": "128", "desc": "Vintage style 128px"},
    {"name": "glass_88", "theme": "glass", "size": "88", "desc": "Glass style 88px"},
    {"name": "metal_128", "theme": "metal", "size": "128", "desc": "Metal style 128px"},
    {"name": "tournament_200", "theme": "tournament", "size": "200", "desc": "Tournament style 200px"},
    {"name": "neo_200", "theme": "neo", "size": "200", "desc": "Neo style 200px"},
    {"name": "marble_128", "theme": "marble", "size": "128", "desc": "Marble style 128px"},
    {"name": "alpha_200", "theme": "alpha", "size": "200", "desc": "Alpha style 200px"},
]


def get_chesscom_url(theme, piece, color, size="150"):
    """Generate Chess.com piece URL"""
    color_prefix = "w" if color == "white" else "b"
    piece_code = {
        "king": "k", "queen": "q", "rook": "r",
        "bishop": "b", "knight": "n", "pawn": "p"
    }[piece]
    return f"https://images.chesscomfiles.com/chess-themes/pieces/{theme}/{size}/{color_prefix}{piece_code}.png"


def download_file(url, destination, max_size_mb=10):
    """Download a file"""
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
    except:
        return False


def download_set(set_name, config, base_path):
    """Download a complete chess piece set"""
    pieces = ["king", "queen", "rook", "bishop", "knight", "pawn"]
    colors = ["white", "black"]
    
    # Check if already exists
    if (base_path / set_name).exists():
        white_count = len(list((base_path / set_name / "white").glob("*.png")))
        black_count = len(list((base_path / set_name / "black").glob("*.png")))
        if white_count == 6 and black_count == 6:
            return True
    
    # Create directories
    for color in colors:
        (base_path / set_name / color).mkdir(parents=True, exist_ok=True)
    
    downloaded = 0
    size = config.get("size", "150")
    
    for color in colors:
        for piece in pieces:
            dest = base_path / set_name / color / f"{piece}.png"
            
            if dest.exists():
                downloaded += 1
                continue
            
            url = get_chesscom_url(config["theme"], piece, color, size)
            if download_file(url, dest):
                downloaded += 1
    
    return downloaded >= 10


def main():
    script_dir = Path(__file__).parent
    assets_path = script_dir / "images" / "figures"
    
    # Get existing sets
    existing = []
    for item in assets_path.iterdir():
        if item.is_dir() and item.name not in ["black", "white"] and "_var" not in item.name:
            white_count = len(list((item / "white").glob("*.png")))
            black_count = len(list((item / "black").glob("*.png")))
            if white_count == 6 and black_count == 6:
                existing.append(item.name)
    
    print(f"Existing unique sets: {len(existing)}")
    print(f"Need: {max(0, 25 - len(existing))} more")
    print()
    
    needed = max(0, 25 - len(existing))
    if needed == 0:
        print("Already have 25+ unique sets!")
        return
    
    successful = []
    
    for config in ALTERNATIVE_SETS:
        if len(existing) + len(successful) >= 25:
            break
        
        set_name = config["name"]
        
        # Skip if already exists
        if set_name in existing:
            continue
        
        print(f"Trying: {set_name} ({config['desc']})...", end=" ")
        
        try:
            if download_set(set_name, config, assets_path):
                successful.append(set_name)
                print("[OK]")
                if len(existing) + len(successful) >= 25:
                    break
            else:
                print("[FAIL]")
        except Exception as e:
            print(f"[ERROR]")
        
        time.sleep(0.3)
    
    total = len(existing) + len(successful)
    print()
    print(f"Total unique sets: {total}")
    if total >= 25:
        print("[SUCCESS] Reached 25 unique sets!")
    else:
        print(f"[INFO] Need {25 - total} more sets")


if __name__ == "__main__":
    main()

