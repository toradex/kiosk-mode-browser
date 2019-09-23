FROM torizon/arm32v7-debian-wayland-base:buster

RUN cat /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends chromium chromium-sandbox && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# temporary workaround for an issue in multi-arch package creation
RUN mv /usr/lib/\*/libminigbm.so /usr/lib/arm-linux-gnueabihf/

ENTRYPOINT ["/usr/bin/chromium","--kiosk","--no-sandbox","--test-type"]
CMD ["http://www.toradex.com"]
