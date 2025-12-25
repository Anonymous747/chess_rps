#!/usr/bin/env python3
"""
Generate chess icon for Chess RPS app
Creates icons in various sizes matching the app's design style
"""

from PIL import Image, ImageDraw, ImageFont
import math
import os

# App color palette
COLORS = {
    'background': (10, 14, 39),  # #0A0E27
    'background_secondary': (20, 27, 66),  # #141B2D
    'background_tertiary': (30, 39, 66),  # #1E2742
    'accent': (0, 212, 255),  # #00D4FF
    'purple_accent': (124, 58, 237),  # #7C3AED
    'purple_light': (159, 122, 234),  # #9F7AEA
    'glass_border': (255, 255, 255, 48),  # 30% white
}

def create_chess_icon(size):
    """Create a chess icon at the specified size"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    center = size / 2
    radius = size / 2 - size * 0.05
    
    # Draw background circle with gradient effect
    # Create a radial gradient by drawing multiple circles
    for i in range(20):
        alpha = int(255 * (1 - i / 20))
        r = radius * (1 - i / 20)
        color = (
            int(COLORS['background_tertiary'][0] * (1 - i / 20) + COLORS['background'][0] * (i / 20)),
            int(COLORS['background_tertiary'][1] * (1 - i / 20) + COLORS['background'][1] * (i / 20)),
            int(COLORS['background_tertiary'][2] * (1 - i / 20) + COLORS['background'][2] * (i / 20)),
            alpha
        )
        draw.ellipse(
            [center - r, center - r, center + r, center + r],
            fill=color
        )
    
    # Draw border with glassmorphism effect
    border_color = (*COLORS['glass_border'][:3], COLORS['glass_border'][3])
    draw.ellipse(
        [center - radius, center - radius, center + radius, center + radius],
        outline=border_color,
        width=int(size * 0.02)
    )
    
    # Draw chess board pattern (4x4 squares)
    square_size = radius * 0.6 / 4
    board_offset_x = center - square_size * 2
    board_offset_y = center - square_size * 2
    
    for row in range(4):
        for col in range(4):
            is_light = (row + col) % 2 == 0
            if is_light:
                color = (*COLORS['accent'], int(255 * 0.2))
            else:
                color = (*COLORS['purple_accent'], int(255 * 0.3))
            
            x1 = board_offset_x + col * square_size
            y1 = board_offset_y + row * square_size
            x2 = x1 + square_size
            y2 = y1 + square_size
            
            draw.rectangle([x1, y1, x2, y2], fill=color)
    
    # Draw chess pieces
    piece_size = square_size * 0.8
    
    # King
    king_center_x = board_offset_x + square_size * 0.5
    king_center_y = board_offset_y + square_size * 1.5
    draw_king(draw, king_center_x, king_center_y, piece_size)
    
    # Queen
    queen_center_x = board_offset_x + square_size * 2.5
    queen_center_y = board_offset_y + square_size * 1.5
    draw_queen(draw, queen_center_x, queen_center_y, piece_size)
    
    # Draw accent arcs
    arc_color = (*COLORS['accent'], int(255 * 0.6))
    arc_radius = radius - size * 0.05
    arc_width = int(size * 0.015)
    
    # Top arc
    bbox = [center - arc_radius, center - arc_radius, center + arc_radius, center + arc_radius]
    draw.arc(bbox, start=-54, end=54, fill=arc_color, width=arc_width)
    
    # Bottom arc
    draw.arc(bbox, start=126, end=234, fill=arc_color, width=arc_width)
    
    return img

def draw_king(draw, center_x, center_y, size):
    """Draw a king chess piece"""
    color = (*COLORS['accent'], int(255 * 0.9))
    
    # Base
    base_width = size * 0.4
    base_height = size * 0.2
    draw.rectangle(
        [center_x - base_width/2, center_y + size*0.2,
         center_x + base_width/2, center_y + size*0.4],
        fill=color
    )
    
    # Body
    body_width = size * 0.35
    body_height = size * 0.4
    draw.rectangle(
        [center_x - body_width/2, center_y - body_height/2,
         center_x + body_width/2, center_y + body_height/2],
        fill=color
    )
    
    # Cross vertical
    cross_v_width = size * 0.15
    cross_v_height = size * 0.25
    draw.rectangle(
        [center_x - cross_v_width/2, center_y - size*0.475,
         center_x + cross_v_width/2, center_y - size*0.225],
        fill=color
    )
    
    # Cross horizontal
    cross_h_width = size * 0.25
    cross_h_height = size * 0.1
    draw.rectangle(
        [center_x - cross_h_width/2, center_y - size*0.5,
         center_x + cross_h_width/2, center_y - size*0.4],
        fill=color
    )

def draw_queen(draw, center_x, center_y, size):
    """Draw a queen chess piece"""
    color = (*COLORS['purple_accent'], int(255 * 0.9))
    
    # Base
    base_width = size * 0.4
    base_height = size * 0.2
    draw.rectangle(
        [center_x - base_width/2, center_y + size*0.2,
         center_x + base_width/2, center_y + size*0.4],
        fill=color
    )
    
    # Body
    body_width = size * 0.35
    body_height = size * 0.4
    draw.rectangle(
        [center_x - body_width/2, center_y - body_height/2,
         center_x + body_width/2, center_y + body_height/2],
        fill=color
    )
    
    # Crown (3 points)
    crown_color = (*COLORS['purple_light'], int(255 * 0.9))
    for i in range(3):
        x = center_x + (i - 1) * size * 0.15
        y_top = center_y - size * 0.4
        y_bottom = center_y - size * 0.225
        width = size * 0.12
        
        # Draw triangle
        points = [
            (x, y_bottom),
            (x - width/2, y_top),
            (x + width/2, y_top),
        ]
        draw.polygon(points, fill=crown_color)

def main():
    """Generate icons in all required sizes"""
    # Create output directory
    output_dir = 'flutter_app/assets/images/icons'
    os.makedirs(output_dir, exist_ok=True)
    
    # Sizes needed for different platforms
    sizes = {
        # Android
        'android-mdpi': 48,
        'android-hdpi': 72,
        'android-xhdpi': 96,
        'android-xxhdpi': 144,
        'android-xxxhdpi': 192,
        
        # Web
        'web-192': 192,
        'web-512': 512,
        'web-maskable-192': 192,
        'web-maskable-512': 512,
        
        # iOS
        'ios-1024': 1024,
        
        # Favicon
        'favicon': 32,
    }
    
    print('Generating chess icons...')
    
    for name, size in sizes.items():
        icon = create_chess_icon(size)
        output_path = os.path.join(output_dir, f'{name}.png')
        icon.save(output_path, 'PNG')
        print(f'Generated: {output_path} ({size}x{size})')
    
    # Also generate for Android mipmap directories
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    
    for mipmap_name, size in android_sizes.items():
        icon = create_chess_icon(size)
        output_path = f'android/app/src/main/res/{mipmap_name}/ic_launcher.png'
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        icon.save(output_path, 'PNG')
        print(f'Generated: {output_path} ({size}x{size})')
    
    # Generate web icons
    web_sizes = {
        'Icon-192': 192,
        'Icon-512': 512,
        'Icon-maskable-192': 192,
        'Icon-maskable-512': 512,
    }
    
    web_dir = 'web/icons'
    os.makedirs(web_dir, exist_ok=True)
    
    for name, size in web_sizes.items():
        icon = create_chess_icon(size)
        output_path = os.path.join(web_dir, f'{name}.png')
        icon.save(output_path, 'PNG')
        print(f'Generated: {output_path} ({size}x{size})')
    
    # Generate favicon
    favicon = create_chess_icon(32)
    favicon.save('web/favicon.png', 'PNG')
    print(f'Generated: web/favicon.png (32x32)')
    
    # Generate iOS icons
    ios_sizes = {
        'Icon-App-20x20@1x': 20,
        'Icon-App-20x20@2x': 40,
        'Icon-App-20x20@3x': 60,
        'Icon-App-29x29@1x': 29,
        'Icon-App-29x29@2x': 58,
        'Icon-App-29x29@3x': 87,
        'Icon-App-40x40@1x': 40,
        'Icon-App-40x40@2x': 80,
        'Icon-App-40x40@3x': 120,
        'Icon-App-60x60@2x': 120,
        'Icon-App-60x60@3x': 180,
        'Icon-App-76x76@1x': 76,
        'Icon-App-76x76@2x': 152,
        'Icon-App-83.5x83.5@2x': 167,
        'Icon-App-1024x1024@1x': 1024,
    }
    
    ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(ios_dir, exist_ok=True)
    
    for name, size in ios_sizes.items():
        icon = create_chess_icon(size)
        output_path = os.path.join(ios_dir, f'{name}.png')
        icon.save(output_path, 'PNG')
        print(f'Generated: {output_path} ({size}x{size})')
    
    print('\nDone! All icons generated successfully.')
    print('\nIcons are ready for:')
    print('  - Android (all mipmap directories)')
    print('  - iOS (all AppIcon sizes)')
    print('  - Web (all PWA icon sizes)')
    print('  - Favicon')
    print('\nIcons match your app\'s dark theme with cyan/purple accents')

if __name__ == '__main__':
    main()

