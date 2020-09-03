# First stage download virtual keyboard
ARG IMAGE_ARCH=linux/arm
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64
ARG BASE_IMAGE=wayland-base
# For iMX7 use:
# ARG BASE_IMAGE=debian
ARG IMAGE_TAG=1
# For iMX7 use:
# ARG IMAGE_TAG=1-buster
FROM --platform=$IMAGE_ARCH torizon/$BASE_IMAGE:$IMAGE_TAG AS first
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends wget

WORKDIR /extension

# Download the virtual keyboard from gitlab
RUN wget --no-check-certificate https://gitlab.int.toradex.com/rd/torizon-core/chrome-virtual-keyboard/-/archive/master/chrome-virtual-keyboard-master.tar.gz && tar -xf chrome-virtual-keyboard-master.tar.gz

# Second stage build final container
FROM --platform=$IMAGE_ARCH torizon/$BASE_IMAGE:$IMAGE_TAG AS second

# Needs to come after FROM!
ARG BUILD_TYPE=wayland
# For iMX7 use:
# ARG BUILD_TYPE=x11

RUN test "$BUILD_TYPE" = "x11" && \
        sed -i '/feeds.toradex.com/d' /etc/apt/sources.list || true

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends chromium chromium-sandbox && \
    apt-get clean && apt-get autoremove && \
    update-mime-database /usr/share/mime && \
    rm -rf /var/lib/apt/lists/*

# Copy the virtual keyboard extension from the first stage
COPY --from=0 /extension/chrome-virtual-keyboard-master /chrome-extensions/chrome-virtual-keyboard

COPY start-browser.sh /usr/bin/start-browser

USER torizon

ENV LIBGL_ALWAYS_SOFTWARE=1
ENV DISPLAY=:0

ENTRYPOINT ["/usr/bin/start-browser"]
CMD ["http://www.toradex.com"]