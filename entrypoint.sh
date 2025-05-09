#!/bin/bash

#Prepare variables
: "${VNC_BUILTIN_WIDTH:=1280}"
: "${VNC_BUILTIN_HEIGHT:=720}"
: "${VNC_BUILTIN_PIXELDEPTH:=24}"
: "${VNC_BUILTIN_DISABLED:=false}"

if [ "${VNC_BUILTIN_DISABLED}" = true ]; then
    echo "Builtin VNC is disabled. You must ensure the DISPLAY variable is set and the target display is accessible"
    echo "Using display ${DISPLAY}"
else
    echo "Builtin VNC is enabled. The DISPLAY variable will be ignored and overwritten"
    export DISPLAY=":10"

    #Launch the virtual framebuffer and wait for it to become ready
    echo "Using display ${DISPLAY} with size of ${VNC_BUILTIN_WIDTH}x${VNC_BUILTIN_HEIGHT} with pixel depth ${VNC_BUILTIN_PIXELDEPTH}"
    echo "Xvfb ${DISPLAY} -nolisten tcp -screen 0 "${VNC_BUILTIN_WIDTH}x${VNC_BUILTIN_HEIGHT}x${VNC_BUILTIN_PIXELDEPTH}" "
    Xvfb ${DISPLAY} -nolisten tcp -screen 0 "${VNC_BUILTIN_WIDTH}x${VNC_BUILTIN_HEIGHT}x${VNC_BUILTIN_PIXELDEPTH}" &
fi

#Wait for the display to become ready
while true
do
    if xdpyinfo -display "${DISPLAY}" > /dev/null 2>/dev/null; then
        echo "Display ${DISPLAY} is ready!"
        break
    else
        echo "Waiting for display ${DISPLAY} to become ready..."
        sleep 0.25
    fi
done

#Launch the VNC server if enabled
if [ "${VNC_BUILTIN_DISABLED}" != true ]; then
    # Enable copy-paste for VNC
    export XKL_XMODMAP_DISABLE=1
    autocutsel -fork -s PRIMARY &
    
    x11vnc -bg -forever -nopw -display ${DISPLAY} &
fi

#Launch OpenBox
openbox --sm-disable &

#Launch WinBox
while true
do
    /WinBox
    sleep 1
done
