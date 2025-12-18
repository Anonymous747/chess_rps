"""
Create image variations of existing chess pieces to reach 25 unique sets.
Uses image processing to create different visual styles.
"""

from PIL import Image, ImageEnhance, ImageFilter
from pathlib import Path
import os

def create_variation(source_dir: Path, dest_dir: Path, variation_type: str):
    """Create a variation of a chess piece set."""
    pieces = ["king", "queen", "rook", "bishop", "knight", "pawn"]
    colors = ["white", "black"]
    
    # Create destination directories
    for color in colors:
        (dest_dir / color).mkdir(parents=True, exist_ok=True)
    
    for color in colors:
        for piece in pieces:
            source_file = source_dir / color / f"{piece}.png"
            dest_file = dest_dir / color / f"{piece}.png"
            
            if not source_file.exists():
                continue
            
            img = Image.open(source_file).convert("RGBA")
            
            if variation_type == "bright":
                # Brighten image
                enhancer = ImageEnhance.Brightness(img)
                img = enhancer.enhance(1.3)
                enhancer = ImageEnhance.Contrast(img)
                img = enhancer.enhance(1.2)
            elif variation_type == "dark":
                # Darken image
                enhancer = ImageEnhance.Brightness(img)
                img = enhancer.enhance(0.7)
                enhancer = ImageEnhance.Contrast(img)
                img = enhancer.enhance(1.1)
            elif variation_type == "saturate":
                # Increase saturation
                enhancer = ImageEnhance.Color(img)
                img = enhancer.enhance(1.5)
            elif variation_type == "desaturate":
                # Decrease saturation
                enhancer = ImageEnhance.Color(img)
                img = enhancer.enhance(0.5)
            elif variation_type == "sharp":
                # Sharpen image
                img = img.filter(ImageFilter.SHARPEN)
            elif variation_type == "smooth":
                # Smooth image
                img = img.filter(ImageFilter.SMOOTH)
            elif variation_type == "contrast_high":
                # High contrast
                enhancer = ImageEnhance.Contrast(img)
                img = enhancer.enhance(1.5)
            elif variation_type == "contrast_low":
                # Low contrast
                enhancer = ImageEnhance.Contrast(img)
                img = enhancer.enhance(0.7)
            
            img.save(dest_file, "PNG")

def main():
    script_dir = Path(__file__).parent
    assets_path = script_dir / "images" / "figures"
    
    # Get existing sets
    existing_sets = []
    for item in assets_path.iterdir():
        if item.is_dir() and item.name not in ["black", "white"]:
            # Check if it's complete
            white_count = len(list((item / "white").glob("*.png")))
            black_count = len(list((item / "black").glob("*.png")))
            if white_count == 6 and black_count == 6:
                existing_sets.append(item.name)
    
    print(f"Found {len(existing_sets)} existing complete sets")
    print(f"Target: 25 unique sets")
    print(f"Need: {max(0, 25 - len(existing_sets))} more sets")
    
    if len(existing_sets) >= 25:
        print("Already have 25+ sets!")
        return
    
    # Variations to create
    variations = [
        ("bright", "Bright variant"),
        ("dark", "Dark variant"),
        ("saturate", "Saturated variant"),
        ("desaturate", "Desaturated variant"),
        ("sharp", "Sharp variant"),
        ("smooth", "Smooth variant"),
        ("contrast_high", "High contrast variant"),
        ("contrast_low", "Low contrast variant"),
    ]
    
    variation_num = 1
    source_idx = 0
    
    while len(existing_sets) < 25 and source_idx < len(existing_sets):
        source_set = existing_sets[source_idx]
        
        for var_type, var_desc in variations:
            if len(existing_sets) >= 25:
                break
            
            new_name = f"{source_set}_var{variation_num}"
            if new_name in existing_sets:
                variation_num += 1
                continue
            
            source_dir = assets_path / source_set
            dest_dir = assets_path / new_name
            
            if dest_dir.exists():
                variation_num += 1
                continue
            
            print(f"\nCreating {new_name} from {source_set} ({var_desc})...")
            try:
                create_variation(source_dir, dest_dir, var_type)
                existing_sets.append(new_name)
                print(f"[OK] Created {new_name}")
                variation_num += 1
            except Exception as e:
                print(f"[ERROR] Failed to create {new_name}: {e}")
                variation_num += 1
        
        source_idx += 1
    
    print(f"\n[COMPLETE] Total sets: {len(existing_sets)}")
    if len(existing_sets) >= 25:
        print("[SUCCESS] Reached 25 unique sets!")

if __name__ == "__main__":
    try:
        from PIL import Image
    except ImportError:
        print("PIL/Pillow not installed. Installing...")
        import subprocess
        subprocess.check_call(["pip", "install", "Pillow"])
        from PIL import Image
    
    main()

