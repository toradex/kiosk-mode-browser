FROM torizon/arm32v7-debian-wayland-base:buster

RUN cat /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends chromium chromium-sandbox && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# temporary workaround for an issue in multi-arch package creation
RUN mv /usr/lib/\*/libminigbm.so /usr/lib/arm-linux-gnueabihf/

COPY start-browser.sh /usr/bin/start-browser

ENTRYPOINT ["/usr/bin/start-browser"]
CMD ["http://www.toradex.com"]
