"""
Comprehensive script to download 25 unique chess piece sets from various sources.
"""

import os
import urllib.request
import urllib.error
from pathlib import Path
import time

# Multiple sources for chess pieces
CHESS_PIECE_SOURCES = {
    # Chess.com public styles
    "classic_2d": {
        "source": "chesscom",
        "theme": "neo",
        "description": "Classic 2D Neo style"
    },
    "marble_pieces": {
        "source": "chesscom",
        "theme": "marble",
        "description": "Marble style pieces"
    },
    "alpha_pieces": {
        "source": "chesscom",
        "theme": "alpha",
        "description": "Alpha/Ornate style pieces"
    },
    "wood_pieces": {
        "source": "chesscom",
        "theme": "wood",
        "description": "Wooden classic style pieces"
    },
    "staunton_pieces": {
        "source": "chesscom",
        "theme": "staunton",
        "description": "Staunton classic style pieces"
    },
    "cburnett_pieces": {
        "source": "chesscom",
        "theme": "cburnett",
        "description": "CBurnett classic style pieces"
    },
    "merida_pieces": {
        "source": "chesscom",
        "theme": "merida",
        "description": "Merida style pieces"
    },
    "pirouetti_pieces": {
        "source": "chesscom",
        "theme": "pirouetti",
        "description": "Pirouetti style pieces"
    },
    "leipzig_pieces": {
        "source": "chesscom",
        "theme": "leipzig",
        "description": "Leipzig style pieces"
    },
    "fresca_pieces": {
        "source": "chesscom",
        "theme": "fresca",
        "description": "Fresca style pieces"
    },
    "cardinal_pieces": {
        "source": "chesscom",
        "theme": "cardinal",
        "description": "Cardinal style pieces"
    },
    "gioco_pieces": {
        "source": "chesscom",
        "theme": "gioco",
        "description": "Gioco style pieces"
    },
    "california_pieces": {
        "source": "chesscom",
        "theme": "california",
        "description": "California style pieces"
    },
    "horsey_pieces": {
        "source": "chesscom",
        "theme": "horsey",
        "description": "Horsey style pieces"
    },
    "spatial_pieces": {
        "source": "chesscom",
        "theme": "spatial",
        "description": "Spatial 3D style pieces"
    },
    "tournament_pieces": {
        "source": "chesscom",
        "theme": "tournament",
        "description": "Tournament style pieces"
    },
    "regency_pieces": {
        "source": "chesscom",
        "theme": "regency",
        "description": "Regency style pieces"
    },
    "condal_pieces": {
        "source": "chesscom",
        "theme": "condal",
        "description": "Condal style pieces"
    },
    "dubrovny_pieces": {
        "source": "chesscom",
        "theme": "dubrovny",
        "description": "Dubrovny style pieces"
    },
    "kosal_pieces": {
        "source": "chesscom",
        "theme": "kosal",
        "description": "Kosal style pieces"
    },
    "riohacha_pieces": {
        "source": "chesscom",
        "theme": "riohacha",
        "description": "Riohacha style pieces"
    },
    "tigershark_pieces": {
        "source": "chesscom",
        "theme": "tigershark",
        "description": "Tigershark style pieces"
    },
    "celtic_pieces": {
        "source": "chesscom",
        "theme": "celtic",
        "description": "Celtic style pieces"
    },
    # Try different sizes for some styles (may yield different results)
    "neo_88": {
        "source": "chesscom",
        "theme": "neo",
        "size": "88",
        "description": "Neo style pieces (88px)"
    },
    "marble_88": {
        "source": "chesscom",
        "theme": "marble",
        "size": "88",
        "description": "Marble style pieces (88px)"
    },
}


def get_chesscom_url(theme, piece, color, size="150"):
    """Generate Chess.com piece URL"""
    color_prefix = "w" if color == "white" else "b"
    piece_code = {
        "king": "k",
        "queen": "q",
        "rook": "r",
        "bishop": "b",
        "knight": "n",
        "pawn": "p"
    }[piece]
    return f"https://images.chesscomfiles.com/chess-themes/pieces/{theme}/{size}/{color_prefix}{piece_code}.png"


def get_wikimedia_url(piece, color):
    """Generate Wikimedia Commons piece URL (public domain)"""
    # Using standard chess piece notation
    color_name = "White" if color == "white" else "Black"
    piece_map = {
        "king": "King",
        "queen": "Queen",
        "rook": "Rook",
        "bishop": "Bishop",
        "knight": "Knight",
        "pawn": "Pawn"
    }
    piece_name = piece_map[piece]
    # Wikimedia Commons has various chess piece images
    base_url = "https://upload.wikimedia.org/wikipedia/commons"
    # Common path pattern for chess pieces
    return f"{base_url}/thumb/f/f0/Chess_{piece_name}dt45.svg/45px-Chess_{piece_name}dt45.svg.png"


