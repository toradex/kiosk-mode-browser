# kiosk-mode-browser

Container that can be used to run a browser in kiosk-mode, allowing implementation of web-based UIs.

This container should be used together with the torizon/arm32v7-debian-weston:buster container to provide a kiosk-mode user interface with a browser that opens an 
URL passed as a parameter, does not show error messages/popups and does not allow the user to navigate to different websites.

Current implementation is based on chromium (using ozone/wayland rendering backend).

## Usage

You should start the wayland server container first (torizon/arm32v7-debian-weston:buster) and the container providing the local UI, if required.
When you start the kiosk container you need to provide it access to the /tmp folder (used for wayland and X11 sockets) and provide the URL you want to open as command line parameter.

```bash
$> docker run -v /tmp:/tmp torizon/arm32v7-debian-kiosk-mode-browser http://www.toradex.com
```

## Docker Compose

Docker compose can be used to start multiple containers at the same time, providing shared data volumes, mount points, resource usage limitations etc.
If you want to use the kiosk-mode-browser container in this way it's a good idea to make it dependent from the wayland server container and the container providing the data that should be displayed by the UI.

This small sample docker-compose.yaml file shows how to do this with portainer (used to monitor docker itself).

```yaml
version: "3.2"
services:
  weston:
    image: torizon/arm32v7-debian-weston:latest
    privileged: true
    volumes:
      - type: bind
        source: /tmp
        target: /tmp

  portainer:
    image: portainer/portainer
    command: -H unix:///var/run/docker.sock
    ports:
      - 9000:9000
    volumes:
      - type: volume
        source: portainer_data
        target: /data
      - type: bind
        source: /var/run/docker.sock
        target: /var/run/docker.sock

  kiosk:
    image: torizon/arm32v7-debian-kiosk-mode-browser:latest
    command: http://portainer:9000
    volumes:
      - type: bind
        source: /tmp
        target: /tmp
      - type: bind
        source: /var/run/dbus
        target: /var/run/dbus
      - type: bind
        source: /dev/dri
        target: /dev/dri
    depends_on:
      - portainer
      - weston

volumes:
  portainer_data:
```