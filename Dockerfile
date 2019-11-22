ARG BASE_IMAGE=torizon/arm32v7-debian-wayland-base

FROM $BASE_IMAGE:latest

RUN cat /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends chromium chromium-sandbox && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY start-browser.sh /usr/bin/start-browser

USER torizon

ENV LIBGL_ALWAYS_SOFTWARE=1

ENTRYPOINT ["/usr/bin/start-browser"]
CMD ["http://www.toradex.com"]