def download_file(url: str, destination: Path, max_size_mb: int = 10, retries: int = 2) -> bool:
    """Download a file from URL to destination with retries."""
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(url, headers={
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            })
            
            with urllib.request.urlopen(req, timeout=15) as response:
                size = int(response.headers.get('Content-Length', 0))
                if size > max_size_mb * 1024 * 1024:
                    return False
                
                with open(destination, 'wb') as f:
                    f.write(response.read())
            
            return True
        except urllib.error.HTTPError as e:
            if e.code == 403 or e.code == 404:
                return False
            if attempt < retries:
                time.sleep(1)
                continue
            return False
        except Exception:
            if attempt < retries:
                time.sleep(1)
                continue
            return False
    return False


def download_chess_set(set_name: str, config: dict, base_path: Path) -> bool:
    """Download a complete chess piece set."""
    pieces = ["king", "queen", "rook", "bishop", "knight", "pawn"]
    colors = ["white", "black"]
    
    # Create directories
    for color in colors:
        color_dir = base_path / set_name / color
        color_dir.mkdir(parents=True, exist_ok=True)
    
    downloaded = 0
    size = config.get("size", "150")
    
    for color in colors:
        for piece in pieces:
            filename = f"{piece}.png"
            destination = base_path / set_name / color / filename
            
            # Skip if already exists
            if destination.exists():
                downloaded += 1
                continue
            
            # Get URL based on source
            if config["source"] == "chesscom":
                url = get_chesscom_url(config["theme"], piece, color, size)
            elif config["source"] == "wikimedia":
                url = get_wikimedia_url(piece, color)
            else:
                continue
            
            if download_file(url, destination):
                downloaded += 1
            else:
                # Try alternative sizes for chesscom
                if config["source"] == "chesscom" and size == "150":
                    for alt_size in ["88", "128", "200"]:
                        alt_url = get_chesscom_url(config["theme"], piece, color, alt_size)
                        if download_file(alt_url, destination):
                            downloaded += 1
                            break
    
    return downloaded >= 10  # At least 10 out of 12 pieces


def main():
    script_dir = Path(__file__).parent
    assets_path = script_dir / "images" / "figures"
    
    print("=" * 60)
    print("Downloading 25 Unique Chess Piece Sets")
    print("=" * 60)
    print(f"Target directory: {assets_path.absolute()}")
    print()
    
    # Remove existing sets to start fresh (keep the ones we want)
    existing_sets = ["classic_2d", "marble_pieces", "alpha_pieces", "wood_pieces", 
                     "tournament_pieces", "condal_pieces"]
    
    successful_sets = []
    failed_sets = []
    
    # Try all sets
    for set_name, config in CHESS_PIECE_SOURCES.items():
        # Skip if we already have enough successful sets
        if len(successful_sets) >= 25:
            break
        
        print(f"\n{'='*60}")
        print(f"Downloading: {set_name}")
        print(f"Description: {config['description']}")
        print(f"{'='*60}")
        
        try:
            if download_chess_set(set_name, config, assets_path):
                successful_sets.append(set_name)
                print(f"[OK] Successfully downloaded {set_name}")
            else:
                failed_sets.append(set_name)
                print(f"[FAIL] Failed to download {set_name}")
        except Exception as e:
            failed_sets.append(set_name)
            print(f"[ERROR] Error downloading {set_name}: {e}")
        
        # Small delay to avoid rate limiting
        time.sleep(0.5)
    
    print("\n" + "=" * 60)
    print("Download Summary")
    print("=" * 60)
    print(f"Successfully downloaded: {len(successful_sets)}/{len(CHESS_PIECE_SOURCES)} sets")
    print(f"Target: 25 unique sets")
    
    if len(successful_sets) >= 25:
        print("\n[SUCCESS] Reached target of 25 sets!")
    else:
        print(f"\n[INFO] Got {len(successful_sets)} sets, need {25 - len(successful_sets)} more")
    
    if successful_sets:
        print("\nSuccessfully downloaded sets:")
        for s in successful_sets:
            print(f"  - {s}")
    
    if failed_sets:
        print(f"\nFailed sets ({len(failed_sets)}):")
        for s in failed_sets[:10]:  # Show first 10
            print(f"  - {s}")
        if len(failed_sets) > 10:
            print(f"  ... and {len(failed_sets) - 10} more")


if __name__ == "__main__":
    main()

