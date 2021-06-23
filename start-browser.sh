#!/bin/sh

# default URL
KIOSK_URL="www.toradex.com"

# LAUNCHER
if [ -z "$KIOSK_LAUNCHER" ]; then
    KIOSK_LAUNCHER="chromium"
fi

start_chromium() {
    KIOSK_ENV="LIBGL_ALWAYS_SOFTWARE=1 $KIOSK_ENV"

    # default parms for kiosk mode
    chromium_parms_base="--test-type --allow-insecure-localhost --disable-notifications --check-for-update-interval=315360000 --disable-gpu "
    chromium_parms="--kiosk "

    # Additional params should be stacked chromium_parms_extended="$chromium_parms_extended ..."
    chromium_parms_extended=""

    # FIXME: TOR-1426: work around seccomp-bpf failures in chromium.
    chromium_parms_extended="$chromium_parms_extended --disable-seccomp-filter-sandbox"

    for arg in "$@"
    do
        case $arg in
        --window-mode)
            chromium_parms="--start-maximized --app="
            shift
            ;;
        --browser-mode)
            chromium_parms="--start-maximized "
            shift
            ;;
        --virtual-keyboard)
            # Load the virtual keyboard
            chromium_parms_extended="$chromium_parms_extended --load-extension=/chrome-extensions/chrome-virtual-keyboard"
            shift
            ;;
        esac
    done

    if [ ! -z "$1" ]; then
        KIOSK_URL=$1
    fi

    eval $KIOSK_ENV exec chromium $chromium_parms_base $chromium_parms_extended $KIOSK_ARGS $chromium_parms$KIOSK_URL
}

start_cog() {
    KIOSK_ENV="COG_PLATFORM_FDO_VIEW_FULLSCREEN=1 $KIOSK_ENV"
    KIOSK_ARGS="-P fdo $KIOSK_ARGS"

    if [ ! -z "$1" ]; then
        KIOSK_URL=$1
    fi

    eval $KIOSK_ENV exec cog $KIOSK_ARGS $KIOSK_URL
}

case "$KIOSK_LAUNCHER" in
    cog)
        start_cog $@
        ;;

    chromium)
        start_chromium $@
        ;;

    *)
        echo "Launcher $KIOSK_LAUNCHER is invalid!"
        exit 1
esac
