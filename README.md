# kiosk-mode-browser

Container that can be used to run a browser in kiosk-mode, allowing implementation of web-based UIs.

This container should be used together with the torizon/arm32v7-debian-weston:buster container to provide a kiosk-mode user interface with a browser that opens an 
URL passed as a parameter, does not show error messages/popups and does not allow the user to navigate to different websites.

Current implementation is based on chromium (using ozone/wayland rendering backend).

## Usage

You should start the wayland server container first (torizon/arm32v7-debian-weston:buster) and the container providing the local UI, if required.
When you start the kiosk container you need to provide access to the /tmp folder (used for wayland and X11 sockets), /dev/dri (for buffer sharing/hardware acceleration) and provide the URL you want to open as command line parameter.

```bash
$> docker run -d --rm -v /tmp:/tmp -v /dev/dri:/dev/dri --device-cgroup-rule='c 226:* rmw' \
              torizon/arm32v7-debian-kiosk-mode-browser http://www.toradex.com
```

### Optional command line flags
It's possibile to start chromium in less-secure ways (secure from the point of view of user being able to run other graphical apps etc.) using command line switches.  
- --window-mode : runs the browser inside a maximized window without navigation bar
- --browser-mode : runs the browser in a standard window with navigation bars and all user menus enabled

## Docker Compose

Docker compose can be used to start multiple containers at the same time, providing shared data volumes, mount points, resource usage limitations etc.
If you want to use the kiosk-mode-browser container in this way it's a good idea to make it dependent from the wayland server container and the container providing the data that should be displayed by the UI.

This small sample docker-compose.yaml file shows how to do this with portainer (used to monitor docker itself). To use the device_cgroup_rules configuration option we have to use Compose file version 2.4 currently.

```yaml
version: "2.4"
services:
  weston:
    image: torizon/arm32v7-debian-weston:latest
    # Required to get udev events from host udevd via netlink
    network_mode: host
    volumes:
      - type: bind
        source: /tmp
        target: /tmp
      - type: bind
        source: /dev
        target: /dev
      - type: bind
        source: /run/udev
        target: /run/udev
    cap_add:
      - CAP_SYS_TTY_CONFIG
    # Add device access rights through cgroup...
    device_cgroup_rules:
      # ... for tty0
      - 'c 4:0 rmw'
      # ... for tty7
      - 'c 4:7 rmw'
      # ... for /dev/input devices
      - 'c 13:* rmw'
      # ... for /dev/dri devices
      - 'c 226:* rmw'

  portainer:
    image: portainer/portainer:latest
    # default user/password is admin/toradex2019
    command: -H unix:///var/run/docker.sock --admin-password=$$2y$$05$$wUwPQ6QCd/Y5IB/JLPTYn.RVuyKozg7vlqDCGA6Z7WrL6b5jDLSby
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
    command: --window-mode http://portainer:9000
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
    shm_size: '256mb'
    device_cgroup_rules:
      # ... for /dev/dri devices
      - 'c 226:* rmw'


volumes:
  portainer_data:
```
