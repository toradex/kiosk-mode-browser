Please check our Developer Article [Kiosk Mode Browser with TorizonCore] for more details.

[Kiosk Mode Browser with TorizonCore]: https://developer.toradex.com/knowledge-base/kiosk-mode-browser-with-torizon-core

And, for the impatient, you can see below some details on how to get this sample up and running in a Torizon compatible module.

# Technical Details

Torizon provides support for Chromium and Cog.

Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all users to experience the web. In the Chromium container, Chromium uses Ozone/Wayland as a rendering backend and it is not optimized for applications that require hardware acceleration and the GPU.

Cog is a single "window" launcher for the WebKit WPE port. It is small, provides no user interface, and is suitable to be used as a Web application launcher. Cog is able to leverage the GPU for hardware-accelerated applications, which works well on iMX6 and iMX8 based modules. From Cog container with the container tag 2.6 onwards, Cog is supported also on devices that lack a GPU (e.g. iMX7 and iMX6ULL).

## Preparing the environment

You should start the wayland server container first (torizon/weston) and the container providing the local UI, if required.
Learn how to [start a Wayland server container on Debian Containers] for Torizon.

[start a Wayland server container on Debian Containers]: https://developer.toradex.com/knowledge-base/debian-container-for-torizon#Debian_With_Weston_Wayland_Compositor

## Running Chromium

The Chromium container needs visibility to some host resources (for accessing the accelerated graphical environment, buffer sharing, and inter-process communication), and the URL of the web UI as a command-line parameter. It also recognizes some optional command-line flags (explained ahead).
You can run the following command to start the Chromium container on iMX6 devices:

```bash
$> docker run -d --rm -v /tmp:/tmp -v /dev/dri:/dev/dri -v /var/run/dbus:/var/run/dbus \
              --device-cgroup-rule='c 226:* rmw' --shm-size="256m"
              --security-opt="seccomp=unconfined" \
              torizon/chromium:$CT_TAG_CHROMIUM https://www.toradex.com
```

You can run the following command to start the Chromium container on iMX8 devices:

```bash
$> docker run -d --rm --name=chromium \
              -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
              --security-opt seccomp=unconfined --shm-size 256mb \
              torizon/chromium:$CT_TAG_CHROMIUM https://www.toradex.com
```

For the X11 build we have to provide shared memory access from the host system:
```bash
$> docker run -d --ipc=host --rm -v /tmp:/tmp -v /dev/dri:/dev/dri -v /var/run/dbus:/var/run/dbus \
              --device-cgroup-rule='c 226:* rmw' --shm-size="256m"
              --security-opt="seccomp=unconfined" \
              torizon/chromium-x11:$CT_TAG_CHROMIUM_X11 https://www.toradex.com
```

It's possibile to start Chromium in less-secure ways (secure from the point of view of user being able to run other graphical apps etc.) using command line switches.
- --window-mode : runs the browser inside a maximized window without navigation bar
- --browser-mode : runs the browser in a standard window with navigation bars and all user menus enabled

## Running Cog

You can run the following command to start the Cog container on iMX6 and iMX7 devices:

```bash
$> docker run -d --rm --name=cog \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule='c 226:* rmw' \
    torizon/cog:$CT_TAG_COG
```

You can run the following command to start the Cog container on iMX8 devices:

```bash
$> docker run -d --rm --name=cog \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/galcore:/dev/galcore --device-cgroup-rule='c 199:* rmw' \
    torizon/cog:$CT_TAG_COG
```

To change how the output will be configured, the following environment variables can be set:
- COG_PLATFORM_WL_VIEW_FULLSCREEN
- COG_PLATFORM_WL_VIEW_MAXIMIZE
- COG_PLATFORM_WL_VIEW_WIDTH
- COG_PLATFORM_WL_VIEW_HEIGHT

## Docker Compose

Docker compose can be used to start multiple containers at the same time, providing shared data volumes, mount points, resource usage limitations etc.
If you want to use the Chromium or Cog container in this way it's a good idea to make it dependent from the wayland compositor container and the container providing the data that should be displayed by the UI.

You can find example Docker compose files in our sample repository: https://github.com/toradex/torizon-samples/tree/master/debian-container/demonstration

