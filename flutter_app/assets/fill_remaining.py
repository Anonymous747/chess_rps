"""Fill remaining empty sets with working themes"""

from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))

from fill_empty_sets import fill_empty_set

assets_path = Path(__file__).parent / "images" / "figures"

failed_sets = [
     'cardinal', 'cardinal_pieces', 'horsey_pieces',
     'kosal', 'riohacha', 'riohacha_pieces', 'royal'
]

working_themes = ['neo', 'marble', 'alpha', 'wood', 'tournament', 'condal', 
                  'classic', 'modern', 'vintage', 'glass', 'metal']

print(f"Filling {len(failed_sets)} remaining empty sets...")
print()

successful = []
theme_idx = 0

for set_name in failed_sets:
    theme = working_themes[theme_idx % len(working_themes)]
    theme_idx += 1
    
    print(f"Filling {set_name} with {theme} theme...", end=" ")
    
    try:
        if fill_empty_set(set_name, theme, assets_path):
            successful.append(set_name)
            print("[OK]")
        else:
            print("[FAIL]")
    except Exception as e:
        print(f"[ERROR: {e}]")

print()
print(f"Successfully filled: {len(successful)}/{len(failed_sets)} sets")

