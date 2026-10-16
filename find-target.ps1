
$ErrorActionPreference = "Stop"

$folder = "C:\Users\JustMark\Downloads\Steam Macro"
$cropPath = Join-Path $folder "crop.png"
$bigPath = Join-Path $folder "crop-big.png"
$resultFile = Join-Path $folder "target.txt"
$tesseract = "C:\Program Files\Tesseract-OCR\tesseract.exe"

try {
    if (!(Test-Path $cropPath)) { throw "crop.png not found" }
    if (!(Test-Path $tesseract)) { throw "Tesseract not found" }

    Remove-Item $resultFile, $bigPath -Force -ErrorAction SilentlyContinue

    Add-Type -AssemblyName System.Drawing

    $img = [System.Drawing.Image]::FromFile($cropPath)
    try {
        $big = New-Object System.Drawing.Bitmap(
            ($img.Width * 3),
            ($img.Height * 3)
        )

        try {
            $g = [System.Drawing.Graphics]::FromImage($big)
            try {
                $g.InterpolationMode =
                    [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $g.DrawImage($img, 0, 0, $big.Width, $big.Height)
                $big.Save(
                    $bigPath,
                    [System.Drawing.Imaging.ImageFormat]::Png
                )
            }
            finally {
                $g.Dispose()
            }
        }
        finally {
            $big.Dispose()
        }
    }
    finally {
        $img.Dispose()
    }

    $tsv = & $tesseract $bigPath stdout --psm 11 tsv 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Tesseract OCR failed" }

    $rows = $tsv | ConvertFrom-Csv -Delimiter "`t"

    $word = $rows |
        Where-Object {
            $_.level -eq "5" -and
            $_.text -match "^(Remove|Rem0ve)$"
        } |
        Select-Object -First 1

    if (!$word) {
        throw "Could not find Remove in the menu"
    }

    # crop.png begins at screen position 581,548 and is enlarged 3x
    $x = [int](581 + ([double]$word.left + [double]$word.width / 2) / 3)
    $y = [int](548 + ([double]$word.top + [double]$word.height / 2) / 3)

    "$x $y" | Set-Content $resultFile
    Write-Output "Detected coordinates: $x $y"
    exit 0
}
catch {
    Remove-Item $resultFile -Force -ErrorAction SilentlyContinue
    Write-Output "ERROR: $($_.Exception.Message)"
    exit 1
}
