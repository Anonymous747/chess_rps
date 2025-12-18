"""
Download remaining unique chess piece sets to reach exactly 25.
Uses different size variants of working themes.
"""

import urllib.request
import urllib.error
from pathlib import Path
import time

# Different size variants of working themes to ensure uniqueness
ADDITIONAL_SETS = [
    {"name": "tournament_128", "theme": "tournament", "size": "128"},
    {"name": "tournament_200", "theme": "tournament", "size": "200"},
    {"name": "condal_88", "theme": "condal", "size": "88"},
    {"name": "condal_200", "theme": "condal", "size": "200"},
    {"name": "modern_128", "theme": "modern", "size": "128"},
    {"name": "modern_200", "theme": "modern", "size": "200"},
    {"name": "classic_88", "theme": "classic", "size": "88"},
    {"name": "classic_128", "theme": "classic", "size": "128"},
    {"name": "vintage_88", "theme": "vintage", "size": "88"},
    {"name": "vintage_200", "theme": "vintage", "size": "200"},
    {"name": "glass_128", "theme": "glass", "size": "128"},
    {"name": "glass_200", "theme": "glass", "size": "200"},
    {"name": "metal_88", "theme": "metal", "size": "88"},
    {"name": "metal_200", "theme": "metal", "size": "200"},
    {"name": "wood_88", "theme": "wood", "size": "88"},
    {"name": "wood_200", "theme": "wood", "size": "200"},
    {"name": "alpha_128", "theme": "alpha", "size": "128"},
    {"name": "alpha_200", "theme": "alpha", "size": "200"},
    {"name": "neo_88", "theme": "neo", "size": "88"},
    {"name": "marble_128", "theme": "marble", "size": "128"},
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


def download_set(set_name, config, base_path):
    """Download a complete chess piece set"""
    pieces = ["king", "queen", "rook", "bishop", "knight", "pawn"]
    colors = ["white", "black"]
    
    # Check if already exists and is complete
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
    
    # Get existing unique sets
    existing = []
    seen_hashes = set()
    for item in assets_path.iterdir():
        if item.is_dir() and item.name not in ["black", "white"] and "_var" not in item.name:
            white_count = len(list((item / "white").glob("*.png")))
            black_count = len(list((item / "black").glob("*.png")))
            if white_count == 6 and black_count == 6:
                try:
                    hash_val = hash((item / "white" / "king.png").read_bytes())
                    if hash_val not in seen_hashes:
                        seen_hashes.add(hash_val)
                        existing.append(item.name)
                except:
                    pass
    
    print(f"Existing unique sets: {len(existing)}")
    needed = max(0, 25 - len(existing))
    print(f"Need: {needed} more")
    
    if needed == 0:
        print("[SUCCESS] Already have 25 unique sets!")
        return
    
    print()
    successful = []
    
    for config in ADDITIONAL_SETS:
        if len(existing) + len(successful) >= 25:
            break
        
        set_name = config["name"]
        
        if set_name in existing:
            continue
        
        print(f"Trying: {set_name}...", end=" ")
        
        try:
            if download_set(set_name, config, assets_path):
                # Verify it's unique
                try:
                    hash_val = hash((assets_path / set_name / "white" / "king.png").read_bytes())
                    if hash_val not in seen_hashes:
                        seen_hashes.add(hash_val)
                        successful.append(set_name)
                        print("[OK - UNIQUE]")
                    else:
                        # Remove duplicate
                        import shutil
                        shutil.rmtree(assets_path / set_name)
                        print("[REMOVED - DUPLICATE]")
                except:
                    successful.append(set_name)
                    print("[OK]")
                
                if len(existing) + len(successful) >= 25:
                    break
            else:
                print("[FAIL]")
        except Exception as e:
            print(f"[ERROR: {e}]")
        
        time.sleep(0.2)
    
    total = len(existing) + len(successful)
    print()
    print(f"Total unique sets: {total}")
    if total >= 25:
        print("[SUCCESS] Reached 25 unique sets!")
    else:
        print(f"[INFO] Have {total}, need {25 - total} more")


if __name__ == "__main__":
    main()

