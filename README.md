# Prism Launcher Rofi Modpack Selector

A lightweight, self-toggling Rofi dmenu script for Prism Launcher that lets you seamlessly select modpacks, browse and launch individual worlds by modification time, open the full Prism Launcher app, or launch instances directly.

## Features

* **Self-Toggling Keybind Support:** Pressing your shortcut key once opens the menu; pressing it again instantly closes it.
* **Auto-Sorting by Recent Activity:** Both your modpack instances and Minecraft worlds are automatically sorted by their latest modified date/time (newest first).
* **Robust Spacing Support:** Safely handles folder and modpack names with spaces (e.g., "Create Daily", "Fabulously Optimized").
* **Rich Icon Integration:** Features custom application icons, grass block icons for worlds, and custom action icons.

---

## Icon File Directory Setup

To ensure all icons render properly, place your icon assets in the following exact locations:

* **Prism Launcher Logo:** Automatically detected from system paths (`/usr/share/icons/hicolor/`).
* **Grass Block Icon (Worlds):**
```bash
~/.local/share/PrismLauncher/icons/grass.png

```


* **Exit Icon:**
```bash
~/.local/modIcons/exit.png

```


* **Back Icon:**
```bash
~/.local/modIcons/back.png

```



---

## Custom Modpacks & Icon Exporting Note

If you are creating **custom modpacks** in Prism Launcher and want your custom pack icon to display correctly in the menu, Prism Launcher looks for an image file directly inside the instance folder (`icon.png`, `icon.svg`, etc.).

To export or apply an icon to a custom modpack folder:

1. Create a `.desktop` shortcut file or assign your desired image asset.
2. Ensure the icon file is explicitly exported/saved as `icon.png` (or `.svg`, `.ico`, `.webp`) directly inside your specific instance's root folder (`~/.local/share/PrismLauncher/instances/YourModpackName/`).

---

## Hyprland Configuration & Device Binding Tutorial

To bind this script to a custom key combination on a specific keyboard input device in your window manager environment, you can configure it like this:

```lua
hl.bind("SUPER + code:42", hl.dsp.exec_cmd("bash /home/khraos/Dev/scripts/modpack.sh"), { device = { inclusive = true, list = {
    "sino-wealth-usb-keyboard",
    "sino-wealth-usb-keyboard-system-control",
    "sino-wealth-usb-keyboard-consumer-control",
    "sino-wealth-usb-keyboard-1"
} } })

```

### How to Find Your Device Names and Key Codes

If you need to map extra keys or find the exact identifiers for your input device:

1. **Find your connected keyboard/device names:** Run the following command in your terminal to list active input devices recognized by your compositor/system:
```bash
hyprctl devices

```


Look under the **Keyboards** section to copy the exact device names string (e.g., `"sino-wealth-usb-keyboard"`).
2. **Find your key codes:** Run `wev` or `evtest` in your terminal, then press the key you want to bind. Look for the `keycode:` output value (e.g., `code:42`) to use in your bind string.

---

## Credits

* **Back & Exit Icons:** Provided by **[Icons8](https://icons8.com)**.
