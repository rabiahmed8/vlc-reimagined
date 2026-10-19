# Juxtopposed VLC redesign - implementation progress

Unofficial community implementation of Juxtopposed's VLC redesign
(Figma Community file + walkthrough video) on top of this fork's VLC 4 Qt/QML
interface. Not affiliated with or endorsed by VideoLAN or Juxtopposed.

## Design references

| Source | Use | Access |
| --- | --- | --- |
| Figma: `5UEUReDQz2dQjwoQDHY5z9` (VLC Redesign - Community) | Source of truth for layout/colour/typography | No authenticated export possible here; see limitation |
| Video: https://www.youtube.com/watch?v=ERFeOgqk324 | Behaviour, transitions, screen order | Frame grabs (`juxt-ref-design/video/`) |
| https://github.com/SpeedyPete25/Juxtopposed-VLC-Rebuild | SVG exports + reference implementation | Cloned to `/home/rabi/ref/Juxtopposed-VLC-Rebuild` |
| https://github.com/Olmo-Gutierrez/VLC-juxtopposed | Design screenshots, icon index, palette, roadmap crops | Cloned to `/home/rabi/ref/olmo` (reference only) |
| https://github.com/Geckostya/vlc-Juxtopposed-redesign (`redesign/stage1`) | Implementation study only | Cloned to `/home/rabi/ref/gecko`; no code imported |

**Figma limitation (honest):** the Community file needs an authenticated Figma
session to export frames. Direct export was not possible from this environment,
so geometry/tokens come from the reference implementation (built against that
file), the published design crops (`design/roadmap/phase-*.png`,
`design/screenshots/*.png`) and video frames - not from invention.

## How the reference was ported (method)

1. Scratch worktree of this repo at the reference's VLC base
   (`1176b56b`, present in our object store) under `/home/rabi/ref/juxt-vlc`.
2. Reference patches applied there **step by step** (`--reject`, resolving
   rejects), never to the user's checkout.
3. Each changed file compared to our `redesign-ui` tree:
   identical-to-base files were copied in full; files with upstream drift
   (`PlaylistPane.qml` +74/-3, `meson.build`, `Makefile.am`) were merged with
   `git apply --3way` or edited by hand so no upstream work was lost.
4. Rebuild + screenshot verification after each step.

## Assets

- 53 Figma SVG exports -> `modules/gui/qt/pixmaps/icons/juxt/` (+`ATTRIBUTION.txt`).
- Redesign icon font `VLCIcons.ttf` / `VLCIcons.json` (glyphs from those SVGs).
- Inter Regular/Medium/SemiBold + OFL -> `pixmaps/fonts/`, loaded in `qt.cpp`
  from `:/fonts/Inter-*.ttf` with a platform-font fallback.
- Gradient volume assets -> `pixmaps/juxt/{volume_track,volume_fill}.svg`.
- Comparison material -> `juxt-ref-design/` in the workspace (not committed).

## Design tokens

| Token | Value | Role |
| --- | --- | --- |
| juxtBgA3 | `#1B1B1B` | title bar, control bar |
| juxtBgA4 | `#191919` | navigation rail |
| juxtBgB1 | `#0E0E0E` | player / library background |
| juxtBgB2 | `#090909` | seek track |
| juxtBgAccent | `#371F06` | played part of seek track |
| juxtBgPill | `#262626` | hovered/selected sidebar item |
| juxtFgA1/A2/A3 | `#969696` `#8F8F8F` `#6B6B6B` | text hierarchy |
| juxtFgB1 | `#161616` | glyph on accent buttons |
| juxtDividerBright/Dim | `#373737` `#222222` | borders / separators |
| orange500 / orange800 | `#D37918` `#E08A2E` | accent / pressed accent |

Metrics (`style/VLCStyle.qml`): title bar 40, control bar 54, control-bar padding
20, play pill 54x28 r6, seek h28 r6 handle 8, time 76, volume 88, stage inset 10,
stage radius 10, plus the side-panel and mini-card metrics.

## Implemented screens

