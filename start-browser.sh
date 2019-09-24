#!/bin/sh

# default url
url="www.toradex.com"

# default parms for kiosk mode
chromium_parms="--kiosk --no-sandbox --test-type --allow-insecure-localhost --disable-notifications "

for arg in "$@"
do
    case $arg in
    --window-mode)
        chromium_parms="--start-maximized --no-sandbox --test-type --allow-insecure-localhost --app="
        shift
        ;;
    --browser-mode)
        chromium_parms="--start-maximized --no-sandbox --test-type --allow-insecure-localhost "
        shift
    esac
done

if [ ! -z "$1" ]; then
    url=$1
fi

chromium $chromium_parms$url
