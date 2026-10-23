# VLC Reimagined — updates and releases

VLC Reimagined ships its own updater. It does not use VideoLAN's update
servers, status files or PGP signatures: the app reads a small plain-text
**manifest** over HTTPS, and that manifest points at the Windows installer
hosted on GitHub Releases.

## What the user sees

* **Settings → General → "Check for updates automatically"** is enabled by
  default. At startup the app checks at most once every `qt-updates-days`
  days (default: 1).
* **Main menu (…) → "Check for Updates"** opens the dialog and checks
  immediately.
* If the manifest announces a newer version, the dialog shows the release
  notes and offers **Yes / No**. *Yes* downloads the installer with a progress
  bar; when the download finishes the app asks whether to close itself and run
  the setup. The installer keeps settings, library and playlists.
* If the manifest is missing, malformed or unreachable, the check fails
  silently (it is logged with `-vv`) and the user is not nagged.

## Version numbers

The product version is independent from the upstream VLC version:

* First public release: **1.0.0**.
* Later releases follow `MAJOR.MINOR.PATCH`: `1.0.1` (fix), `1.1.0`
  (features), `2.0.0` (breaking changes).
* The VLC 4 engine underneath keeps its own internal version; libvlc's ABI
  version (`12.0.0` in `meson.build`) is unrelated and must not be used for
  releases.
* Git tags get a `v` prefix (`v1.0.0`); the **manifest and the file names never
  do** — the manifest parser expects `1.0.0`, not `v1.0.0`.
* The version in `meson.build` and `VERSION` in `package-redesign.sh` must
  match, otherwise the installer and the app disagree about what is installed.

Versions are compared numerically, component by component. There is no
pre-release logic: a local build whose numeric version equals the manifest
(e.g. `1.0.0-dev`) is not offered an update.

## Manifest format

Plain text, UTF-8, at most 64 KiB, exactly three parts:

```
1.0.0
https://github.com/rabiahmed8/vlc-reimagined/releases/download/v1.0.0/VLC-Reimagined-1.0.0-win64-setup.exe
VLC Reimagined 1.0.0
- Redesigned player, library and settings.
- Queue reordering, track panels, subtitle sync.
- Portable mode, side-by-side installation with VLC, in-app updates.
```

1. **Line 1** — latest version: `MAJOR.MINOR.REVISION` or
   `MAJOR.MINOR.REVISION.EXTRA`, digits only.
2. **Line 2** — direct HTTPS URL of the Windows **installer** (`.exe`). Not
   the release page, not the portable ZIP, not a redirector that needs
   cookies.
3. **Everything after line 2** — release notes, shown in the update dialog.
   Required (must not be empty), plain text, line breaks are preserved.

The file name in the URL becomes the file name of the download, so keep the
asset names clean (`VLC-Reimagined-1.0.0-win64-setup.exe`, no spaces).

Both the manifest and the installer must be served with a
`Content-Length` header: the updater refuses streams of unknown size. Static
files on GitHub, Vercel, Netlify and plain nginx all do this; chunked
responses and some object-storage presigned URLs do not.

## Where the manifest lives

The manifest is a static file on the landing site:

```
https://vlc-reimagined.vercel.app/update/win64.txt
```

In the Next.js project that is `public/update/win64.txt`. The installer itself
must **not** be committed to the site or served by Vercel: a 57 MB file in the
deployment is slow to build and burns bandwidth. It lives on GitHub Releases.

The site should serve the manifest with a short cache so that a new release is
visible immediately:

```
Cache-Control: public, max-age=0, must-revalidate
```

(Vercel already does this for files in `public/`; add a `headers` rule in
`vercel.json` if you want it explicit.)

## Where the URL is configured

`src/misc/update.c`:

```c
#ifndef VLC_REIMAGINED_UPDATE_URL
# define VLC_REIMAGINED_UPDATE_URL "https://vlc-reimagined.vercel.app/update/win64.txt"
#endif
```

The default is compiled into the app: changing the domain requires a rebuild.
For local testing it can be overridden at run time without rebuilding:

```
set VLC_REIMAGINED_UPDATE_URL=http://127.0.0.1:8099/win64.txt
vlc.exe -vv --file-logging --logfile=%TEMP%\update-test.log
```

The log contains `Update manifest loaded from ...` when the check succeeds.
The download can be tested with any small `.exe`; cancel at the install prompt
to avoid running it.

## Publishing a release

### 1. Bump the version

* `meson.build`: `version: '1.0.1'`
* `extras/package/win32/package-redesign.sh`: `VERSION=${VERSION:-1.0.1}`
* Rebuild: `ninja -C build/win64-meson`

