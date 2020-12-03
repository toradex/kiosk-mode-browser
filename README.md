Please check our Developer Article [Kiosk Mode Browser with TorizonCore] for more details.

[Kiosk Mode Browser with TorizonCore]: https://developer.toradex.com/knowledge-base/kiosk-mode-browser-with-torizon-core

And, for the impatient, you can see below some details on how to get this sample up and running in a Torizon compatible module.

# kiosk-mode-browser

Container that can be used to run a browser in kiosk-mode, allowing implementation of web-based UIs.

This container should be used together with the torizon/weston container to provide a kiosk-mode user interface with a browser that opens an
URL passed as a parameter, does not show error messages/popups and does not allow the user to navigate to different websites.

Current implementation is based on chromium (using ozone/wayland rendering backend).

## Usage

You should start the wayland server container first (torizon/weston) and the container providing the local UI, if required.
When you start the kiosk container you need to provide access to the /tmp folder (used for wayland and X11 sockets), /dev/dri (for buffer sharing/hardware acceleration) and provide the URL you want to open as command line parameter.

```bash
$> docker run -d --rm -v /tmp:/tmp -v /dev/dri:/dev/dri -v /var/run/dbus:/var/run/dbus \
              --device-cgroup-rule='c 226:* rmw' --shm-size="256m"
              --security-opt="seccomp=unconfined" \
              torizon/arm32v7-debian-kiosk-mode-browser https://www.toradex.com
```

Replace arm32v7 with arm64v8 for the 64-bit variant.

For the X11 build we have to provide shared memory access from the host system:
```bash
$> docker run -d --ipc=host --rm -v /tmp:/tmp -v /dev/dri:/dev/dri -v /var/run/dbus:/var/run/dbus \
              --device-cgroup-rule='c 226:* rmw' --shm-size="256m"
              --security-opt="seccomp=unconfined" \
              torizon/arm32v7-debian-kiosk-mode-browser https://www.toradex.com
```

### Optional command line flags

It's possibile to start chromium in less-secure ways (secure from the point of view of user being able to run other graphical apps etc.) using command line switches.  
- --window-mode : runs the browser inside a maximized window without navigation bar
- --browser-mode : runs the browser in a standard window with navigation bars and all user menus enabled

## Docker Compose

Docker compose can be used to start multiple containers at the same time, providing shared data volumes, mount points, resource usage limitations etc.
If you want to use the kiosk-mode-browser container in this way it's a good idea to make it dependent from the wayland compositor container and the container providing the data that should be displayed by the UI.

You can find example Docker compose files in our sample repository: https://github.com/toradex/torizon-samples/tree/master/debian-container/demonstration

