#!/bin/bash

LOCKFILE="/tmp/modpack_rofi.lock"

if [ -f "$LOCKFILE" ]; then
    pkill -f "rofi.*sidebar-v2-custom.rasi"
    rm -f "$LOCKFILE"
    exit 0
fi

touch "$LOCKFILE"
trap "rm -f '$LOCKFILE'" EXIT

INSTANCE_DIR="/opt/PrismLauncher/instances"
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

steam_icon_path="${HOME}/.local/modIcons/steam.png"
if [ ! -f "$steam_icon_path" ]; then
    for size in 48x48 64x64 128x128 256x256 scalable; do
        for ext in png svg; do
            candidate="/usr/share/icons/hicolor/${size}/apps/steam.${ext}"
            if [ -f "$candidate" ]; then
                steam_icon_path="$candidate"
                break 2
            fi
        done
    done
fi
[ ! -f "$steam_icon_path" ] && [ -f "/usr/share/pixmaps/steam.png" ] && steam_icon_path="/usr/share/pixmaps/steam.png"
[ ! -f "$steam_icon_path" ] && steam_icon_path=$(find /usr/share/icons/ -name "*steam*" 2>/dev/null | head -n 1)
[ ! -f "$steam_icon_path" ] && steam_icon_path="$prism_icon_path"

exit_icon_path="${HOME}/.local/modIcons/exit.png"
[ ! -f "$exit_icon_path" ] && exit_icon_path="$prism_icon_path"

back_icon_path="${HOME}/.local/modIcons/back.png"
[ ! -f "$back_icon_path" ] && back_icon_path="$prism_icon_path"

grass_icon_path="${HOME}/.local/share/PrismLauncher/icons/grass.png"
[ ! -f "$grass_icon_path" ] && grass_icon_path="$prism_icon_path"

steam_apps_dir=""
for p in "${HOME}/.local/share/Steam" "${HOME}/.steam/steam"; do
    if [ -d "$p/steamapps" ]; then
        steam_apps_dir="$p/steamapps"
        break
    fi
done

