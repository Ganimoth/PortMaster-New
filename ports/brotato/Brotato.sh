#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/brotato/
CONFDIR="$GAMEDIR/conf/"

if [[ "$CFW_NAME" = "ROCKNIX" ]]; then
    if ! glxinfo | grep "OpenGL version string"; then
    pm_message "This Port does not support the libMali graphics driver. Switch to Panfrost to continue."
    sleep 5
    exit 1
    fi
fi

cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Ensure the conf directory exists
mkdir -p "$GAMEDIR/conf"

# Set the XDG environment variables for config & savefiles
export XDG_CONFIG_HOME="$CONFDIR"
export XDG_DATA_HOME="$CONFDIR"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
$ESUDO chmod +x "$GAMEDIR/brotato.aarch64"
$ESUDO chmod +x "$GAMEDIR/hacksdl/hacksdl.aarch64.so"

[ -f "./gamedata/Brotato.pck" ] && mv gamedata/Brotato.pck gamedata/brotato.pck

$GPTOKEYB "brotato.aarch64" -c "./brotato.gptk" &
pm_platform_helper "$GAMEDIR/brotato.aarch64"
LD_PRELOAD=$GAMEDIR/libcrusty.so CRUSTY_BLOCK_INPUT=1 ./brotato.aarch64 $GODOT_OPTS --main-pack "gamedata/brotato.pck"

pm_finish