# PowerShell script to download chess piece assets
# Run this script from the assets directory

$ErrorActionPreference = "Stop"

# Create directory structure for different piece sets
$pieceSets = @("classic_2d", "neon_3d", "modern_flat", "fantasy_pieces")
$pieces = @("pawn", "rook", "knight", "bishop", "queen", "king")
$colors = @("white", "black")

$baseDir = "images\figures"

Write-Host "Creating directory structure..." -ForegroundColor Green

foreach ($set in $pieceSets) {
    foreach ($color in $colors) {
        $dir = Join-Path $baseDir $set $color
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "Created: $dir" -ForegroundColor Cyan
    }
}

Write-Host "`nDirectory structure created!" -ForegroundColor Green
Write-Host "`nTo download chess pieces:" -ForegroundColor Yellow
Write-Host "1. Visit one of these resources:" -ForegroundColor Yellow
Write-Host "   - https://opengameart.org/content/chess-pieces-and-board-squares-11" -ForegroundColor Cyan
Write-Host "   - https://commons.wikimedia.org/wiki/Category:Chess_pieces" -ForegroundColor Cyan
Write-Host "   - https://www.flaticon.com/packs/chess-pieces" -ForegroundColor Cyan
Write-Host "`n2. Download pieces and name them as: pawn.png, rook.png, knight.png, bishop.png, queen.png, king.png" -ForegroundColor Yellow
Write-Host "3. Place them in the appropriate set/color directories" -ForegroundColor Yellow

# Example: Download from a public repository if available
# Uncomment and modify the URLs below if you find a reliable source

<#
$baseUrl = "https://raw.githubusercontent.com/example/chess-pieces/main/"
foreach ($piece in $pieces) {
    foreach ($color in $colors) {
        $url = "$baseUrl$color/$piece.png"
        $outputPath = Join-Path $baseDir "classic_2d" $color "$piece.png"
        try {
            Invoke-WebRequest -Uri $url -OutFile $outputPath
            Write-Host "Downloaded: $outputPath" -ForegroundColor Green
        } catch {
            Write-Host "Failed to download: $url" -ForegroundColor Red
        }
    }
}
#>

