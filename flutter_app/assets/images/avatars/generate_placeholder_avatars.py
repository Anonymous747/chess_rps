"""
Script to generate 20 placeholder avatar images.
This creates simple colored circle avatars with numbers as placeholders.
You can replace these with actual avatar designs later.
"""
from PIL import Image, ImageDraw, ImageFont
import os

# Create avatars directory if it doesn't exist
os.makedirs(os.path.dirname(__file__), exist_ok=True)

# Avatar colors (different colors for variety)
colors = [
    (139, 69, 19),   # Brown
    (75, 0, 130),    # Indigo
    (0, 128, 0),     # Green
    (255, 20, 147),  # Deep Pink
    (0, 191, 255),   # Deep Sky Blue
    (255, 140, 0),   # Dark Orange
    (148, 0, 211),   # Dark Violet
    (255, 215, 0),   # Gold
    (0, 206, 209),   # Dark Turquoise
    (255, 69, 0),    # Red Orange
    (138, 43, 226),  # Blue Violet
    (50, 205, 50),   # Lime Green
    (255, 105, 180), # Hot Pink
    (30, 144, 255),  # Dodger Blue
    (255, 165, 0),   # Orange
    (186, 85, 211),  # Medium Orchid
    (60, 179, 113),  # Medium Sea Green
    (255, 99, 71),   # Tomato
    (72, 61, 139),   # Dark Slate Blue
    (255, 192, 203), # Pink
]

# Generate 20 avatars
for i in range(1, 21):
    # Create a 256x256 image
    img = Image.new('RGB', (256, 256), color='white')
    draw = ImageDraw.Draw(img)
    
    # Get color for this avatar
    color = colors[(i - 1) % len(colors)]
    
    # Draw circle background
    margin = 20
    draw.ellipse(
        [margin, margin, 256 - margin, 256 - margin],
        fill=color,
        outline=(255, 255, 255),
        width=4
    )
    
    # Try to add number text (fallback if font not available)
    try:
        # Try to use a nice font
        font_size = 80
        font = ImageFont.truetype("arial.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
        except:
            font = ImageFont.load_default()
    
    # Draw number
    text = str(i)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((256 - text_width) // 2, (256 - text_height) // 2 - text_height // 4)
    draw.text(position, text, fill=(255, 255, 255), font=font)
    
    # Save image
    filename = f'avatar_{i}.png'
    filepath = os.path.join(os.path.dirname(__file__), filename)
    img.save(filepath, 'PNG')
    print(f'Generated {filename}')

print('\nAll 20 placeholder avatars generated!')
print('You can replace these with actual avatar designs later.')