- **Player window**: rounded inset video stage; title bar with cone, overflow
  menu, play-queue toggle, divider, folder breadcrumb, centred title and four
  window buttons (minimise / maximise / **fullscreen** / close).
- **Control bar**: prev, pill play/pause, next, inline seek with orange handle,
  elapsed/duration, gradient cone volume, **audio-track**, subtitles, settings,
  playlist.
- **Music view**: rounded cover card, "title - artist" caption, skip controls in
  the control bar.
- **Mini player card** (floating card in the library while media plays).
- **Play queue restyle**: `PlaylistPane` gained a `juxtStyle` mode (compact
  header with more/pop-out, item count, sort and search) and the
  `SidePanelRail` component exists in the tree.
- **Library chrome** restyled through the shared palette.

## Crash at end of playback - root cause and fix (toolchain ABI mismatch)

Symptom: playback died with `0xC0000005` (faulting module `ntdll.dll`) a couple of
seconds after the media reached its end - i.e. when the player/audio threads are
torn down.

It reproduced on the **pre-redesign build of this same repo**, which ruled out the
UI work. The cause was the build configuration:

- the prebuilt contrib from VideoLAN CI (Qt, x264, ...) is compiled with a
  **posix-threaded** mingw-w64 (`libx264.a` references `pthread_create`);
- we were cross-compiling VLC with Ubuntu's default **win32-threaded**
  `x86_64-w64-mingw32-gcc` (`-v` reports `Thread model: win32`).

`libstdc++` is ABI-incompatible between those two threading models
(`std::thread`, `std::mutex`, `std::condition_variable`), so mixing objects from
both corrupts memory when threads are destroyed - exactly at end-of-playback.

Fix: configure with the posix variants
(`x86_64-w64-mingw32-gcc-posix` / `g++-posix` / `gcc-ar-posix` /
`gcc-ranlib-posix`), cross file kept at `/home/rabi/cross/crossfile-posix.meson`
and installed as the default `/home/rabi/cross/crossfile.meson`.

Verification: 80 s of looping playback (the 10 s clip crosses the end-of-stream
path 8 times) with no crash; previously it died after the first end-of-stream.
The `libwinpthread-1.dll` runtime is shipped next to `vlc.exe` by `rebuild.sh`.

No upstream commit change or pull is needed - the checkout was fine.

## Build & run

```sh
wsl -d Ubuntu-24.04 -- bash /home/rabi/rebuild.sh   # ninja + install + mirror to C:
```

Run: `C:\Users\ahmed\VLC-Reimagined\vlc-win64\vlc.exe` (source of truth:
`/home/rabi/src/vlc-reimagined`, tree `build/win64-meson`).

## Verification

- Full plugin relink builds clean; no warnings introduced beyond upstream ones.
- Player launches with a real H.264 clip, plays, seeks, and stays stable
  (60s+ soak) with the current change set.
- Screenshots (`shots/`, workspace): `vlc-final.png` (player, 1280x800),
  `vlc-sidepanel.png` (library chrome: rail + inset content panel),
  `vlc-music.png` (music card), compared against
  `juxt-ref-design/roadmap/phase-2-bottom-bar.png`, `phase-3-top-bar.png`
  and `juxt-ref-design/video/hq2.jpg` (real video frame).
- Regression found and fixed during this round: the build must not mirror while
  VLC is running (locked DLLs); the rebuild script aborts early if it is.

## Remaining work

1. Verify the docked queue panel visually once the window-capture flow can open
   it reliably (Ctrl+L changes the window handle mid-capture).
2. Library page headers (breadcrumbs, item count, search field), sidebar and
   content panel polish.
3. Settings window, onboarding, dialogs, context menus, tracks popup, light theme.
4. Icon optical-size pass and a proper pixel diff against the Figma crops.
5. Verify mini player card behaviour with real playback and PIP compositor.

## Provenance / licensing

Design: Juxtopposed (Figma Community). Icon SVGs and resulting font derive from
that file; Inter is SIL OFL 1.1 (`pixmaps/fonts/Inter-LICENSE.txt`). VLC code and
licence notices untouched; this fork remains GPL-2.0+.

