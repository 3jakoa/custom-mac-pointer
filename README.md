# Custom Mac Pointer

A native macOS prototype for running a custom PNG pointer overlay.

macOS does not provide a public user setting or stable API for replacing the built-in system cursor artwork globally. This app uses a reversible overlay approach: when enabled, it hides the default cursor with CoreGraphics and draws a transparent always-on-top AppKit panel at the current mouse location.

## Features

- Import PNG cursor artwork.
- Preview the pointer on a clean white background.
- Adjust pointer size.
- Start and stop a system-wide pointer overlay.

## Build

```sh
swift build
```

## Package A Runnable App

```sh
sh scripts/package_app.sh
```

The packaged app is written to:

```text
build/Custom Mac Pointer.app
```

## Run From Source

```sh
swift run
```

If the pointer overlay is running, use the **Stop Pointer** button before quitting. The app also restores the system cursor during normal termination.
