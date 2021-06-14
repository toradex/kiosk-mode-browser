ARG IMAGE_ARCH=linux/arm
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64

ARG BASE_IMAGE=wayland-base
# For iMX7 use:
# ARG BASE_IMAGE=debian

ARG IMAGE_TAG=2
# For iMX7 use:
# ARG IMAGE_TAG=2-bullseye

# First stage download virtual keyboard
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

# If x11 build (iMX7), use Chromium from Debian feed
RUN test "$BUILD_TYPE" = "x11" && \
        sed -i '/feeds.toradex.com/d' /etc/apt/sources.list || true

# Install Chromium
RUN apt-get -y update && \
    apt-get -o Acquire::Http::Dl-limit=100 install -y --no-install-recommends chromium chromium-sandbox && \
    apt-get clean && apt-get autoremove && \
    update-mime-database /usr/share/mime && \
    rm -rf /var/lib/apt/lists/*

# Install Cog on wayland builds (iMX6/iMX8)
# Cog is installed from the experimental feed to get the latest version that has some fixes
# for iMX based devices. Also, we are currently not installing Cog on x11 builds (iMX7) for
# two main reasons: 1) install fails with a package dependency issue (it seems the reason
# is that Chromium installed from the Debian feed brings some dependencies that conflict
# with Cog), and 2) Cog crashes with SEGFAULT on non-GPU devices.
RUN if [ "$BUILD_TYPE" = "wayland" ]; then \
    echo "deb http://deb.debian.org/debian experimental main" >> /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get -o Acquire::Http::Dl-limit=100 -t experimental install -y --no-install-recommends cog && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/* ; fi

# Copy the virtual keyboard extension from the first stage
COPY --from=0 /extension/chrome-virtual-keyboard-master /chrome-extensions/chrome-virtual-keyboard

COPY start-browser.sh /usr/bin/start-browser

USER torizon

ENV DISPLAY=:0

ENTRYPOINT ["/usr/bin/start-browser"]
CMD ["http://www.toradex.com"]
