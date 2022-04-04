#!/bin/sh

# default URL
URL="www.toradex.com"

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
            chromium_parms_extended="$chromium_parms_extended --load-extension=/chrome-extensions/chrome-virtual-keyboard-master"
            shift
            ;;
        esac
    done

    if [ ! -z "$1" ]; then
        URL=$1
    fi

    exec chromium $chromium_parms_base $chromium_parms_extended $chromium_parms$URL

