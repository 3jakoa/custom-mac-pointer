# Custom Mac Pointer: LLM Project Context

## Current Project

This is a native macOS Swift/AppKit app that lets a user use a PNG image as a custom mouse pointer overlay.

The app does not replace macOS system cursor assets directly. macOS does not expose a stable public setting/API for globally replacing the built-in cursor artwork. Instead, the app uses a reversible overlay approach:

- hide the normal cursor with CoreGraphics
- show a transparent always-on-top AppKit panel
- draw the selected PNG at the current mouse location
- restore the normal cursor when the overlay stops or the app terminates

## Current User Experience

The app is intentionally simple:

- small window
- `Import PNG` button
- clean white preview area
- size slider
- `Start Pointer` button
- `Stop Pointer` button

The current implementation requires the user to import a PNG before starting the pointer overlay.

## Product Direction

The next desired feature is a built-in library of funny meme PNG pointers.

The user does **not** want a normal cursor preset library with arrows, hands, rings, or generic pointer shapes. They want culturally recognizable, funny meme-style PNGs that can be selected quickly and used as the pointer.

The expected UX should stay simple:

- keep `Import PNG`
- add a preset meme picker
- selecting a preset updates the preview immediately
- size slider applies to both imported PNGs and presets
- start/stop behavior remains unchanged

A good UI direction is a compact preset grid above or near the import button. Avoid turning the app into a complex editor.

## Asset Guidance

Do not bundle random copyrighted meme images from the web unless the user provides them or the license is clear.

Acceptable sources:

- PNGs the user drops into the project
- original/generated meme-inspired artwork that does not copy a protected image directly
- permissively licensed assets with attribution tracked in the repo

If the user provides image files, place them under a repo-tracked resource folder such as:

```text
Resources/Presets/
```

Suggested metadata file:

```text
Resources/Presets/presets.json
```

Example metadata shape:

```json
[
  {
    "id": "example-meme",
    "name": "Example Meme",
    "filename": "example-meme.png",
    "source": "user-provided"
  }
]
```

## Implementation Notes

The app currently uses Swift Package Manager and AppKit.

Important files:

- `Sources/CustomMacPointer/AppState.swift`: cursor state, currently image + size
- `Sources/CustomMacPointer/MainViewController.swift`: compact UI, import button, size slider, start/stop
- `Sources/CustomMacPointer/CursorImageFactory.swift`: renders the selected image at the chosen size
- `Sources/CustomMacPointer/CursorOverlayController.swift`: transparent overlay window and system cursor hide/show
- `Sources/CustomMacPointer/PreviewView.swift`: white preview area
- `Resources/Info.plist`: app bundle metadata
- `scripts/package_app.sh`: creates `build/Custom Mac Pointer.app`

When adding presets:

- add preset image loading from bundled resources
- preserve imported PNG support
- distinguish selection source in state if needed, but keep the public model simple
- keep hotspot centered unless the user explicitly asks for per-preset hotspots
- keep `build/`, `.build/`, and `.DS_Store` ignored

## Build And Verify

Run:

```sh
swift build
```

Package app:

```sh
sh scripts/package_app.sh
```

Run app:

```sh
open "build/Custom Mac Pointer.app"
```

Before committing, verify:

```sh
git status --short
swift build
```
