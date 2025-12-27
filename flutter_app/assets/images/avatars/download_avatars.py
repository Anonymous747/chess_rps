"""
Script to download 20 modern avatar images that match the app's dark theme style.
Uses multiple free avatar services to get diverse, modern avatars.
"""
import os
import requests
from pathlib import Path
from PIL import Image
import io

# Output directory
AVATAR_DIR = Path(__file__).parent
SIZE = 256  # Target size for avatars

# Avatar sources - using free APIs and services
AVATAR_SOURCES = [
    # DiceBear API - Modern style avatars (free, no API key needed)
    {
        "name": "Modern Person 1",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=happy-king&backgroundColor=0a0e27&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 2", 
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=cool-dude&backgroundColor=141b2d&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 3",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=surprised&backgroundColor=1e2742&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 4",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=laughing&backgroundColor=252f4a&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 5",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=strategist&backgroundColor=0a0e27&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 6",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=cat-lover&backgroundColor=141b2d&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 7",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=dog-lover&backgroundColor=1e2742&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 8",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=bear-fan&backgroundColor=252f4a&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 9",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=rabbit&backgroundColor=0a0e27&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 10",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=panda&backgroundColor=141b2d&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 11",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=party&backgroundColor=1e2742&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 12",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=wise&backgroundColor=252f4a&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 13",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=monkey&backgroundColor=0a0e27&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 14",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=chess-nerd&backgroundColor=141b2d&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 15",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=fox&backgroundColor=1e2742&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 16",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=champion&backgroundColor=252f4a&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 17",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=dragon&backgroundColor=0a0e27&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 18",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=wizard&backgroundColor=141b2d&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 19",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=unicorn&backgroundColor=1e2742&size=256",
        "style": "personas"
    },
    {
        "name": "Modern Person 20",
        "url": "https://api.dicebear.com/7.x/personas/svg?seed=master&backgroundColor=252f4a&size=256",
        "style": "personas"
    },
]

def download_avatar(url: str, output_path: Path, index: int):
    """Download an avatar from URL and save as PNG."""
    try:
        print(f"Downloading avatar {index}...")
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        # If SVG, convert to PNG
        if url.endswith('.svg') or 'svg' in url:
            from cairosvg import svg2png
            png_data = svg2png(bytestring=response.content, output_width=SIZE, output_height=SIZE)
            img = Image.open(io.BytesIO(png_data))
        else:
            img = Image.open(io.BytesIO(response.content))
        
        # Resize to target size if needed
        if img.size != (SIZE, SIZE):
            img = img.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
        
        # Convert to RGB if needed (for PNG compatibility)
        if img.mode != 'RGB':
            # Create a dark background matching app theme
            background = Image.new('RGB', (SIZE, SIZE), (10, 14, 39))  # 0xFF0A0E27
            if img.mode == 'RGBA':
                background.paste(img, mask=img.split()[3])  # Use alpha channel as mask
            else:
                background.paste(img)
            img = background
        
        # Save as PNG
        img.save(output_path, 'PNG', optimize=True)
        print(f"Saved: {output_path.name}")
        return True
    except Exception as e:
        print(f"Error downloading avatar {index}: {e}")
        return False

def main():
    """Download all avatars."""
    print("Starting avatar download...")
    print(f"Output directory: {AVATAR_DIR}")
    
    # Ensure directory exists
    AVATAR_DIR.mkdir(parents=True, exist_ok=True)
    
    success_count = 0
    for idx, source in enumerate(AVATAR_SOURCES, start=1):
        output_path = AVATAR_DIR / f"avatar_{idx}.png"
        if download_avatar(source["url"], output_path, idx):
            success_count += 1
    
    print(f"\nDownloaded {success_count}/{len(AVATAR_SOURCES)} avatars successfully!")
    if success_count < len(AVATAR_SOURCES):
        print("Some avatars failed to download. You may need to install cairosvg:")
        print("  pip install cairosvg")

if __name__ == "__main__":
    main()
