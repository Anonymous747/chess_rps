"""
Script to create 20 unique, funny person and animal avatar images.
Uses PIL/Pillow to generate cute and funny character avatars.
"""
from PIL import Image, ImageDraw
import os
import math

# Create avatars directory if it doesn't exist
avatars_dir = os.path.dirname(__file__)
os.makedirs(avatars_dir, exist_ok=True)

# Define 20 funny avatar designs (people and animals)
avatar_designs = [
    # 1-5: Funny people
    {"type": "person", "skin": (255, 220, 177), "hair": (139, 69, 19), "expression": "happy", "accessory": "crown", "name": "Happy King"},
    {"type": "person", "skin": (255, 206, 180), "hair": (0, 0, 0), "expression": "wink", "accessory": "glasses", "name": "Cool Dude"},
    {"type": "person", "skin": (255, 228, 196), "hair": (255, 215, 0), "expression": "surprised", "accessory": "hat", "name": "Surprised Player"},
    {"type": "person", "skin": (222, 184, 135), "hair": (128, 128, 128), "expression": "laughing", "accessory": "beard", "name": "Laughing Master"},
    {"type": "person", "skin": (255, 218, 185), "hair": (75, 0, 130), "expression": "cool", "accessory": "sunglasses", "name": "Cool Strategist"},
    
    # 6-10: Cute animals
    {"type": "cat", "color": (255, 165, 0), "expression": "happy", "accessory": "bow", "name": "Happy Cat"},
    {"type": "dog", "color": (139, 69, 19), "expression": "excited", "accessory": "bandana", "name": "Excited Dog"},
    {"type": "bear", "color": (139, 90, 43), "expression": "friendly", "accessory": "none", "name": "Friendly Bear"},
    {"type": "rabbit", "color": (255, 255, 255), "expression": "cute", "accessory": "carrot", "name": "Cute Rabbit"},
    {"type": "panda", "color": (0, 0, 0), "expression": "sleepy", "accessory": "bamboo", "name": "Sleepy Panda"},
    
    # 11-15: More funny characters
    {"type": "person", "skin": (255, 228, 196), "hair": (255, 20, 147), "expression": "silly", "accessory": "party_hat", "name": "Party Person"},
    {"type": "owl", "color": (139, 69, 19), "expression": "wise", "accessory": "glasses", "name": "Wise Owl"},
    {"type": "monkey", "color": (139, 90, 43), "expression": "mischievous", "accessory": "banana", "name": "Mischievous Monkey"},
    {"type": "person", "skin": (255, 218, 185), "hair": (0, 128, 0), "expression": "nerd", "accessory": "glasses", "name": "Chess Nerd"},
    {"type": "fox", "color": (255, 140, 0), "expression": "cunning", "accessory": "none", "name": "Cunning Fox"},
    
    # 16-20: Legendary funny characters
    {"type": "person", "skin": (255, 220, 177), "hair": (255, 215, 0), "expression": "epic", "accessory": "crown", "name": "Epic Champion"},
    {"type": "dragon", "color": (255, 69, 0), "expression": "friendly", "accessory": "none", "name": "Friendly Dragon"},
    {"type": "person", "skin": (255, 228, 196), "hair": (138, 43, 226), "expression": "mystical", "accessory": "star", "name": "Mystical Wizard"},
    {"type": "unicorn", "color": (255, 192, 203), "expression": "magical", "accessory": "horn", "name": "Magical Unicorn"},
    {"type": "person", "skin": (255, 218, 185), "hair": (0, 0, 0), "expression": "legendary", "accessory": "crown", "name": "Legendary Master"},
]