## Screenshot workflow notes

- Capture with --no-media-library: otherwise VLC's resume prompt
  (" restart playback where you left off)

## Screenshot workflow notes

- Capture with `--no-media-library`: otherwise VLC's resume prompt
  ("restart playback where you left off") replaces the title bar and ruins the
  shot. That dialog is itself a design surface still to be restyled.
- Preferred capture command:
  `vlc.exe <clip> --no-qt-video-autoresize --no-media-library --loop`
  then resize to 1280x800 and `PrintWindow(PW_RENDERFULLCONTENT)`.
- Control-bar comparison harness: `shots/compare-controlbar*.png`
  (reference strip scaled to the same width, stacked above the captured bar);
  same for `compare-topbar*.png`.
- Synthetic mouse clicks (SendInput/mouse_event) do not activate the QML
  play-queue toggle, so the docked side panel still needs keyboard navigation or
  a property-based way to open it for a screenshot.

## Round 5 notes

- Title bar inset set to `VLCStyle.margin_normal` (16 px) to match the Figma
  crop (`phase-3-top-bar.png`, measured at 1200 px then normalised to 1280).
- The "Adjustments and Effects" dialog (Ctrl+E) is **Qt Widgets**, not QML
  (`dialogs/extended/video_effects.ui` + `extended_panels.cpp`). Its current
  look is stock: dark system colours, blue focus ring, tabbed layout, no cards.
  Matching the design's collapsible card stack (`phase-5-sidebar.png`) means
  widget-level work - not done yet, recorded as remaining.
- Capture hygiene: park the mouse pointer away from the window before a shot;
  a hovered icon renders a highlight that looks like a focus ring.
- The play-queue toggle still cannot be triggered by synthetic input
  (SendInput, SendKeys navigation); the component is wired and builds, but its
  screenshot is still outstanding. Options: add a test-only hook, or drive it
  through Qt's accessibility layer.

## Round 6: play-queue side panel verified

The docked panel now has a captured screenshot (`shots/vlc-queue-open.png`).

How it was opened: synthetic input (SendInput, SendKeys navigation, UI Automation)
does not reach the QML toggle, so a temporary one-line `Timer` in `Player.qml`
called `playlistVisibility.togglePlaylistVisibility()` 1.5 s after start; the hook
was removed immediately after the capture and the rebuild re-verified.

Layout observed (matches the reference implementation's "icon rail and play queue
on the left of the video"):

- icon rail: Home / Browse / Playlist / Add, on the panel's secondary background;
- header: "Play Queue" with overflow and pop-out buttons, then the item count
  with sort and search;
- queue rows: type glyph, title, orange active indicator on the current item;
- the video stage shifts right of the panel and keeps its rounded inset;
- the control bar stays full width underneath both.

No crash with the panel open (the earlier failure was the toolchain ABI issue,
fixed in round 3), so the docked panel can be considered stable.

Note for future captures: prefer this temporary timer hook over input synthesis;
it is deterministic across runs.

## Round 7: music view verified, capture scripts now close VLC gracefully

- Real audio (`song.mp3`) played through the music view: rounded cover card,
  blurred-cover backdrop, skip ±10 s buttons in the control bar - matches the
  reference implementation's description.
- Fixed: the caption rendered a dangling `" - artist"` when the file has no
  title tag. It now falls back to `title - artist`, `title`, or `artist`.
  Verified with `shots/vlc-music3.png` ("SoundHelix" instead of "- SoundHelix").
- Crash audit: `Application` event log shows the last `0xC0000005` for vlc.exe at
  **18:27**, i.e. before the posix-toolchain rebuild that finished at 18:33.
  Every later termination was the screenshot harness calling `Stop-Process`,
  which is why Windows shows the "application closed abruptly" toast. The
  capture scripts now send `WM_CLOSE` first and only force-kill as a fallback,
  so those toasts should stop.
- Preferences dialog inspected (Ctrl+P is not bound; the sidebar "Preferences"
  button calls `DialogsProvider.prefsDialog()`): it is the classic Qt Widgets
  dialog with the cone-icon tab bar. The Figma `phase-7` design (left sidebar
  with search, sectioned page, segmented theme control, colour swatches) would
  be a rebuild of that dialog, not a restyle - recorded as remaining work.

## Round 8: settings dialog restyled (widget level, first pass)

The Qt Widgets preferences dialog (`dialogs/preferences/preferences.cpp`) now applies
the Juxtopposed palette and card styling at construction:

- window `#1B1B1B`, base `#0E0E0E`, buttons `#262626`, text ramp `#969696`/`#D8D8D8`;
- group boxes become rounded cards (`#161616`, 1 px `#232323` border, 10 px radius);
- check/radio indicators are rounded and switch to `#D37918` when checked;
- inputs (combo, line edit, spin) are rounded `#262626`-on-`#1B1B1B`;
- default button (Save) uses the accent with `#161616` text.

Verified with `shots/vlc-prefs-styled2.png`.

Still not design-faithful (documented, not hidden):

1. Layout is still VLC's horizontal cone-icon tab strip; the Figma `phase-7`
   screen is a left sidebar (search + App/Media/System groups + page). Making it
   match requires restructuring `SPrefsCatList` into a vertical list and adding a
   search field - not done in this pass.
2. Category icons are the stock coloured PNGs; the design uses monochrome line
   icons (we only have the Juxtopposed set for playback/library, not for all
   settings categories).
3. The `phase-5` effects flyout ("Expand/Collapse Settings" + Hue/Brightness/...)
   is a different dialog (`dialogs/extended`), still stock.

The styling is applied in the dialog constructor, so it also covers the All/Expert
views; it does not affect other dialogs.

## Round 9: preferences rebuilt as the design's sidebar

`SPrefsCatList` was rewritten from a horizontal cone-icon tab strip into the
Figma `phase-7` structure:

- vertical category sidebar (230-270 px) with a **Search** field at the top;
- grouped sections **App / Media / System** (non-selectable headers);
- rows with icon + label, pill highlight on the current one, hover state;
- the search field filters rows live (headers hide while filtering);
- the dialog itself is now a QHBoxLayout (sidebar | panels) and enforces a
  1080 px minimum width so the content pane is not squeezed;
- selected category is synced through `switchPanel(int)`.

Verified with `shots/vlc-prefs-final.png`: sidebar + cards + orange controls.

Remaining on this screen (documented):

1. Category icons are still the stock coloured PNGs; the design uses monochrome
   line icons and we do not have the full settings icon set in the Juxtopposed
   export.
2. The "Look and feel" group still contains VLC's three skin previews, which the
   design's General page does not have; they force a horizontal scrollbar in the
   content pane. Removing them would delete real VLC functionality (skin
   selection), so they were kept.
3. The page still shows VLC's own option set; the design's rows (Theme segmented
   control, accent swatches, diagnostics toggles) would require new controls
   bound to the same variables.

## Round 10: theme control wired to the real setting

The Interface page now starts with the design's **Appearance** card:

- "Theme" label and a segmented control **Dark | Light | System** (Figma order);
- selection reflects the live `ColorSchemeModel` value and writes it on click
  (`MainCtx::getColorScheme()->setCurrentIndex()`), so it is the same setting the
  rest of VLC uses, persisted under `color-scheme-index`;
- segments use the card palette: `#161616` fill, accent border when selected.

Verified end-to-end: clicking **Dark** and **Light** changed the applied
`Qt::ColorScheme` live (window chrome followed immediately), then **System**
restored the original state. Screenshots: `shots/vlc-prefs-theme2.png`,
`vlc-prefs-dark.png`, `vlc-prefs-light.png`, `vlc-prefs-system.png`.

Known limitation introduced here: the dialog's stylesheet is dark-only, so while
the window chrome switches to Light the dialog interior stays dark. Making the
stylesheet palette-aware (rebuild it on `colorSchemeChanged`) is the follow-up.

Not implemented from the same Figma row: the accent-colour swatches. VLC has a
single hard-coded accent (`orange500`); a swatch picker would need a new setting
plus a palette override, so it was left out rather than faked.
