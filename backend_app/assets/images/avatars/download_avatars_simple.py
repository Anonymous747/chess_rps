"""
Simpler script to download 20 modern avatar images using DiceBear API.
This version doesn't require cairosvg - uses PNG endpoint directly.
Uses urllib (built-in) instead of requests.
"""
import os
import urllib.request
import urllib.error
from pathlib import Path
from PIL import Image
import io

# Output directory
AVATAR_DIR = Path(__file__).parent
SIZE = 256  # Target size for avatars

# Avatar seeds matching the original names
AVATAR_SEEDS = [
    "happy-king",
    "cool-dude", 
    "surprised-player",
    "laughing-master",
    "cool-strategist",
    "happy-cat",
    "excited-dog",
    "friendly-bear",
    "cute-rabbit",
    "sleepy-panda",
    "party-person",
    "wise-owl",
    "mischievous-monkey",
    "chess-nerd",
    "cunning-fox",
    "epic-champion",
    "friendly-dragon",
    "mystical-wizard",
    "magical-unicorn",
    "legendary-master",
]

# Background colors matching app palette (hex without #)
BACKGROUND_COLORS = [
    "0a0e27",  # Deep dark blue-black
    "141b2d",  # Slightly lighter dark
    "1e2742",  # Card backgrounds
    "252f4a",  # Elevated cards
] * 5  # Repeat to get 20

def download_avatar(seed: str, bg_color: str, output_path: Path, index: int):
    """Download an avatar from DiceBear API and save as PNG."""
    try:
        # Use PNG endpoint directly (no SVG conversion needed)
        url = f"https://api.dicebear.com/7.x/personas/png?seed={seed}&backgroundColor={bg_color}&size={SIZE}"
        
        print(f"Downloading avatar {index}: {seed}...")
        try:
            with urllib.request.urlopen(url, timeout=30) as response:
                image_data = response.read()
        except urllib.error.URLError as e:
            raise Exception(f"Failed to download: {e}")
        
        # Open and verify image
        img = Image.open(io.BytesIO(image_data))
        
        # Ensure it's RGB (some PNGs might be RGBA)
        if img.mode == 'RGBA':
            # Create background with app's dark color
            background = Image.new('RGB', (SIZE, SIZE), tuple(int(bg_color[i:i+2], 16) for i in (0, 2, 4)))
            background.paste(img, mask=img.split()[3])  # Use alpha channel
            img = background
        elif img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Resize if needed (should already be correct size)
        if img.size != (SIZE, SIZE):
            img = img.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
        
        # Save as PNG
        img.save(output_path, 'PNG', optimize=True)
        print(f"  Saved: {output_path.name}")
        return True
    except Exception as e:
        print(f"  Error downloading avatar {index}: {e}")
        return False

def main():
    """Download all avatars."""
    print("=" * 60)
    print("Downloading 20 Modern Avatars for Chess RPS")
    print("Using DiceBear API - Modern Personas Style")
    print("=" * 60)
    print(f"Output directory: {AVATAR_DIR.absolute()}")
    print()
    
    # Ensure directory exists
    AVATAR_DIR.mkdir(parents=True, exist_ok=True)
    
    success_count = 0
    for idx, (seed, bg_color) in enumerate(zip(AVATAR_SEEDS, BACKGROUND_COLORS), start=1):
        output_path = AVATAR_DIR / f"avatar_{idx}.png"
        if download_avatar(seed, bg_color, output_path, idx):
            success_count += 1
    
    print()
    print("=" * 60)
    print(f"Download complete: {success_count}/{len(AVATAR_SEEDS)} avatars")
    print("=" * 60)
    
    if success_count == len(AVATAR_SEEDS):
        print("\nAll avatars downloaded successfully!")
        print("The avatars are now ready to use in the app.")
    else:
        print(f"\nWarning: {len(AVATAR_SEEDS) - success_count} avatars failed to download.")
        print("Please check your internet connection and try again.")

if __name__ == "__main__":
    main()
