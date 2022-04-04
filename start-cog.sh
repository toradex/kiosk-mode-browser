#!/bin/sh

# default URL
URL="www.toradex.com"

    KIOSK_ENV="COG_PLATFORM_FDO_VIEW_FULLSCREEN=1 $KIOSK_ENV"
    KIOSK_ARGS="-P fdo $KIOSK_ARGS"

    if [ ! -z "$1" ]; then
        URL=$1
    fi

    eval $KIOSK_ENV exec cog $KIOSK_ARGS $URL