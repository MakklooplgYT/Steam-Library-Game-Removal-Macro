# Steam Library Game Removal Macro

Automatically removes games from your Steam library using AutoHotkey and PowerShell. Uses screen coordinates and OCR to detect the **"Remove from account"** option, with customizable click delays and hotkeys.

## How to Run

1. Open Steam on your PC in **Windowed Fullscreen** mode.
2. Go to your Library.
3. In the left sidebar, click **Uncategorized** to display your uncategorized games in the full Library view.<br>
<img width="261" height="177" alt="image" src="https://github.com/user-attachments/assets/b796be20-5747-45aa-bac5-6603e5068e7e" /><br>
4. Make sure Steam is positioned the same way as when you configured the macro.
5. Open `SteamMacro.ahk` to launch the macro.

## Controls

| Key | Action |
|---|---|
| `F6` | Start the macro |
| `F7` | Stop and exit |
| `Esc` | Exit immediately |

## Requirements

- Windows
- AutoHotkey v2
- PowerShell
- Tesseract OCR

## Important Notes

- **Paid games:** Some paid games or licenses may not be removable through the library's right-click menu. Stop the macro and try removing these manually through Steam Support.
- **Monitor the macro:** Removing a game from your account may be permanent. Watch the screen while it runs.
- **Keep Steam in position:** The macro relies on fixed screen coordinates. Avoid moving or resizing Steam.
- **Test first:** Run one cycle and verify the selected game and confirmation dialog before continuing. You might have to change the coordinates of the buttons in SteamMacro.ahk to work with your screen size. (Working monitor size is 3840x1600)
