#!/bin/sh

# default url
url="www.toradex.com"

# default parms for kiosk mode
chromium_parms_base="--test-type --allow-insecure-localhost --disable-notifications --check-for-update-interval=315360000 "
chromium_parms="--kiosk "
# Additional params should be stacked chromium_parms_extended="$chromium_params_extended ..."
chromium_parms_extended=""

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
    url=$1
fi

exec chromium $chromium_parms_base $chromium_parms_extended $chromium_parms$url
