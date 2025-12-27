#!/usr/bin/env python3
"""
Generate splash screen images for native platforms
Matches the Flutter AppLoadingScreen design
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
    'text_primary': (255, 255, 255),  # White
    'text_secondary': (180, 185, 199),  # #B4B9C7
}

def create_splash_screen(width, height):
    """Create a splash screen image matching the Flutter loading screen"""
    # Create image with gradient background
    img = Image.new('RGB', (width, height), COLORS['background'])
    draw = ImageDraw.Draw(img)
    
    # Draw gradient background
    for y in range(height):
        ratio = y / height
        r = int(COLORS['background'][0] * (1 - ratio) + COLORS['background_secondary'][0] * ratio)
        g = int(COLORS['background'][1] * (1 - ratio) + COLORS['background_secondary'][1] * ratio)
        b = int(COLORS['background'][2] * (1 - ratio) + COLORS['background_secondary'][2] * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    # Add tertiary color at bottom
    for y in range(int(height * 0.5), height):
        ratio = (y - height * 0.5) / (height * 0.5)
        r = int(COLORS['background_secondary'][0] * (1 - ratio) + COLORS['background_tertiary'][0] * ratio)
        g = int(COLORS['background_secondary'][1] * (1 - ratio) + COLORS['background_tertiary'][1] * ratio)
        b = int(COLORS['background_secondary'][2] * (1 - ratio) + COLORS['background_tertiary'][2] * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    center_x = width / 2
    center_y = height / 2
    
    # Draw chess icon (same as app icon but larger)
    icon_size = min(width, height) * 0.25
    icon_center_y = center_y - height * 0.15
    
    # Draw dark circle area around icon
    dark_radius = icon_size / 2 + min(width, height) * 0.03  # Slightly larger than icon
    
    # Create dark circle with slight transparency effect
    for i in range(20):
        alpha = 1 - i / 20
        r = dark_radius * (1 - i / 20)
        # Dark color blending with background
        dark_color = (
            int(COLORS['background'][0] * 0.7 * alpha + COLORS['background'][0] * (1 - alpha)),
            int(COLORS['background'][1] * 0.7 * alpha + COLORS['background'][1] * (1 - alpha)),
            int(COLORS['background'][2] * 0.7 * alpha + COLORS['background'][2] * (1 - alpha)),
        )
        bbox = [center_x - r, icon_center_y - r, center_x + r, icon_center_y + r]
        draw.ellipse(bbox, fill=dark_color)
    
    # Draw solid dark circle
    dark_bbox = [center_x - dark_radius, icon_center_y - dark_radius, 
                 center_x + dark_radius, icon_center_y + dark_radius]
    draw.ellipse(dark_bbox, fill=COLORS['background'])
    
    # Draw icon on top of dark area
    draw_chess_icon(draw, center_x, icon_center_y, icon_size)
    
    # Draw app name
    try:
        # Try to use a nice font, fallback to default if not available
        font_size = int(width * 0.08)
        try:
            font = ImageFont.truetype("arial.ttf", font_size)
        except:
            try:
                font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", font_size)
            except:
                font = ImageFont.load_default()
    except:
        font = ImageFont.load_default()
    
    text = "Chess RPS"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_x = center_x - text_width / 2
    text_y = icon_center_y + icon_size / 2 + height * 0.05
    
    # Draw text with shadow
    shadow_offset = int(width * 0.005)
    draw.text((text_x + shadow_offset, text_y + shadow_offset), text, 
              fill=(0, 0, 0, 128), font=font)
    draw.text((text_x, text_y), text, fill=COLORS['text_primary'], font=font)
    
    return img

def draw_chess_icon(draw, center_x, center_y, size):
    """Draw the chess icon (same design as app icon)"""
    radius = size / 2 - size * 0.05
    
    # Draw background circle with gradient effect (using filled circles, no outlines)
    for i in range(20):
        r = radius * (1 - i / 20)
        color = (
            int(COLORS['background_tertiary'][0] * (1 - i / 20) + COLORS['background'][0] * (i / 20)),
            int(COLORS['background_tertiary'][1] * (1 - i / 20) + COLORS['background'][1] * (i / 20)),
            int(COLORS['background_tertiary'][2] * (1 - i / 20) + COLORS['background'][2] * (i / 20)),
        )
        # Draw filled circle (no outline)
        bbox = [center_x - r, center_y - r, center_x + r, center_y + r]
        draw.ellipse(bbox, fill=color)
    
    # Fill main circle
    bbox = [center_x - radius, center_y - radius, center_x + radius, center_y + radius]
    draw.ellipse(bbox, fill=COLORS['background_tertiary'])
    
    # Draw border with glassmorphism effect
    border_color = (255, 255, 255, 48)  # Glass border
    draw.ellipse(bbox, outline=(255, 255, 255), width=int(size * 0.02))
    
    # Draw chess board pattern (4x4 squares)
    square_size = radius * 0.6 / 4
    board_offset_x = center_x - square_size * 2
    board_offset_y = center_y - square_size * 2
    
    for row in range(4):
        for col in range(4):
            is_light = (row + col) % 2 == 0
            if is_light:
                color = COLORS['accent']
                alpha = 0.2
            else:
                color = COLORS['purple_accent']
                alpha = 0.3
            
            # Blend with background
            r = int(color[0] * alpha + COLORS['background_tertiary'][0] * (1 - alpha))
            g = int(color[1] * alpha + COLORS['background_tertiary'][1] * (1 - alpha))
            b = int(color[2] * alpha + COLORS['background_tertiary'][2] * (1 - alpha))
            
            x1 = board_offset_x + col * square_size
            y1 = board_offset_y + row * square_size
            x2 = x1 + square_size
            y2 = y1 + square_size
            
            draw.rectangle([x1, y1, x2, y2], fill=(r, g, b))
    
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
    arc_radius = radius - size * 0.05
    arc_width = int(size * 0.015)
    
    # Top arc
    arc_bbox = [center_x - arc_radius, center_y - arc_radius, 
                center_x + arc_radius, center_y + arc_radius]
    # Draw arc (approximate with lines)
    for angle in range(-54, 55, 2):
        rad = math.radians(angle)
        x1 = center_x + arc_radius * math.cos(rad)
        y1 = center_y + arc_radius * math.sin(rad)
        x2 = center_x + (arc_radius - arc_width) * math.cos(rad)
        y2 = center_y + (arc_radius - arc_width) * math.sin(rad)
        draw.line([(x1, y1), (x2, y2)], fill=COLORS['accent'], width=arc_width)
    
    # Bottom arc
    for angle in range(126, 235, 2):
        rad = math.radians(angle)
        x1 = center_x + arc_radius * math.cos(rad)
        y1 = center_y + arc_radius * math.sin(rad)
        x2 = center_x + (arc_radius - arc_width) * math.cos(rad)
        y2 = center_y + (arc_radius - arc_width) * math.sin(rad)
        draw.line([(x1, y1), (x2, y2)], fill=COLORS['accent'], width=arc_width)

def draw_king(draw, center_x, center_y, size):
    """Draw a king chess piece"""
    color = COLORS['accent']
    
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
    color = COLORS['purple_accent']
    
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
    crown_color = COLORS['purple_light']
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
    """Generate splash screen images for different screen sizes"""
    output_dir = 'assets/images/splash'
    os.makedirs(output_dir, exist_ok=True)
    
    # Common screen sizes
    splash_sizes = {
        # Android common sizes
        'android-port-hdpi': (480, 800),
        'android-port-xhdpi': (720, 1280),
        'android-port-xxhdpi': (1080, 1920),
        'android-port-xxxhdpi': (1440, 2560),
        'android-land-hdpi': (800, 480),
        'android-land-xhdpi': (1280, 720),
        'android-land-xxhdpi': (1920, 1080),
        'android-land-xxxhdpi': (2560, 1440),
        
        # iOS sizes
        'ios-iphone-se': (640, 1136),
        'ios-iphone-8': (750, 1334),
        'ios-iphone-8-plus': (1242, 2208),
        'ios-iphone-x': (1125, 2436),
        'ios-ipad': (1536, 2048),
        'ios-ipad-pro': (2048, 2732),
    }
    
    print('Generating splash screen images...')
    
    for name, (width, height) in splash_sizes.items():
        splash = create_splash_screen(width, height)
        output_path = os.path.join(output_dir, f'{name}.png')
        splash.save(output_path, 'PNG')
        print(f'Generated: {output_path} ({width}x{height})')
    
    # Generate Android launch images (square, centered)
    android_launch_sizes = [96, 144, 192, 256, 384, 512]
    android_launch_dir = 'android/app/src/main/res'
    
    for size in android_launch_sizes:
        # Create square image with dark background
        img = Image.new('RGB', (size, size), COLORS['background'])
        draw = ImageDraw.Draw(img)
        
        # Gradient background
        for y in range(size):
            ratio = y / size
            r = int(COLORS['background'][0] * (1 - ratio) + COLORS['background_tertiary'][0] * ratio)
            g = int(COLORS['background'][1] * (1 - ratio) + COLORS['background_tertiary'][1] * ratio)
            b = int(COLORS['background'][2] * (1 - ratio) + COLORS['background_tertiary'][2] * ratio)
            draw.line([(0, y), (size, y)], fill=(r, g, b))
        
        # Draw dark circle area around icon
        icon_size = size * 0.6
        dark_radius = icon_size / 2 + size * 0.08  # Slightly larger than icon
        dark_center = size / 2
        
        # Create dark circle with slight transparency effect
        for i in range(20):
            alpha = 1 - i / 20
            r = dark_radius * (1 - i / 20)
            # Dark color blending with background
            dark_color = (
                int(COLORS['background'][0] * 0.7 * alpha + COLORS['background'][0] * (1 - alpha)),
                int(COLORS['background'][1] * 0.7 * alpha + COLORS['background'][1] * (1 - alpha)),
                int(COLORS['background'][2] * 0.7 * alpha + COLORS['background'][2] * (1 - alpha)),
            )
            bbox = [dark_center - r, dark_center - r, dark_center + r, dark_center + r]
            draw.ellipse(bbox, fill=dark_color)
        
        # Draw solid dark circle
        dark_bbox = [dark_center - dark_radius, dark_center - dark_radius, 
                     dark_center + dark_radius, dark_center + dark_radius]
        draw.ellipse(dark_bbox, fill=COLORS['background'])
        
        # Draw icon on top of dark area
        draw_chess_icon(draw, size/2, size/2, size * 0.6)
        
        # Save to drawable
        drawable_dir = f'{android_launch_dir}/drawable'
        os.makedirs(drawable_dir, exist_ok=True)
        output_path = f'{drawable_dir}/launch_image_{size}.png'
        img.save(output_path, 'PNG')
        print(f'Generated: {output_path} ({size}x{size})')
    
    # Generate iOS launch images
    ios_launch_sizes = {
        'LaunchImage': 168,
        'LaunchImage@2x': 336,
        'LaunchImage@3x': 504,
    }
    
    ios_dir = 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
    os.makedirs(ios_dir, exist_ok=True)
    
    for name, size in ios_launch_sizes.items():
        # Create square image with dark background
        img = Image.new('RGB', (size, size), COLORS['background'])
        draw = ImageDraw.Draw(img)
        
        # Gradient background
        for y in range(size):
            ratio = y / size
            r = int(COLORS['background'][0] * (1 - ratio) + COLORS['background_tertiary'][0] * ratio)
            g = int(COLORS['background'][1] * (1 - ratio) + COLORS['background_tertiary'][1] * ratio)
            b = int(COLORS['background'][2] * (1 - ratio) + COLORS['background_tertiary'][2] * ratio)
            draw.line([(0, y), (size, y)], fill=(r, g, b))
        
        # Draw dark circle area around icon
        icon_size = size * 0.6
        dark_radius = icon_size / 2 + size * 0.08  # Slightly larger than icon
        dark_center = size / 2
        
        # Create dark circle with slight transparency effect
        for i in range(20):
            alpha = 1 - i / 20
            r = dark_radius * (1 - i / 20)
            # Dark color blending with background
            dark_color = (
                int(COLORS['background'][0] * 0.7 * alpha + COLORS['background'][0] * (1 - alpha)),
                int(COLORS['background'][1] * 0.7 * alpha + COLORS['background'][1] * (1 - alpha)),
                int(COLORS['background'][2] * 0.7 * alpha + COLORS['background'][2] * (1 - alpha)),
            )
            bbox = [dark_center - r, dark_center - r, dark_center + r, dark_center + r]
            draw.ellipse(bbox, fill=dark_color)
        
        # Draw solid dark circle
        dark_bbox = [dark_center - dark_radius, dark_center - dark_radius, 
                     dark_center + dark_radius, dark_center + dark_radius]
        draw.ellipse(dark_bbox, fill=COLORS['background'])
        
        # Draw icon on top of dark area
        draw_chess_icon(draw, size/2, size/2, size * 0.6)
        
        output_path = f'{ios_dir}/{name}.png'
        img.save(output_path, 'PNG')
        print(f'Generated: {output_path} ({size}x{size})')
    
    print('\nDone! All splash screen images generated successfully.')

if __name__ == '__main__':
    main()

