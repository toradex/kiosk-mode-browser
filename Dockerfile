FROM torizon/arm32v7-debian-wayland-base:buster

RUN apt-get -y update && apt-get install -y --no-install-recommends\
    apt-utils \
    curl \
    && apt-mark hold dash && apt-get -y upgrade && apt-mark unhold dash \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENV CURL_CA_BUNDLE /etc/ssl/certs/ca-certificates.crt

RUN curl -L https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get -y update && apt-get install -y --no-install-recommends\
    nodejs \
    dbus-x11 \
    libasound2 \
    libcanberra-gtk-module \
    libcurl4 \
    libexif-dev \
    libgconf-2-4 \
    libgtk3.0 \
    libnotify4 \
    libnss3 \
    libxss1 \
    libxtst6 \
    libxcursor1 \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN npm install oak && npm cache clear

ENV npm_config_target=3.1.8 \
    npm_config_runtime=electron \
    npm_config_arch=arm32v7 \
    npm_config_target_arch=arm32v7 \
    npm_config_disturl=https://atom.io/download/electron \
    DEBUG=false \
    NODE_ENV=production \
    ELECTRON_VERSION=3.1.8 \
    DISPLAY=:0 \
    IGNORE_GPU_BLACKLIST=false \
    NODE_TLS_REJECT_UNAUTHORIZED=0 \
    ELECTRON_DISABLE_SECURITY_WARNINGS=true

ENTRYPOINT ["/usr/bin/env","node","/node_modules/.bin/oak"]
CMD ["http://www.toradex.com"]