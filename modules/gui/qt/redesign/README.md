# VLC redesign (Qt Quick)

This folder holds a new interface for the Qt module, written from scratch to
follow the community redesign made by Juxtopposed. The Qt module keeps its native playback and video compositor architecture.
Small C++ bridges expose configuration snapshots, subtitle cues, external tracks
and media-library collection operations to the redesign. That covers `Player`, `MainPlaylistController`,
the media library models, `DialogsProvider` and the video compositors. The classic QML interface remains available.

* `qml/`: the `VLC.Redesign` QML module, with `RMainInterface.qml` as its root
* `icons/`: the icon set exported from the Figma file. Main color is
  `#FF00FF`, accent is `#FF8800`, and both are recolored at runtime by
  `RedesignIconProvider` (`image://redesignicon/<name>?c=<color>&a=<accent>`)
* `redesign_icon_provider.*`: synchronous SVG provider for these icons

The redesigned interface is enabled by default. Start VLC with
`--no-qt-redesign`, or untick *Interface > Main interfaces > Qt > Use the
redesigned interface*, to get the classic interface back.

## Status

| Area | Implemented |
|------|-------------|
| Player | Floating controls, music cover view, queue/bookmarks/chapters, hide UI, compact topmost player with a separate library window |
| Library | Home/videos/music/network/playlists/recent, nested folders, compact sidebar, pins, search, sorting and persistent grid/list choices |
| Media actions | Play/enqueue, favorites, watched state, playlist membership/rename/delete/export, native streaming/conversion and metadata, external subtitle/audio matching |
| Settings | 13 categories, expanded native options, shortcuts, light/dark/system themes and accent |
| Effects | Audio/video filters, native HDR tone mapping when available, visualizer, named playback/effect presets, SRT/WebVTT synchronization timeline |
| Personalization | Onboarding, top/control bar customization and profiles including VLC options and live playback/effect state |

Windows verification and native-engine adaptations are recorded in
`redesign-dev/REDESIGN-ACCEPTANCE.md`. Hardware HDR and the DirectComposition
video path require a display-based playback check; offscreen QA does not prove them.

## Design tokens

`Theme.qml` mirrors the Figma variables (`Dark/BG/A3`, `Dark/FG/A2`, ...).
Sizes are given at 1x and scaled with the interface scale factor through
`Theme.dp()`.
