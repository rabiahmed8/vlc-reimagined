<p align="center">
  <img src="share/icons/vlc-reimagined.png" width="120" alt="VLC Reimagined icon">
</p>

<h1 align="center">VLC Reimagined</h1>

<p align="center">
  <strong>The engine you trust, in an interface that belongs in 2026.</strong><br>
  An independent, open-source fork of VLC media player for Windows.
</p>

<p align="center">
  <a href="https://vlc-reimagined.vercel.app">Website</a> ·
  <a href="../../releases/latest">Download</a> ·
  <a href="#building-from-source">Build</a> ·
  <a href="#contributing">Contribute</a> ·
  <a href="extras/package/win32/README-updates.md">Release guide</a>
</p>

---

## What is VLC Reimagined?

VLC Reimagined is a fork of [VLC media player](https://www.videolan.org/vlc/)
that keeps what makes VLC VLC — the playback engine, codec support, streaming
stack and libvlc — and rebuilds the desktop interface around it.

It plays the same files, discs and streams as VLC 4 and installs side by side
with the official player, but looks and feels like a modern desktop
application: dark by default, quiet, fast and focused on the media instead of
the chrome.

The point is to keep the original source, not to rewrite a player: everything
below the interface is upstream VLC, and the interface is built on top of it.

## The idea

Designer **Juxtopposed** published
[*I Redesigned VLC After 25 Years*](https://www.youtube.com/watch?v=ERFeOgqk324)
on YouTube and released the design as a public
[Figma file](https://www.figma.com/community/file/1691465999134370980/vlc-redesign).
It imagined what VLC could look like today.

This project turns that idea into a real application. Instead of building
another mockup or a skin on top of the old interface, it forks VLC 4 and
implements the redesign directly in VLC's own Qt 6 / QML interface: playback,
codecs, subtitles and network streams stay exactly as solid as upstream VLC.

VLC Reimagined is independent. It is not affiliated with, endorsed or
sponsored by VideoLAN or by Juxtopposed.

## Features

**Player**

- Frameless player with a minimal top bar and redesigned menus.
- Controls that fade out in fullscreen and in the mini player.
- Queue panel with per-item move up/down buttons — no drag and drop needed.
- Audio and subtitle track panels, plus a subtitle sync timeline.
- Video adjustments and a full equalizer.
- Keyboard shortcut reference from the main menu and the right-click menu.

**Media library**

- Home, Videos, Music, Playlists, Folders, Network, Streams and Recent views.
- Search, thumbnails, album art and folder browsing.
- Per-file audio and subtitle pairing that is remembered the next time the
  same media is opened.

**Application**

- Dark, light or system theme, custom accent color and interface scaling.
- First-run onboarding and a redesigned settings window.
- Portable mode: put an empty `portable` folder next to `vlc.exe` and settings,
  library and cache stay inside that folder.
- Side-by-side installation with official VLC: own program folder, config
  directory (`%APPDATA%\vlc-reimagined`), registry keys, ProgIDs and autoplay
  handlers.
- Built-in updater: checks a manifest once a day or on demand from the menu,
  downloads the new setup and starts it from inside the app.
- English UI in release builds. The sources are translatable (`qsTr`) but no
  translation catalogues are bundled yet.

## Download

Release builds are published on the
[releases page](../../releases/latest) and on the
[project website](https://vlc-reimagined.vercel.app).

- **Installer** — `VLC-Reimagined-1.0.0-win64-setup.exe` (57 MB). Installs for
  all users, adds the Start-menu and desktop shortcuts, registers media
  associations and the updater. Recommended.
- **Portable** — `VLC-Reimagined-1.0.0-win64-portable.zip` (88 MB). Extract
  and run `VLC-Reimagined-1.0.0-win64\vlc.exe`; everything stays in the folder.

**Requirements:** Windows 10 (1809 or later) or Windows 11, 64-bit. This
project currently ships Windows x64 builds only.

Versions are the project's own: the first public release is **1.0.0**, later
releases follow `MAJOR.MINOR.PATCH`. The VLC 4 engine underneath has its own
internal version and ABI, which are not the app version.

The binaries are not code-signed yet, so Windows SmartScreen may show
*"Windows protected your PC"*: choose **More info → Run anyway**.

## Updating

Release builds check for a new version once a day when
**Settings → General → "Check for updates automatically"** is enabled (the
default), and on demand through **main menu (…) → Check for Updates**.

When a release is available the app shows its notes, downloads the installer
and asks to close the player before starting it. Settings, library and
playlists are preserved.

Maintainers: the manifest format, hosting and the release checklist are in
[`extras/package/win32/README-updates.md`](extras/package/win32/README-updates.md).

## Building from source

The Windows release is cross-compiled from Linux or WSL2. The upstream
build helper takes care of the contrib libraries (Qt, FFmpeg, codecs, …).

Prerequisites and the full package list: [`doc/BUILD-win32.md`](doc/BUILD-win32.md).
The released builds use Ubuntu 24.04 (WSL2), mingw-w64 GCC and Qt 6.8;
expect at least 20 GB of disk and a long first build.

```sh
# 1. Build the contribs and VLC in release mode, using prebuilt contribs
extras/package/win32/build.sh -a x86_64 -r -p

# 2. Produce the branded portable ZIP and the NSIS setup
INSTALL_DIR="$PWD/win64-meson/vlc-win64" \
  extras/package/win32/package-redesign.sh

# artifacts: build/package/
```

`build.sh` installs the runtime tree in `win64-meson/vlc-win64`.
`package-redesign.sh` accepts `VERSION`, `PRODUCT_NAME`, `BUILD_DIR`,
`INSTALL_DIR` and `WORK_DIR` (see its `--help`); if your install tree already
ends in `vlc-win64`, `INSTALL_DIR` can be omitted.

Day-to-day development:

```sh
meson compile -C win64-meson
win64-meson/vlc-win64/vlc.exe
```

The published binaries use NLS disabled (English-only UI) and the updater
enabled; the packaging script works with either configuration. The setup is
built by this repository's script instead of the upstream NSIS target.

## Project layout

```
modules/gui/qt/redesign/   the redesigned Qt/QML interface (R*.qml)
modules/gui/qt/            upstream Qt interface, dialogs and settings
src/misc/update.c          update manifest fetch and installer download
src/win32/dirs.c           config directory and portable mode
share/icons/               application icon (.ico/.png)
extras/package/win32/      Windows packaging and update documentation
```

## Contributing

Bug reports, fixes and interface polish are welcome. The project has a clear
visual direction, so please open an issue before starting on a large feature
or a redesign of an existing screen.

- Branch from `redesign-ui` (the active branch) and keep pull requests
  focused on one change.
- Match the surrounding code: C follows VLC's style, commits use prefixes such
  as `qt:`, `video_filter:` or `package:`.
- In the redesigned interface, reuse the `R*` components and the `Theme`
  values (`Theme.dp()`, palette roles) instead of hardcoded sizes and colors,
  and wrap user-facing strings in `qsTr()`.
- Per-user UI state belongs in `MainCtx.settingValue("Redesign/...")`, not in
  ad-hoc files.
- Keep engine changes separate from interface work and explain why they are
  needed.
- Test on Windows 10/11. Running under Wine or offscreen only catches QML load
  errors. For UI pull requests, include a screenshot or a short clip and list
  what you tested.
- No telemetry, ads or network requests other than the update check.

## Forking this project

You are free to fork it under the GPL. If you publish your own build, please
make it visibly your own:

- Change the product name and icon (`share/icons/`, the `*_win32_rc.rc.in`
  files, `modules/module.rc.in`) and the display strings in
  `modules/gui/qt/qt.cpp`.
- Use a different configuration directory in `src/win32/dirs.c` so the two
  applications do not share settings.
- Pick your own installer name, install directory, registry keys and ProgIDs
  in `extras/package/win32/package-redesign.sh` so both can coexist.
- Point `VLC_REIMAGINED_UPDATE_URL` in `src/misc/update.c` at your own update
  manifest.
- Keep the GPL notices and make your source available.

"VLC" and the cone are VideoLAN trademarks. If you publish a modified build,
make it clear that it is a fork and not the official player; using your own
name and icon avoids any ambiguity.

## Credits

- **VideoLAN and the VLC contributors** — the engine, libvlc, the Qt interface
  and more than two decades of work this fork is built on.
- **Juxtopposed** — the redesign concept, the video and the public Figma file
  that inspired this project.
- **The Qt project, FFmpeg** and all the libraries bundled through VLC's
  contrib system.
- Everyone who tests builds, reports issues and sends fixes.

## License and trademarks

VLC Reimagined is distributed under the **GNU General Public License v2.0 or
later**, like VLC itself; libvlc remains LGPLv2.1+. See [`COPYING`](COPYING).

If you distribute binaries of this fork, you must also make the corresponding
source available. This repository is that source.

"VLC", the traffic-cone logo and "VideoLAN" are trademarks of VideoLAN. This
is an independent fork, not affiliated with, endorsed or sponsored by
VideoLAN. The name is used to make the origin of the code clear. The redesign
concept is credited to Juxtopposed; the interface implementation in this
repository is original code.