### 2. Package

```sh
VERSION=1.0.1 extras/package/win32/package-redesign.sh
```

Output in `build/package/`:

* `VLC-Reimagined-1.0.1-win64-setup.exe` — the file the updater downloads;
* `VLC-Reimagined-1.0.1-win64-portable.zip`.

### 3. Tag the exact commit that produced the binaries

Build first, then tag that commit — never tag a tree that differs from the
binaries. The release page also publishes the source archive, which is what
satisfies the GPL.

```sh
git tag -a v1.0.1 -m "VLC Reimagined 1.0.1"
git push origin v1.0.1
```

### 4. Create the GitHub release

With the web UI:

1. Repository → **Releases** → **Draft a new release**.
2. **Choose a tag**: `v1.0.1` (create it from the target branch/commit if you
   did not push the tag).
3. **Title**: `VLC Reimagined 1.0.1`.
4. **Describe this release**: the user-facing changelog. Copy the important
   parts into the manifest notes as well.
5. Attach `VLC-Reimagined-1.0.1-win64-setup.exe` and
   `VLC-Reimagined-1.0.1-win64-portable.zip` as binary assets.
6. Leave **Set as the latest release** checked; do **not** mark it as a
   pre-release (the site's "latest" link skips pre-releases).
7. **Publish release**.

With the `gh` CLI:

```sh
gh release create v1.0.1 \
  --repo rabiahmed8/vlc-reimagined \
  --target redesign-ui \
  --title "VLC Reimagined 1.0.1" \
  --notes-file release-notes/1.0.1.md \
  build/package/VLC-Reimagined-1.0.1-win64-setup.exe \
  build/package/VLC-Reimagined-1.0.1-win64-portable.zip
```

(Install `gh` first, e.g. `sudo apt install gh`, and run `gh auth login`.)

The asset URL is then:

```
https://github.com/rabiahmed8/vlc-reimagined/releases/download/v1.0.1/VLC-Reimagined-1.0.1-win64-setup.exe
```

### 5. Update the manifest on the site

```
1.0.1
https://github.com/rabiahmed8/vlc-reimagined/releases/download/v1.0.1/VLC-Reimagined-1.0.1-win64-setup.exe
VLC Reimagined 1.0.1
- ...
```

Commit + push (Vercel redeploys), or upload the file. No app rebuild is
needed for a new release: only the domain change requires one.

### 6. Verify

```sh
# the asset redirects to objects.githubusercontent.com and has a size
curl -sIL https://github.com/rabiahmed8/vlc-reimagined/releases/download/v1.0.1/VLC-Reimagined-1.0.1-win64-setup.exe \
  | grep -iE '^HTTP/|content-length|content-type'

# the manifest is served as-is, with a size
curl -s https://vlc-reimagined.vercel.app/update/win64.txt
curl -sI https://vlc-reimagined.vercel.app/update/win64.txt | grep -i content-length
```

Then run the **previous** version (or any build with a smaller version) and
use *Check for Updates*. Do not test with the same version: the comparison is
numeric and equal versions are not offered.

## Checklist

- [ ] `meson.build` version and `VERSION` in the packaging script match
- [ ] binaries built from the commit that will be tagged
- [ ] tag `vX.Y.Z` pushed, release published (not draft, not pre-release)
- [ ] setup `.exe` attached to the release
- [ ] asset URL opens without login and has `Content-Length`
- [ ] site manifest updated with version, installer URL and notes
- [ ] manifest is reachable over HTTPS with a size and a short cache
- [ ] update tested from the previous installed version
- [ ] tag, release and assets kept (do not delete them later)

## Common mistakes

* `v1.0.1` on the version line — the parser rejects it.
* Pointing line 2 at the release page or at the ZIP — the updater downloads
  HTML or a ZIP and then tries to execute it.
* Empty release notes — the manifest is rejected.
* A host that sends the file chunked or without `Content-Length` — rejected.
* Caching the manifest for a year — updates appear months late.
* Bumping the manifest but not the app version — every check re-offers the
  same update.
* Replacing an already-published asset with a different binary — downloads in
  flight break; publish a new patch version instead.
* Deleting or renaming the repository, the release assets, or the site domain
  that hosts the manifest — installed apps can no longer receive fixes.

## Security

There is no signature on the manifest beyond HTTPS. Whoever controls the
site, the DNS or the GitHub release can ship an executable to every user:

* enable 2FA on GitHub and on the domain registrar;
* do not put third-party scripts or an editable CMS on `/update/`;
* keep the repository public and the release source archive available (GPL);
* if the domain ever changes, ship a bridge release **before** the old URL
  stops working.
