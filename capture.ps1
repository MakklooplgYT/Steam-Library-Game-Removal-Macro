
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$folder = "C:\Users\JustMark\Downloads\Steam Macro"
$cropPath = Join-Path $folder "crop.png"

$bounds = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bitmap = New-Object System.Drawing.Bitmap($bounds.Width, $bounds.Height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

$graphics.CopyFromScreen(
    $bounds.Left, $bounds.Top, 0, 0, $bitmap.Size
)

# Exact Steam menu rectangle
$x = 581 - $bounds.Left
$y = 548 - $bounds.Top
$width = 754 - 581
$height = 718 - 548

$rect = New-Object System.Drawing.Rectangle($x, $y, $width, $height)
$menu = $bitmap.Clone($rect, $bitmap.PixelFormat)

$menu.Save($cropPath, [System.Drawing.Imaging.ImageFormat]::Png)

$menu.Dispose()
$graphics.Dispose()
$bitmap.Dispose()
