"""
Level System for Chess RPS
Implements an XP-based leveling system with chess-inspired titles.
"""
from typing import Tuple, Dict, Any

# Level system constants
BASE_XP = 100  # Base XP for level 1
XP_MULTIPLIER = 2.5  # Exponential multiplier for each level
MIN_XP_PER_GAME = 10  # Minimum XP for completing a game
WIN_XP_BASE = 50  # Base XP for winning
LOSS_XP_BASE = 20  # Base XP for losing (participation)
DRAW_XP_BASE = 35  # Base XP for drawing
OPPONENT_BONUS_MULTIPLIER = 0.1  # Bonus XP based on opponent rating difference

# Chess-inspired level names
LEVEL_NAMES: Dict[int, str] = {
    0: "Novice",
    1: "Beginner",
    2: "Apprentice",
    3: "Intermediate",
    4: "Advanced",
    5: "Expert",
    6: "Master",
    7: "Grandmaster",
    8: "International Master",
    9: "World Champion",
    10: "Legend",
    11: "Mythic",
    12: "Transcendent",
    13: "Divine",
    14: "Immortal",
}

# Extended level names for levels beyond 14
def get_level_name(level: int) -> str:
    """Get the name for a given level."""
    if level in LEVEL_NAMES:
        return LEVEL_NAMES[level]
    elif level < 20:
        return f"Level {level}"
    elif level < 30:
        return f"Elite {level - 19}"
    elif level < 40:
        return f"Supreme {level - 29}"
    else:
        return f"Ultimate {level - 39}"


def calculate_xp_for_level(level: int) -> int:
    """
    Calculate the total XP required to reach a given level.
    Uses exponential progression: XP = base * multiplier^(level-1)
    
    Level 0: 0 XP
    Level 1: 100 XP
    Level 2: 250 XP
    Level 3: 625 XP
    Level 4: 1562 XP
    etc.
    """
    if level <= 0:
        return 0
    return int(BASE_XP * (XP_MULTIPLIER ** (level - 1)))


def calculate_level_from_xp(total_xp: int) -> Tuple[int, int, int]:
    """
    Calculate current level, XP in current level, and XP needed for next level.
    Returns: (level, current_level_xp, xp_needed_for_next_level)
    """
    if total_xp < 0:
        total_xp = 0
    
    level = 0
    while total_xp >= calculate_xp_for_level(level + 1):
        level += 1
    
    current_level_xp = total_xp - calculate_xp_for_level(level)
    next_level_xp = calculate_xp_for_level(level + 1) - calculate_xp_for_level(level)
    
    return level, current_level_xp, next_level_xp


def calculate_xp_reward(
    result: str,
    player_rating: int,
    opponent_rating: int = None
) -> int:
    """
    Calculate XP reward for completing a game.
    
    Args:
        result: "win", "loss", or "draw"
        player_rating: Player's current rating
        opponent_rating: Opponent's rating (optional, for bonus calculation)
    
    Returns:
        XP reward amount
    """
    # Base XP based on result
    if result == "win":
        base_xp = WIN_XP_BASE
    elif result == "draw":
        base_xp = DRAW_XP_BASE
    else:  # loss
        base_xp = LOSS_XP_BASE
    
    # Bonus XP based on opponent rating (if provided)
    bonus_xp = 0
    if opponent_rating is not None:
        rating_diff = opponent_rating - player_rating
        # Bonus for beating higher-rated opponents, smaller bonus for lower-rated
        bonus_xp = int(rating_diff * OPPONENT_BONUS_MULTIPLIER)
        # Cap bonus between -10 and +30
        bonus_xp = max(-10, min(30, bonus_xp))
    
    total_xp = base_xp + bonus_xp
    
    # Ensure minimum XP
    return max(MIN_XP_PER_GAME, total_xp)


def get_level_progress(total_xp: int) -> Dict[str, Any]:
    """
    Get detailed level progress information.
    
    Returns:
        Dictionary with level, level_name, current_xp, xp_for_next_level, progress_percentage
    """
    level, current_level_xp, xp_for_next_level = calculate_level_from_xp(total_xp)
    level_name = get_level_name(level)
    
    progress_percentage = 0.0
    if xp_for_next_level > 0:
        progress_percentage = (current_level_xp / xp_for_next_level) * 100.0
    
    return {
        "level": level,
        "level_name": level_name,
        "total_xp": total_xp,
        "current_level_xp": current_level_xp,
        "xp_for_next_level": xp_for_next_level,
        "progress_percentage": round(progress_percentage, 2)
    }
