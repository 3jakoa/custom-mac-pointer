# Burek Mac Pointer

A native macOS prototype for running a Burek pointer overlay.

macOS does not provide a public user setting or stable API for replacing the built-in system cursor artwork globally. This app uses a reversible overlay approach: when enabled, it hides the default cursor with CoreGraphics and draws a transparent always-on-top AppKit panel at the current mouse location.

## Features

- Load bundled Burek pointer artwork.
- Advance to the next Burek on each mouse click.
- Preview the active Burek pointer.
- Adjust Burek pointer size.
- Start and stop a system-wide Burek pointer overlay.

## Add Bureks

Place Burek image files in:

```text
Sources/CustomMacPointer/Resources/Bureks
```

Supported formats are PNG, JPG, JPEG, HEIC, TIFF, and WEBP. Files are loaded alphabetically.

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
build/Burek Mac Pointer.app
```

## Run From Source

```sh
swift run
```

If the pointer overlay is running, use the **Stop Pointer** button before quitting. The app also restores the system cursor during normal termination.
