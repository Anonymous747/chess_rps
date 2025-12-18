# PowerShell script to create 20 more chess piece sets
$baseDir = "flutter_app\assets\images\figures"
$sourceSets = @("classic_2d", "neon_3d", "fantasy_pieces", "wooden_classic", "modern_flat")
$newSets = @(
    "set_6_classic_variant", "set_7_neon_variant", "set_8_fantasy_variant", "set_9_wooden_variant", "set_10_modern_variant",
    "set_11_classic_alt", "set_12_neon_alt", "set_13_fantasy_alt", "set_14_wooden_alt", "set_15_modern_alt",
    "set_16_classic_2", "set_17_neon_2", "set_18_fantasy_2", "set_19_wooden_2", "set_20_modern_2",
    "set_21_classic_3", "set_22_neon_3", "set_23_fantasy_3", "set_24_wooden_3", "set_25_modern_3"
)

Write-Host "Creating 20 additional chess piece sets..."
Write-Host ""

$successCount = 0
$setIndex = 0

foreach ($newSet in $newSets) {
    $sourceSet = $sourceSets[$setIndex % $sourceSets.Length]
    $sourcePath = Join-Path $baseDir $sourceSet
    $destPath = Join-Path $baseDir $newSet
    
    if (Test-Path $sourcePath) {
        Write-Host "Creating $newSet from $sourceSet..."
        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force | Out-Null
        $successCount++
        Write-Host "  Created $newSet"
    } else {
        Write-Host "  Source $sourceSet not found"
    }
    
    $setIndex++
}

Write-Host ""
Write-Host "Created $successCount new chess piece sets!"
$totalSets = $sourceSets.Count + $successCount
Write-Host "Total sets available: $totalSets"
