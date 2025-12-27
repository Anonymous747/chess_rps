"""
Assets router for serving static files (images, avatars, chess pieces, etc.)
"""
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse
from pathlib import Path
import logging
import os

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/assets",
    tags=["Assets"]
)

# Base path for assets directory
# Get the backend_app directory (parent of src)
BASE_DIR = Path(__file__).resolve().parent.parent.parent
ASSETS_DIR = BASE_DIR / "assets" / "images"

# Allowed asset types and directories (relative to ASSETS_DIR)
ALLOWED_ASSET_TYPES = {
    "figures": "figures",
    "avatars": "avatars",
    "splash": "splash",
}


def get_asset_path(asset_type: str, *path_parts: str) -> Path:
    """
    Get the full path to an asset file.
    
    Args:
        asset_type: Type of asset (figures, avatars, splash)
        *path_parts: Path components relative to the asset type directory
        
    Returns:
        Path object to the asset file
        
    Raises:
        HTTPException: If asset type is not allowed or path is invalid
    """
    if asset_type not in ALLOWED_ASSET_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid asset type. Allowed types: {list(ALLOWED_ASSET_TYPES.keys())}"
        )
    
    # Build the asset path
    asset_subdir = ALLOWED_ASSET_TYPES[asset_type]
    asset_path = ASSETS_DIR / asset_subdir
    
    # Add path parts
    for part in path_parts:
        # Security: prevent directory traversal
        if ".." in part or part.startswith("/"):
            raise HTTPException(status_code=400, detail="Invalid path")
        asset_path = asset_path / part
    
    # Verify the file exists and is within the assets directory
    try:
        asset_path = asset_path.resolve()
        if not asset_path.is_relative_to(ASSETS_DIR.resolve()):
            raise HTTPException(status_code=403, detail="Access denied")
    except (ValueError, OSError):
        raise HTTPException(status_code=404, detail="Asset not found")
    
    if not asset_path.exists() or not asset_path.is_file():
        raise HTTPException(status_code=404, detail="Asset not found")
    
    return asset_path


@router.get("/figures/{piece_set}/{color}/{piece}")
async def get_chess_piece(
    piece_set: str,
    color: str,
    piece: str
):
    """
    Get a chess piece image.
    
    Parameters:
    - piece_set: The piece set name (e.g., 'cardinal', 'wood', 'modern')
    - color: The piece color ('white' or 'black')
    - piece: The piece type ('pawn', 'rook', 'knight', 'bishop', 'queen', 'king')
    """
    # Validate inputs
    if color not in ["white", "black"]:
        raise HTTPException(status_code=400, detail="Color must be 'white' or 'black'")
    
    valid_pieces = ["pawn", "rook", "knight", "bishop", "queen", "king"]
    if piece not in valid_pieces:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid piece. Valid pieces: {valid_pieces}"
        )
    
    # Construct file path
    filename = f"{piece}.png"
    asset_path = get_asset_path("figures", piece_set, color, filename)
    
    return FileResponse(
        asset_path,
        media_type="image/png",
        filename=filename,
        headers={"Cache-Control": "public, max-age=3600"}
    )


@router.get("/avatars/{avatar_name}")
async def get_avatar(avatar_name: str):
    """
    Get an avatar image.
    
    Parameters:
    - avatar_name: The avatar filename (e.g., 'avatar_1.png', 'avatar_10.png')
    """
    # Validate filename format
    if not avatar_name.startswith("avatar_") or not avatar_name.endswith(".png"):
        raise HTTPException(
            status_code=400,
            detail="Avatar name must be in format 'avatar_N.png' where N is a number"
        )
    
    asset_path = get_asset_path("avatars", avatar_name)
    
    return FileResponse(
        asset_path,
        media_type="image/png",
        filename=avatar_name,
        headers={"Cache-Control": "public, max-age=3600"}
    )


@router.get("/splash/{filename}")
async def get_splash_image(filename: str):
    """
    Get a splash screen image.
    
    Parameters:
    - filename: The splash image filename
    """
    # Validate filename
    if not filename.endswith(".png"):
        raise HTTPException(status_code=400, detail="Splash images must be PNG files")
    
    asset_path = get_asset_path("splash", filename)
    
    return FileResponse(
        asset_path,
        media_type="image/png",
        filename=filename,
        headers={"Cache-Control": "public, max-age=3600"}
    )


@router.get("/health")
async def assets_health():
    """Health check for assets service."""
    return {
        "status": "ok",
        "assets_dir": str(ASSETS_DIR),
        "assets_dir_exists": ASSETS_DIR.exists(),
        "available_types": list(ALLOWED_ASSET_TYPES.keys())
    }