while true; do
    main_menu=""
    [ -n "$prism_icon_path" ] && main_menu+="Minecraft (Prism Launcher)\0icon\x1f${prism_icon_path}\n" || main_menu+="Minecraft (Prism Launcher)\n"
    [ -n "$steam_icon_path" ] && main_menu+="Steam Games\0icon\x1f${steam_icon_path}\n" || main_menu+="Steam Games\n"
    [ -n "$exit_icon_path" ] && main_menu+="Exit\0icon\x1f${exit_icon_path}" || main_menu+="Exit"

    chosen_category=$(echo -en "$main_menu" | rofi -dmenu -p "Launcher: " -theme "$THEME_PATH" -show-icons -markup-rows)

    if [ -z "$chosen_category" ] || [ "$chosen_category" = "Exit" ]; then
        rm -f "$LOCKFILE"
        exit 0
    fi

    if [ "$chosen_category" = "Minecraft (Prism Launcher)" ]; then
        while true; do
            instances=""
            [ -n "$prism_icon_path" ] && instances+="Open Prism Launcher\0icon\x1f${prism_icon_path}\n" || instances+="Open Prism Launcher\n"
            
            while IFS= read -r dir; do
                [ -z "$dir" ] && continue
                dir_name=$(basename "$dir")
                icon_path=""
                for ext in png svg ico webp; do
                    [ -f "$dir/icon.$ext" ] && icon_path="$dir/icon.$ext" && break
                done
                [ -n "$icon_path" ] && instances+="${dir_name}\0icon\x1f${icon_path}\n" || instances+="${dir_name}\n"
            done < <(find "$INSTANCE_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | cut -d' ' -f2-)

            [ -n "$back_icon_path" ] && instances+="Back to Main Menu\0icon\x1f${back_icon_path}\n" || instances+="Back to Main Menu\n"
            [ -n "$exit_icon_path" ] && instances+="Exit\0icon\x1f${exit_icon_path}" || instances+="Exit"

            chosen_instance=$(echo -en "$instances" | rofi -dmenu -p "Modpack: " -theme "$THEME_PATH" -show-icons -markup-rows)

            [ -z "$chosen_instance" ] || [ "$chosen_instance" = "Exit" ] && { rm -f "$LOCKFILE"; exit 0; }
            [ "$chosen_instance" = "Back to Main Menu" ] && break

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

            while true; do
                [ -n "$prism_icon_path" ] && worlds="Just Launch Instance\0icon\x1f${prism_icon_path}\n" || worlds="Just Launch Instance\n"
                while IFS= read -r world_dir; do
                    [ -z "$world_dir" ] && continue
                    world_name=$(basename "$world_dir")
                    [ -n "$grass_icon_path" ] && worlds+="${world_name}\0icon\x1f${grass_icon_path}\n" || worlds+="${world_name}\n"
                done < <(find "$SAVES_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | cut -d' ' -f2-)
                
                [ -n "$back_icon_path" ] && worlds+="Back to Modpacks\0icon\x1f${back_icon_path}\n" || worlds+="Back to Modpacks\n"
                [ -n "$exit_icon_path" ] && worlds+="Exit\0icon\x1f${exit_icon_path}" || worlds+="Exit"
                
                chosen_world=$(echo -e "$worlds" | rofi -dmenu -p "World: " -theme "$THEME_PATH" -show-icons -markup-rows)
                
                [ -z "$chosen_world" ] || [ "$chosen_world" = "Exit" ] && { rm -f "$LOCKFILE"; exit 0; }
                [ "$chosen_world" = "Back to Modpacks" ] && break
                
                [ "$chosen_world" = "Just Launch Instance" ] && chosen_world=""

                rm -f "$LOCKFILE"
                if [ -n "$chosen_world" ]; then
                    prismlauncher --launch "$chosen_instance" --world "$chosen_world" &
                else
                    prismlauncher --launch "$chosen_instance" &
                fi
                exit 0
            done
        done

    elif [ "$chosen_category" = "Steam Games" ]; then
        steam_list=""
        if [ -n "$steam_apps_dir" ] && [ -d "$steam_apps_dir" ]; then
            while IFS= read -r acf; do
                [ -f "$acf" ] || continue
                name=$(grep -oP '"name"\s+"\K[^"]+' "$acf" 2>/dev/null)
                appid=$(grep -oP '"appid"\s+"\K\d+' "$acf" 2>/dev/null)
                
                if [ -n "$name" ] && [[ ! "$name" =~ "Steam Linux Runtime" ]] && [[ ! "$name" =~ "Proton" ]] && [[ ! "$name" =~ "Steamworks" ]]; then
                    game_icon="$steam_icon_path"
                    if [ -n "$appid" ]; then
                        found_icon=$(find "${HOME}/.local/share/icons/" -name "steam_icon_${appid}.png" 2>/dev/null | head -n 1)
                        [ -n "$found_icon" ] && game_icon="$found_icon"
                    fi
                    steam_list+="${name}\0icon\x1f${game_icon}\n"
                fi
            done < <(find "$steam_apps_dir" -maxdepth 1 -name "appmanifest_*.acf" 2>/dev/null | sort)
        fi

        [ -n "$back_icon_path" ] && steam_list+="Back to Main Menu\0icon\x1f${back_icon_path}\n" || steam_list+="Back to Main Menu\n"
        [ -n "$exit_icon_path" ] && steam_list+="Exit\0icon\x1f${exit_icon_path}" || steam_list+="Exit"

        chosen_steam_game=$(echo -en "$steam_list" | rofi -dmenu -p "Steam Game: " -theme "$THEME_PATH" -show-icons -markup-rows)

        [ -z "$chosen_steam_game" ] || [ "$chosen_steam_game" = "Exit" ] && { rm -f "$LOCKFILE"; exit 0; }
        [ "$chosen_steam_game" = "Back to Main Menu" ] && continue

        target_appid=""
        if [ -n "$steam_apps_dir" ]; then
            for acf in "$steam_apps_dir"/appmanifest_*.acf; do
                [ -f "$acf" ] || continue
                name=$(grep -oP '"name"\s+"\K[^"]+' "$acf" 2>/dev/null)
                if [ "$name" = "$chosen_steam_game" ]; then
                    target_appid=$(grep -oP '"appid"\s+"\K\d+' "$acf" 2>/dev/null)
                    break
                fi
            done
        fi

        rm -f "$LOCKFILE"
        if [ -n "$target_appid" ]; then
            steam steam://rungameid/"$target_appid" &
        else
            steam &
        fi
        exit 0
    fi
done
