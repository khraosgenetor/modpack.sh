#!/bin/bash

LOCKFILE="/tmp/modpack_rofi.lock"

if [ -f "$LOCKFILE" ]; then
    pkill -f "rofi.*sidebar-v2-custom.rasi"
    rm -f "$LOCKFILE"
    exit 0
fi

touch "$LOCKFILE"
trap "rm -f '$LOCKFILE'" EXIT

INSTANCE_DIR="${HOME}/.local/share/PrismLauncher/instances"
THEME_PATH="${HOME}/.local/share/rofi/themes/sidebar-v2-custom.rasi"

if [ ! -d "$INSTANCE_DIR" ]; then
    echo "Error: Prism Launcher instance directory not found at $INSTANCE_DIR"
    exit 1
fi

prism_icon_path=""
for size in 48x48 64x64 128x128 256256 scalable; do
    for ext in png svg; do
        candidate="/usr/share/icons/hicolor/${size}/apps/org.prismlauncher.PrismLauncher.${ext}"
        if [ -f "$candidate" ]; then
            prism_icon_path="$candidate"
            break 2
        fi
    done
done
[ -z "$prism_icon_path" ] && prism_icon_path=$(find /usr/share/icons/ -name "*prismlauncher*" 2>/dev/null | head -n 1)

exit_icon_path="${HOME}/.local/modIcons/exit.png"
[ ! -f "$exit_icon_path" ] && exit_icon_path="$prism_icon_path"

back_icon_path="${HOME}/.local/modIcons/back.png"
[ ! -f "$back_icon_path" ] && back_icon_path="$prism_icon_path"

grass_icon_path="${HOME}/.local/share/PrismLauncher/icons/grass.png"
[ ! -f "$grass_icon_path" ] && grass_icon_path="$prism_icon_path"

while true; do
    if [ -n "$prism_icon_path" ]; then
        instances="Open Prism Launcher\0icon\x1f${prism_icon_path}\n"
    else
        instances="Open Prism Launcher\n"
    fi
    
    while IFS= read -r dir; do
        [ -z "$dir" ] && continue
        dir_name=$(basename "$dir")
        
        icon_path=""
        for ext in png svg ico webp; do
            if [ -f "$dir/icon.$ext" ]; then
                icon_path="$dir/icon.$ext"
                break
            fi
        done
        
        if [ -n "$icon_path" ]; then
            instances+="${dir_name}\0icon\x1f${icon_path}\n"
        else
            instances+="${dir_name}\n"
        fi
    done < <(find "$INSTANCE_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | cut -d' ' -f2-)

    if [ -n "$exit_icon_path" ]; then
        instances+="Exit\0icon\x1f${exit_icon_path}"
    else
        instances+="Exit"
    fi

    chosen_instance=$(echo -en "$instances" | rofi -dmenu -p "Modpack: " -theme "$THEME_PATH" -show-icons -markup-rows)

    if [ -z "$chosen_instance" ] || [ "$chosen_instance" = "Exit" ]; then
        rm -f "$LOCKFILE"
        exit 0
    fi

    if [ "$chosen_instance" = "Open Prism Launcher" ]; then
        rm -f "$LOCKFILE"
        prismlauncher &
        exit 0
    fi

    SAVES_DIR="$INSTANCE_DIR/$chosen_instance/minecraft/saves"
    
    if [ ! -d "$SAVES_DIR" ]; then
        rm -f "$LOCKFILE"
        prismlauncher --launch "$chosen_instance" &
        exit 0
    fi

    if [ -n "$prism_icon_path" ]; then
        worlds="Just Launch Instance\0icon\x1f${prism_icon_path}\n"
    else
        worlds="Just Launch Instance\n"
    fi
    
    while IFS= read -r world_dir; do
        [ -z "$world_dir" ] && continue
        world_name=$(basename "$world_dir")
        if [ -n "$grass_icon_path" ]; then
            worlds+="${world_name}\0icon\x1f${grass_icon_path}\n"
        else
            worlds+="${world_name}\n"
        fi
    done < <(find "$SAVES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | cut -d' ' -f2-)
    
    if [ -n "$back_icon_path" ]; then
        worlds+="Back to Modpacks\0icon\x1f${back_icon_path}\n"
    else
        worlds+="Back to Modpacks\n"
    fi

    if [ -n "$exit_icon_path" ]; then
        worlds+="Exit\0icon\x1f${exit_icon_path}"
    else
        worlds+="Exit"
    fi
    
    chosen_world=$(echo -e "$worlds" | rofi -dmenu -p "World: " -theme "$THEME_PATH" -show-icons -markup-rows)
    
    if [ -z "$chosen_world" ] || [ "$chosen_world" = "Exit" ]; then
        rm -f "$LOCKFILE"
        exit 0
    fi
    
    if [ "$chosen_world" = "Back to Modpacks" ]; then
        continue
    fi
    
    [ "$chosen_world" = "Just Launch Instance" ] && chosen_world=""

    rm -f "$LOCKFILE"
    if [ -n "$chosen_world" ]; then
        prismlauncher --launch "$chosen_instance" --world "$chosen_world" &
    else
        prismlauncher --launch "$chosen_instance" &
    fi
    exit 0
done