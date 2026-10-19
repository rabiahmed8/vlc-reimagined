# Autonomous Context Brief — VLC Reimagined (WSL Native Session)

Copy and paste the entire block below into your new Antigravity session running directly inside WSL:

```markdown
# VLC Reimagined — Autonomous Development & Redesign Execution

You are the autonomous software engineering agent continuing development of the open-source VLC redesign project `vlc-reimagined`, based directly on Juxtopposed's VLC redesign concept (Figma Community file + YouTube walkthrough).

---

## 1. Project Objective & Core Constraints
- **Goal:** Modernize native VLC media player (Qt 6 / C++ / QML) to match the Juxtopposed redesign design language while preserving 100% of VLC's native playback engine, codecs, subtitle handling, audio filters, shortcuts, and architecture.
- **Strict Constraints:**
  - This is NOT Electron, a web imitation, or a mockup. All controls must drive real VLC backend APIs.
  - Do NOT reset, wipe (`git clean -fdx`), or re-clone the repository.
  - Target deliverable: Windows x64 binaries built via cross-compilation in WSL2.
  - Autonomous operation: Do not ask for routine confirmation on terminal commands. Execute changes, build, and verify.

---

## 2. Environment & Key Paths (WSL Ubuntu 24.04)
- **Repository Root:** `/home/rabi/src/vlc-reimagined`
- **Git Branch:** `redesign-ui` (tracking `origin/redesign-ui`)
- **Incremental Build Script:** `/home/rabi/rebuild.sh`
  - Recompiles via `ninja` in `/home/rabi/src/vlc-reimagined/build/win64-meson`
  - Runs `patch-qt-link.sh` to ensure static Qt6 dependencies link cleanly
  - Automatically bundles MinGW runtime DLLs (`libwinpthread-1.dll`, `libssp-0.dll`, etc.)
  - Mirrors output directly to the Windows host at `C:\Users\ahmed\VLC-Reimagined\vlc-win64\` (or `/mnt/c/Users/ahmed/VLC-Reimagined/vlc-win64/`)
  - Takes ~15–25 seconds for incremental builds.
- **Figma Design References & Assets on Disk:**
  - Design screenshots & phases: `/home/rabi/ref/olmo/design/` (e.g. `phase-1` through `phase-7`)
  - Extracted Figma icons: `/home/rabi/ref/olmo/design/figma-icons/`
  - Redesign palette tokens: `/home/rabi/ref/olmo/design/palette/`
  - Community reference implementation: `/home/rabi/ref/Juxtopposed-VLC-Rebuild/`

---

## 3. Work Completed So Far
1. **Design Tokens & Icons:**
   - Inter typography loaded in `modules/gui/qt/pixmaps/fonts/`.
   - Custom `VLCIcons.ttf` and `VLCIcons.json` with 53+ redesign glyphs.
   - Dark theme palette in `modules/gui/qt/style/systempalette.cpp` (`#1B1B1B` chrome, `#161616` cards, `#D37918` orange accent) and `VLCStyle.qml`.
2. **Window Stage & Title Bar:**
   - Client-Side Decoration (CSD) title bar (`modules/gui/qt/maininterface/qml/LocalTopbar.qml` & `TopBar.qml`) with orange cone, CSD window control buttons, menu button, and breadcrumbs.
   - Inset rounded stage (`VLCStyle.juxtStage_inset`).
3. **Player Stage & Controls:**
   - Pill-shaped play button (`PlayButton.qml`).
   - Inline seek bar with orange fill track and handle (`SliderBar.qml`).
   - Cone-gradient volume slider (`VolumeWidget.qml`).
   - Dedicated Audio Track and Subtitle selectors on the control bar.
   - Floating Mini Player card (`MiniPlayerCard.qml`) and Slide-out icon rail (`SidePanelRail.qml`).
   - Subtitle Loader modal dialog (`SubtitleLoader.qml`) wired to `Player.associateSubtitleFile`.
4. **Settings & Secondary Dialogs:**
   - Modernized Settings window (`preferences.cpp`, `simple_preferences.cpp`) with Juxtopposed category sidebar and cards.
   - Unified native Qt widget theming: `QVLCTools::applyJuxtopposedTheme` in `qvlcframe.hpp`/`cpp` automatically styles Media Information (Ctrl+I), Bookmarks (Ctrl+B), Messages (Ctrl+M), Go to Time (Ctrl+T), Help/About, and Adjustments (Ctrl+E).
5. **Play Queue Experience:**
   - Compact queue mode enabled via `juxtStyle: true` in `PlaylistPane.qml`.
   - Hover remove button in `PlaylistDelegate.qml` and `+ Add Media` button in empty state.
6. **Bug Fixes:**
   - Fixed `-1 ms` unindexed media duration bug in `vlctick.cpp`, `VideoGridItem.qml`, and `MediaView.qml`.

---

## 4. Pending Redesign Areas (Next Milestones)
Study the Figma screens in `/home/rabi/ref/olmo/design/` and systematically implement the remaining redesign views:

1. **Media Library & Video View (Phase 1 / Phase 2 Figma):**
   - Video and Music grid views (`modules/gui/qt/medialibrary/qml/VideoAll.qml`, `VideoGridItem.qml`, `MediaView.qml`).
   - Refine grid card proportions, hover overlay cards, play overlay buttons, and badges to match Figma.
   - Modernize the View toggle pills (Grid vs List view), Search bar, and Sort selector dropdowns.
2. **Music & Audio Library View:**
   - Modernize Album cards, Artist views, and Track list table styling (`MusicTrackListDisplay.qml`, `MusicAlbums.qml`) to match the Juxtopposed audio aesthetic.
3. **Player OSD & Fullscreen Experience:**
   - Ensure fullscreen HUD overlay smooth fade-in/fade-out, time tooltips on seek bar scrubbing, and chapter indicators.
4. **Context Menus:**
   - Restyle QML context menus (`modules/gui/qt/menus/qml/`) with rounded cards, dark background (`#1B1B1B`), subtle border (`#282828`), and orange highlight hover state.
5. **Drag-and-Drop & Browse Enhancements:**
   - Further polish dragging local videos from the Media Library into the Play Queue and Playlists.

---

## 5. Development Workflow Rules
- Whenever adding new QML files, declare them in both `modules/gui/qt/meson.build` and `modules/gui/qt/Makefile.am`.
- Run incremental builds using:
  ```bash
  bash /home/rabi/rebuild.sh
  ```
- Check git changes using:
  ```bash
  git status --short modules/gui/qt
  ```
- Test and verify builds after each visual change.
```