def draw_person_face(draw, size, skin_color, hair_color, expression, accessory):
    """Draw a funny person face"""
    center_x, center_y = size // 2, size // 2
    face_radius = size // 3
    
    # Face
    draw.ellipse(
        [center_x - face_radius, center_y - face_radius, 
         center_x + face_radius, center_y + face_radius],
        fill=skin_color,
        outline=(0, 0, 0),
        width=2
    )
    
    # Hair
    if hair_color:
        hair_points = [
            (center_x - face_radius * 0.8, center_y - face_radius * 0.6),
            (center_x - face_radius * 0.9, center_y - face_radius * 1.2),
            (center_x, center_y - face_radius * 1.3),
            (center_x + face_radius * 0.9, center_y - face_radius * 1.2),
            (center_x + face_radius * 0.8, center_y - face_radius * 0.6),
        ]
        draw.polygon(hair_points, fill=hair_color)
    
    # Eyes
    eye_y = center_y - face_radius * 0.2
    eye_size = size // 20
    
    if expression == "wink":
        # One eye closed
        draw.ellipse(
            [center_x - face_radius * 0.4 - eye_size, eye_y - eye_size,
             center_x - face_radius * 0.4 + eye_size, eye_y + eye_size],
            fill=(0, 0, 0)
        )
        # Wink line
        draw.line(
            [center_x + face_radius * 0.4 - eye_size, eye_y,
             center_x + face_radius * 0.4 + eye_size, eye_y],
            fill=(0, 0, 0),
            width=3
        )
    elif expression == "surprised":
        # Big round eyes
        draw.ellipse(
            [center_x - face_radius * 0.4 - eye_size * 1.5, eye_y - eye_size * 1.5,
             center_x - face_radius * 0.4 + eye_size * 1.5, eye_y + eye_size * 1.5],
            fill=(0, 0, 0)
        )
        draw.ellipse(
            [center_x + face_radius * 0.4 - eye_size * 1.5, eye_y - eye_size * 1.5,
             center_x + face_radius * 0.4 + eye_size * 1.5, eye_y + eye_size * 1.5],
            fill=(0, 0, 0)
        )
    elif expression == "laughing":
        # Squinted eyes
        for offset in [-face_radius * 0.4, face_radius * 0.4]:
            draw.arc(
                [center_x + offset - eye_size, eye_y - eye_size,
                 center_x + offset + eye_size, eye_y + eye_size],
                0, 180,
                fill=(0, 0, 0),
                width=3
            )
    elif expression == "cool":
        # Cool sunglasses
        draw.rectangle(
            [center_x - face_radius * 0.5, eye_y - eye_size,
             center_x + face_radius * 0.5, eye_y + eye_size],
            fill=(50, 50, 50),
            outline=(0, 0, 0),
            width=2
        )
    elif expression == "silly":
        # Crossed eyes
        draw.ellipse(
            [center_x - face_radius * 0.3 - eye_size, eye_y - eye_size,
             center_x - face_radius * 0.3 + eye_size, eye_y + eye_size],
            fill=(0, 0, 0)
        )
        draw.ellipse(
            [center_x + face_radius * 0.3 - eye_size, eye_y - eye_size,
             center_x + face_radius * 0.3 + eye_size, eye_y + eye_size],
            fill=(0, 0, 0)
        )
    elif expression == "nerd":
        # Glasses
        draw.ellipse(
            [center_x - face_radius * 0.5 - eye_size * 1.5, eye_y - eye_size,
             center_x - face_radius * 0.2 + eye_size * 1.5, eye_y + eye_size],
            outline=(0, 0, 0),
            width=3
        )
        draw.ellipse(
            [center_x + face_radius * 0.2 - eye_size * 1.5, eye_y - eye_size,
             center_x + face_radius * 0.5 + eye_size * 1.5, eye_y + eye_size],
            outline=(0, 0, 0),
            width=3
        )
        draw.line(
            [center_x - face_radius * 0.2, eye_y,
             center_x + face_radius * 0.2, eye_y],
            fill=(0, 0, 0),
            width=2
        )
        draw.ellipse(
            [center_x - face_radius * 0.4 - eye_size, eye_y - eye_size,
             center_x - face_radius * 0.4 + eye_size, eye_y + eye_size],
            fill=(0, 0, 0)
        )
        draw.ellipse(
            [center_x + face_radius * 0.4 - eye_size, eye_y - eye_size,
             center_x + face_radius * 0.4 + eye_size, eye_y + eye_size],
            fill=(0, 0, 0)
        )
    else:  # happy, epic, mystical, legendary
        # Normal happy eyes
        draw.ellipse(
            [center_x - face_radius * 0.4 - eye_size, eye_y - eye_size,
             center_x - face_radius * 0.4 + eye_size, eye_y + eye_size],
            fill=(0, 0, 0)
        )
        draw.ellipse(
            [center_x + face_radius * 0.4 - eye_size, eye_y - eye_size,
             center_x + face_radius * 0.4 + eye_size, eye_y + eye_size],
            fill=(0, 0, 0)
        )
    
    # Mouth
    mouth_y = center_y + face_radius * 0.3
    if expression in ["happy", "wink", "laughing", "epic", "legendary"]:
        # Big smile
        draw.arc(
            [center_x - face_radius * 0.4, mouth_y - face_radius * 0.2,
             center_x + face_radius * 0.4, mouth_y + face_radius * 0.2],
            0, 180,
            fill=(0, 0, 0),
            width=3
        )
    elif expression == "surprised":
        # O mouth
        draw.ellipse(
            [center_x - face_radius * 0.15, mouth_y - face_radius * 0.15,
             center_x + face_radius * 0.15, mouth_y + face_radius * 0.15],
            outline=(0, 0, 0),
            width=3
        )
    elif expression == "cool":
        # Small smile
        draw.arc(
            [center_x - face_radius * 0.3, mouth_y,
             center_x + face_radius * 0.3, mouth_y + face_radius * 0.15],
            0, 180,
            fill=(0, 0, 0),
            width=2
        )
    elif expression == "silly":
        # Tongue out
        draw.ellipse(
            [center_x - face_radius * 0.1, mouth_y,
             center_x + face_radius * 0.1, mouth_y + face_radius * 0.2],
            fill=(255, 192, 203)
        )
    elif expression == "nerd":
        # Small smile
        draw.arc(
            [center_x - face_radius * 0.25, mouth_y,
             center_x + face_radius * 0.25, mouth_y + face_radius * 0.1],
            0, 180,
            fill=(0, 0, 0),
            width=2
        )
    
    # Beard (if accessory is beard)
    if accessory == "beard":
        beard_points = [
            (center_x - face_radius * 0.3, center_y + face_radius * 0.4),
            (center_x - face_radius * 0.4, center_y + face_radius * 0.7),
            (center_x, center_y + face_radius * 0.8),
            (center_x + face_radius * 0.4, center_y + face_radius * 0.7),
            (center_x + face_radius * 0.3, center_y + face_radius * 0.4),
        ]
        draw.polygon(beard_points, fill=hair_color)
    
    # Accessories
    if accessory == "crown":
        crown_points = [
            (center_x - face_radius * 0.6, center_y - face_radius * 1.1),
            (center_x - face_radius * 0.4, center_y - face_radius * 1.3),
            (center_x - face_radius * 0.2, center_y - face_radius * 1.2),
            (center_x, center_y - face_radius * 1.4),
            (center_x + face_radius * 0.2, center_y - face_radius * 1.2),
            (center_x + face_radius * 0.4, center_y - face_radius * 1.3),
            (center_x + face_radius * 0.6, center_y - face_radius * 1.1),
        ]
        draw.polygon(crown_points, fill=(255, 215, 0), outline=(0, 0, 0), width=2)
    elif accessory == "glasses" and expression != "cool" and expression != "nerd":
        draw.rectangle(
            [center_x - face_radius * 0.5, eye_y - eye_size * 1.5,
             center_x + face_radius * 0.5, eye_y + eye_size * 1.5],
            outline=(0, 0, 0),
            width=3
        )
    elif accessory == "hat":
        # Top hat
        draw.rectangle(
            [center_x - face_radius * 0.4, center_y - face_radius * 1.4,
             center_x + face_radius * 0.4, center_y - face_radius * 1.1],
            fill=(0, 0, 0)
        )
        draw.rectangle(
            [center_x - face_radius * 0.5, center_y - face_radius * 1.1,
             center_x + face_radius * 0.5, center_y - face_radius * 1.0],
            fill=(0, 0, 0)
        )
    elif accessory == "party_hat":
        # Party hat (triangle)
        hat_points = [
            (center_x, center_y - face_radius * 1.4),
            (center_x - face_radius * 0.4, center_y - face_radius * 1.0),
            (center_x + face_radius * 0.4, center_y - face_radius * 1.0),
        ]
        draw.polygon(hat_points, fill=(255, 20, 147), outline=(0, 0, 0), width=2)
    elif accessory == "star":
        # Star on forehead
        star_points = []
        for i in range(10):
            angle = (i * 2 * math.pi) / 10 - math.pi / 2
            r = face_radius * 0.15 if i % 2 == 0 else face_radius * 0.08
            x = center_x + r * math.cos(angle)
            y = center_y - face_radius * 0.7 + r * math.sin(angle)
            star_points.append((x, y))
        draw.polygon(star_points, fill=(255, 215, 0), outline=(0, 0, 0), width=1)

