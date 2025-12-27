"""
Script to download 20 abstract avatar images using DiceBear API.
Uses abstract/geometric styles that match the app's modern dark theme.
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

# Abstract avatar styles and seeds
# Using different DiceBear styles for variety: identicon (geometric), bottts (robot/abstract), avataaars (abstract faces)
ABSTRACT_AVATARS = [
    # Identicon style - geometric patterns (1-8)
    {"style": "identicon", "seed": "happy-king", "bg": "0a0e27"},
    {"style": "identicon", "seed": "cool-dude", "bg": "141b2d"},
    {"style": "identicon", "seed": "surprised-player", "bg": "1e2742"},
    {"style": "identicon", "seed": "laughing-master", "bg": "252f4a"},
    {"style": "identicon", "seed": "cool-strategist", "bg": "0a0e27"},
    {"style": "identicon", "seed": "happy-cat", "bg": "141b2d"},
    {"style": "identicon", "seed": "excited-dog", "bg": "1e2742"},
    {"style": "identicon", "seed": "friendly-bear", "bg": "252f4a"},
    
    # Bottts style - abstract robot/geometric (9-14)
    {"style": "bottts", "seed": "cute-rabbit", "bg": "0a0e27"},
    {"style": "bottts", "seed": "sleepy-panda", "bg": "141b2d"},
    {"style": "bottts", "seed": "party-person", "bg": "1e2742"},
    {"style": "bottts", "seed": "wise-owl", "bg": "252f4a"},
    {"style": "bottts", "seed": "mischievous-monkey", "bg": "0a0e27"},
    {"style": "bottts", "seed": "chess-nerd", "bg": "141b2d"},
    
    # Avataaars style - abstract faces (15-20)
    {"style": "avataaars", "seed": "cunning-fox", "bg": "1e2742"},
    {"style": "avataaars", "seed": "epic-champion", "bg": "252f4a"},
    {"style": "avataaars", "seed": "friendly-dragon", "bg": "0a0e27"},
    {"style": "avataaars", "seed": "mystical-wizard", "bg": "141b2d"},
    {"style": "avataaars", "seed": "magical-unicorn", "bg": "1e2742"},
    {"style": "avataaars", "seed": "legendary-master", "bg": "252f4a"},
]

def download_abstract_avatar(style: str, seed: str, bg_color: str, output_path: Path, index: int):
    """Download an abstract avatar from DiceBear API and save as PNG."""
    try:
        # Use PNG endpoint directly
        url = f"https://api.dicebear.com/7.x/{style}/png?seed={seed}&backgroundColor={bg_color}&size={SIZE}"
        
        print(f"Downloading abstract avatar {index}: {style}/{seed}...")
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
    """Download all abstract avatars."""
    print("=" * 60)
    print("Downloading 20 Abstract Avatars for Chess RPS")
    print("Using DiceBear API - Abstract/Geometric Styles")
    print("=" * 60)
    print(f"Output directory: {AVATAR_DIR.absolute()}")
    print()
    
    # Ensure directory exists
    AVATAR_DIR.mkdir(parents=True, exist_ok=True)
    
    success_count = 0
    for idx, avatar_config in enumerate(ABSTRACT_AVATARS, start=1):
        output_path = AVATAR_DIR / f"avatar_{idx}.png"
        if download_abstract_avatar(
            avatar_config["style"],
            avatar_config["seed"],
            avatar_config["bg"],
            output_path,
            idx
        ):
            success_count += 1
    
    print()
    print("=" * 60)
    print(f"Download complete: {success_count}/{len(ABSTRACT_AVATARS)} avatars")
    print("=" * 60)
    
    if success_count == len(ABSTRACT_AVATARS):
        print("\nAll abstract avatars downloaded successfully!")
        print("The avatars are now ready to use in the app.")
        print("\nStyles used:")
        print("  - Identicon: Geometric patterns (8 avatars)")
        print("  - Bottts: Abstract robot/geometric (6 avatars)")
        print("  - Avataaars: Abstract faces (6 avatars)")
    else:
        print(f"\nWarning: {len(ABSTRACT_AVATARS) - success_count} avatars failed to download.")
        print("Please check your internet connection and try again.")

if __name__ == "__main__":
    main()