def draw_animal_face(draw, size, animal_type, color, expression, accessory):
    """Draw a funny animal face"""
    center_x, center_y = size // 2, size // 2
    face_radius = size // 3
    
    if animal_type == "cat":
        # Cat face (pointed ears)
        # Face
        draw.ellipse(
            [center_x - face_radius, center_y - face_radius * 0.8,
             center_x + face_radius, center_y + face_radius * 1.2],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Ears
        ear_points1 = [
            (center_x - face_radius * 0.6, center_y - face_radius * 0.8),
            (center_x - face_radius * 0.9, center_y - face_radius * 1.3),
            (center_x - face_radius * 0.3, center_y - face_radius * 1.1),
        ]
        ear_points2 = [
            (center_x + face_radius * 0.6, center_y - face_radius * 0.8),
            (center_x + face_radius * 0.3, center_y - face_radius * 1.1),
            (center_x + face_radius * 0.9, center_y - face_radius * 1.3),
        ]
        draw.polygon(ear_points1, fill=color, outline=(0, 0, 0), width=2)
        draw.polygon(ear_points2, fill=color, outline=(0, 0, 0), width=2)
        # Inner ears
        draw.polygon([(center_x - face_radius * 0.6, center_y - face_radius * 0.9),
                     (center_x - face_radius * 0.75, center_y - face_radius * 1.2),
                     (center_x - face_radius * 0.4, center_y - face_radius * 1.05)],
                    fill=(255, 192, 203))
        draw.polygon([(center_x + face_radius * 0.6, center_y - face_radius * 0.9),
                     (center_x + face_radius * 0.4, center_y - face_radius * 1.05),
                     (center_x + face_radius * 0.75, center_y - face_radius * 1.2)],
                    fill=(255, 192, 203))
        
    elif animal_type == "dog":
        # Dog face (floppy ears)
        draw.ellipse(
            [center_x - face_radius, center_y - face_radius,
             center_x + face_radius, center_y + face_radius * 1.2],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Floppy ears
        draw.ellipse(
            [center_x - face_radius * 1.1, center_y - face_radius * 0.3,
             center_x - face_radius * 0.3, center_y + face_radius * 0.7],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        draw.ellipse(
            [center_x + face_radius * 0.3, center_y - face_radius * 0.3,
             center_x + face_radius * 1.1, center_y + face_radius * 0.7],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        
    elif animal_type == "bear":
        # Bear face (round with small ears)
        draw.ellipse(
            [center_x - face_radius, center_y - face_radius,
             center_x + face_radius, center_y + face_radius],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Small round ears
        draw.ellipse(
            [center_x - face_radius * 0.8, center_y - face_radius * 0.8,
             center_x - face_radius * 0.4, center_y - face_radius * 0.4],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        draw.ellipse(
            [center_x + face_radius * 0.4, center_y - face_radius * 0.8,
             center_x + face_radius * 0.8, center_y - face_radius * 0.4],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        
    elif animal_type == "rabbit":
        # Rabbit face (long ears)
        draw.ellipse(
            [center_x - face_radius * 0.8, center_y - face_radius * 0.5,
             center_x + face_radius * 0.8, center_y + face_radius * 1.0],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Long ears
        draw.ellipse(
            [center_x - face_radius * 0.6, center_y - face_radius * 1.4,
             center_x - face_radius * 0.2, center_y - face_radius * 0.6],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        draw.ellipse(
            [center_x + face_radius * 0.2, center_y - face_radius * 1.4,
             center_x + face_radius * 0.6, center_y - face_radius * 0.6],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Inner ears
        draw.ellipse(
            [center_x - face_radius * 0.5, center_y - face_radius * 1.3,
             center_x - face_radius * 0.3, center_y - face_radius * 0.8],
            fill=(255, 192, 203)
        )
        draw.ellipse(
            [center_x + face_radius * 0.3, center_y - face_radius * 1.3,
             center_x + face_radius * 0.5, center_y - face_radius * 0.8],
            fill=(255, 192, 203)
        )
        
    elif animal_type == "panda":
        # Panda face
        draw.ellipse(
            [center_x - face_radius, center_y - face_radius,
             center_x + face_radius, center_y + face_radius],
            fill=(255, 255, 255),
            outline=(0, 0, 0),
            width=3
        )
        # Black patches around eyes
        draw.ellipse(
            [center_x - face_radius * 0.6, center_y - face_radius * 0.4,
             center_x - face_radius * 0.1, center_y + face_radius * 0.1],
            fill=(0, 0, 0)
        )
        draw.ellipse(
            [center_x + face_radius * 0.1, center_y - face_radius * 0.4,
             center_x + face_radius * 0.6, center_y + face_radius * 0.1],
            fill=(0, 0, 0)
        )
        # Ears
        draw.ellipse(
            [center_x - face_radius * 0.9, center_y - face_radius * 0.9,
             center_x - face_radius * 0.5, center_y - face_radius * 0.5],
            fill=(0, 0, 0)
        )
        draw.ellipse(
            [center_x + face_radius * 0.5, center_y - face_radius * 0.9,
             center_x + face_radius * 0.9, center_y - face_radius * 0.5],
            fill=(0, 0, 0)
        )
        
    elif animal_type == "owl":
        # Owl face (round with big eyes)
        draw.ellipse(
            [center_x - face_radius, center_y - face_radius,
             center_x + face_radius, center_y + face_radius],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Big eyes
        eye_size = face_radius * 0.4
        draw.ellipse(
            [center_x - face_radius * 0.5 - eye_size, center_y - face_radius * 0.2 - eye_size,
             center_x - face_radius * 0.5 + eye_size, center_y - face_radius * 0.2 + eye_size],
            fill=(255, 255, 255),
            outline=(0, 0, 0),
            width=2
        )
        draw.ellipse(
            [center_x + face_radius * 0.5 - eye_size, center_y - face_radius * 0.2 - eye_size,
             center_x + face_radius * 0.5 + eye_size, center_y - face_radius * 0.2 + eye_size],
            fill=(255, 255, 255),
            outline=(0, 0, 0),
            width=2
        )
        # Pupils
        draw.ellipse(
            [center_x - face_radius * 0.5 - eye_size * 0.3, center_y - face_radius * 0.2 - eye_size * 0.3,
             center_x - face_radius * 0.5 + eye_size * 0.3, center_y - face_radius * 0.2 + eye_size * 0.3],
            fill=(0, 0, 0)
        )
        draw.ellipse(
            [center_x + face_radius * 0.5 - eye_size * 0.3, center_y - face_radius * 0.2 - eye_size * 0.3,
             center_x + face_radius * 0.5 + eye_size * 0.3, center_y - face_radius * 0.2 + eye_size * 0.3],
            fill=(0, 0, 0)
        )
        # Beak
        beak_points = [
            (center_x, center_y + face_radius * 0.2),
            (center_x - face_radius * 0.15, center_y + face_radius * 0.4),
            (center_x + face_radius * 0.15, center_y + face_radius * 0.4),
        ]
        draw.polygon(beak_points, fill=(255, 165, 0), outline=(0, 0, 0), width=1)
        
    elif animal_type == "monkey":
        # Monkey face
        draw.ellipse(
            [center_x - face_radius, center_y - face_radius,
             center_x + face_radius, center_y + face_radius],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Ears
        draw.ellipse(
            [center_x - face_radius * 0.9, center_y - face_radius * 0.5,
             center_x - face_radius * 0.5, center_y - face_radius * 0.1],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        draw.ellipse(
            [center_x + face_radius * 0.5, center_y - face_radius * 0.5,
             center_x + face_radius * 0.9, center_y - face_radius * 0.1],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        
    elif animal_type == "fox":
        # Fox face (pointed snout)
        draw.ellipse(
            [center_x - face_radius, center_y - face_radius * 0.8,
             center_x + face_radius, center_y + face_radius * 1.0],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Pointed ears
        ear_points1 = [
            (center_x - face_radius * 0.6, center_y - face_radius * 0.8),
            (center_x - face_radius * 0.9, center_y - face_radius * 1.2),
            (center_x - face_radius * 0.3, center_y - face_radius * 1.0),
        ]
        ear_points2 = [
            (center_x + face_radius * 0.6, center_y - face_radius * 0.8),
            (center_x + face_radius * 0.3, center_y - face_radius * 1.0),
            (center_x + face_radius * 0.9, center_y - face_radius * 1.2),
        ]
        draw.polygon(ear_points1, fill=color, outline=(0, 0, 0), width=2)
        draw.polygon(ear_points2, fill=color, outline=(0, 0, 0), width=2)
        # White tip
        draw.ellipse(
            [center_x - face_radius * 0.1, center_y + face_radius * 0.6,
             center_x + face_radius * 0.1, center_y + face_radius * 0.9],
            fill=(255, 255, 255)
        )
        
    elif animal_type == "dragon":
        # Dragon face (reptilian)
        draw.ellipse(
            [center_x - face_radius, center_y - face_radius,
             center_x + face_radius, center_y + face_radius],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Horns
        horn_points1 = [
            (center_x - face_radius * 0.5, center_y - face_radius * 0.9),
            (center_x - face_radius * 0.7, center_y - face_radius * 1.3),
            (center_x - face_radius * 0.3, center_y - face_radius * 1.1),
        ]
        horn_points2 = [
            (center_x + face_radius * 0.5, center_y - face_radius * 0.9),
            (center_x + face_radius * 0.3, center_y - face_radius * 1.1),
            (center_x + face_radius * 0.7, center_y - face_radius * 1.3),
        ]
        draw.polygon(horn_points1, fill=color, outline=(0, 0, 0), width=2)
        draw.polygon(horn_points2, fill=color, outline=(0, 0, 0), width=2)
        
    elif animal_type == "unicorn":
        # Unicorn face (horse-like with horn)
        draw.ellipse(
            [center_x - face_radius * 0.8, center_y - face_radius * 0.6,
             center_x + face_radius * 0.8, center_y + face_radius * 1.0],
            fill=color,
            outline=(0, 0, 0),
            width=2
        )
        # Horn (spiral)
        horn_points = [
            (center_x, center_y - face_radius * 1.2),
            (center_x - face_radius * 0.1, center_y - face_radius * 1.4),
            (center_x + face_radius * 0.1, center_y - face_radius * 1.5),
            (center_x, center_y - face_radius * 1.6),
        ]
        draw.polygon(horn_points, fill=(255, 215, 0), outline=(0, 0, 0), width=2)
        # Mane
        for i in range(5):
            angle = (i * 2 * math.pi) / 5 - math.pi / 2
            x = center_x + face_radius * 0.9 * math.cos(angle)
            y = center_y - face_radius * 0.5 + face_radius * 0.9 * math.sin(angle)
            draw.ellipse(
                [x - face_radius * 0.1, y - face_radius * 0.1,
                 x + face_radius * 0.1, y + face_radius * 0.1],
                fill=(255, 192, 203)
            )
    
    # Common features for all animals
    eye_y = center_y - face_radius * 0.2
    eye_size = size // 25
    
    # Eyes (if not already drawn for specific animals)
    if animal_type not in ["panda", "owl"]:
        if expression == "sleepy":
            # Half-closed eyes
            for offset in [-face_radius * 0.4, face_radius * 0.4]:
                draw.arc(
                    [center_x + offset - eye_size, eye_y - eye_size,
                     center_x + offset + eye_size, eye_y + eye_size],
                    0, 180,
                    fill=(0, 0, 0),
                    width=3
                )
        elif expression == "excited":
            # Big round eyes
            draw.ellipse(
                [center_x - face_radius * 0.4 - eye_size * 1.5, eye_y - eye_size * 1.5,
                 center_x - face_radius * 0.4 + eye_size * 1.5, eye_y + eye_size * 1.5],
                fill=(0, 0, 0)
            )
            draw.ellipse(
                [center_x + face_radius * 0.4 - eye_size * 1.5, eye_y - eye_size * 1.5,
                 center_x + face_radius * 0.4 + eye_size * 1.5, eye_y + eye_size * 1.5],
                fill=(0, 0, 0)
            )
        else:  # happy, friendly, cute, wise, cunning, friendly, magical
            draw.ellipse(
                [center_x - face_radius * 0.4 - eye_size, eye_y - eye_size,
                 center_x - face_radius * 0.4 + eye_size, eye_y + eye_size],
                fill=(0, 0, 0)
            )
            draw.ellipse(
                [center_x + face_radius * 0.4 - eye_size, eye_y - eye_size,
                 center_x + face_radius * 0.4 + eye_size, eye_y + eye_size],
                fill=(0, 0, 0)
            )
    
    # Mouth
    mouth_y = center_y + face_radius * 0.3
    if expression in ["happy", "excited", "friendly", "cute", "magical"]:
        # Smile
        draw.arc(
            [center_x - face_radius * 0.4, mouth_y - face_radius * 0.15,
             center_x + face_radius * 0.4, mouth_y + face_radius * 0.15],
            0, 180,
            fill=(0, 0, 0),
            width=3
        )
    elif expression == "sleepy":
        # Small smile
        draw.arc(
            [center_x - face_radius * 0.3, mouth_y,
             center_x + face_radius * 0.3, mouth_y + face_radius * 0.1],
            0, 180,
            fill=(0, 0, 0),
            width=2
        )
    elif expression == "wise":
        # Neutral/slight smile
        draw.arc(
            [center_x - face_radius * 0.35, mouth_y,
             center_x + face_radius * 0.35, mouth_y + face_radius * 0.12],
            0, 180,
            fill=(0, 0, 0),
            width=2
        )
    elif expression == "cunning":
        # Sly smile
        draw.arc(
            [center_x - face_radius * 0.2, mouth_y,
             center_x + face_radius * 0.5, mouth_y + face_radius * 0.15],
            0, 90,
            fill=(0, 0, 0),
            width=2
        )
    
    # Accessories
    if accessory == "bow":
        # Bow on head
        draw.ellipse(
            [center_x - face_radius * 0.2, center_y - face_radius * 1.1,
             center_x + face_radius * 0.2, center_y - face_radius * 0.9],
            fill=(255, 20, 147),
            outline=(0, 0, 0),
            width=1
        )
        draw.rectangle(
            [center_x - face_radius * 0.05, center_y - face_radius * 1.15,
             center_x + face_radius * 0.05, center_y - face_radius * 0.85],
            fill=(255, 20, 147)
        )
    elif accessory == "bandana":
        # Bandana
        draw.arc(
            [int(center_x - face_radius * 0.6), int(center_y - face_radius * 1.0),
             int(center_x + face_radius * 0.6), int(center_y - face_radius * 0.6)],
            180, 360,
            fill=(255, 69, 0),
            width=int(face_radius * 0.2)
        )
    elif accessory == "carrot":
        # Carrot in mouth
        draw.polygon(
            [(center_x, mouth_y + face_radius * 0.2),
             (center_x - face_radius * 0.1, mouth_y + face_radius * 0.5),
             (center_x + face_radius * 0.1, mouth_y + face_radius * 0.5)],
            fill=(255, 140, 0),
            outline=(0, 0, 0),
            width=1
        )
    elif accessory == "bamboo":
        # Bamboo stick
        draw.rectangle(
            [center_x - face_radius * 0.05, center_y + face_radius * 0.4,
             center_x + face_radius * 0.05, center_y + face_radius * 0.8],
            fill=(34, 139, 34),
            outline=(0, 0, 0),
            width=1
        )
    elif accessory == "glasses":
        # Glasses
        draw.rectangle(
            [center_x - face_radius * 0.5, eye_y - eye_size * 1.5,
             center_x + face_radius * 0.5, eye_y + eye_size * 1.5],
            outline=(0, 0, 0),
            width=3
        )
    elif accessory == "banana":
        # Banana
        draw.arc(
            [int(center_x + face_radius * 0.3), int(center_y + face_radius * 0.3),
             int(center_x + face_radius * 0.7), int(center_y + face_radius * 0.7)],
            45, 225,
            fill=(255, 215, 0),
            width=int(face_radius * 0.15)
        )
    elif accessory == "horn":
        # Already drawn for unicorn
        pass

def create_avatar(index, design, size=256):
    """Create a single avatar image"""
    img = Image.new('RGB', (size, size), color=(240, 240, 240))
    draw = ImageDraw.Draw(img)
    
    if design['type'] == 'person':
        draw_person_face(
            draw, size,
            design.get('skin', (255, 220, 177)),
            design.get('hair', (139, 69, 19)),
            design.get('expression', 'happy'),
            design.get('accessory', 'none')
        )
    else:
        draw_animal_face(
            draw, size,
            design['type'],
            design.get('color', (139, 69, 19)),
            design.get('expression', 'happy'),
            design.get('accessory', 'none')
        )
    
    return img

# Generate all 20 avatars
print("Generating 20 funny person and animal avatars...")
for i, design in enumerate(avatar_designs, start=1):
    avatar = create_avatar(i, design)
    filename = f'avatar_{i}.png'
    filepath = os.path.join(avatars_dir, filename)
    avatar.save(filepath, 'PNG')
    print(f'Created {filename} - {design["name"]}')

print(f'\nSuccessfully generated all 20 funny avatars in {avatars_dir}')
print('Avatars are ready to use in the app!')
