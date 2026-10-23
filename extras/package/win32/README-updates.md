# VLC Reimagined — update system

VLC Reimagined checks a small text file (the *manifest*) that you host on your
own website. When the manifest announces a newer version, the app offers to
download the setup executable, run it and quit so that the installer can
replace the files.

No VideoLAN server, PGP key or external service is involved.

## How it looks for the user

* **Settings → General → "Check for updates automatically"** (on by default)
  makes the app look for a new version once a day at startup.
* **Main menu (… ) → "Check for Updates"** opens the update dialog and starts
  a check immediately.
* When a new version exists the dialog lists the release notes and offers
  **Yes / No**. *Yes* downloads the installer with a progress bar, then asks
  *"close VLC and install it now?"*. *Install* launches the setup (Windows
  shows the usual UAC prompt) and closes the app.

The setting is the standard `qt-updates-notif` option, so it can also be
changed in the advanced preferences.

## The manifest

Plain text, UTF-8, three parts:

```
4.0.1
https://example.com/download/VLC-Reimagined-4.0.1-win64-setup.exe
Faster startup on large libraries.
Fixed the audio delay slider.
```

1. first line: latest version (`MAJOR.MINOR.REVISION` or
   `MAJOR.MINOR.REVISION.EXTRA`);
2. second line: direct HTTPS URL of the Windows setup executable;
3. everything after: release notes, shown in the update dialog
   (plain text, line breaks are kept).

Versions are compared numerically. The file is limited to 64 KiB.

## Where the URL is configured

`src/misc/update.c`:

```c
#ifndef VLC_REIMAGINED_UPDATE_URL
# define VLC_REIMAGINED_UPDATE_URL "https://vlc-reimagined.example.com/update/win64.txt"
#endif
```

Change that default to the real address and rebuild. The value can also be
overridden without editing the source:

* at configure/build time: `-DVLC_REIMAGINED_UPDATE_URL=\"https://...\"` in
  `CFLAGS`/`CXXFLAGS` for the `libvlccore` target, or
* at run time (testing): set the `VLC_REIMAGINED_UPDATE_URL` environment
  variable before starting `vlc.exe`.

## Hosting

The manifest is a few hundred bytes, so it can live on the landing website
(`public/update/win64.txt` in the Next.js project, served as
`https://<domain>/update/win64.txt`).

The setup executable is ~57 MB. GitHub Releases is the easiest place to host
it (2 GB per asset, permanent URL):

```
https://github.com/<account>/<repo>/releases/download/v4.0.1/VLC-Reimagined-4.0.1-win64-setup.exe
```

Static site hosts have small per-file limits (Cloudflare Pages: 25 MiB,
Vercel: ~100 MiB), so prefer GitHub Releases unless you have object storage.

The manifest must be reachable over **HTTPS** and should not require cookies
or authentication.

## One-time setup

1. Decide the public address of the manifest, e.g.
   `https://vlcreimagined.example/update/win64.txt`.
2. Put it in `VLC_REIMAGINED_UPDATE_URL` in `src/misc/update.c`.
3. Rebuild (`ninja -C build/win64-meson`) and repackage.
4. Publish an empty/current manifest so early checks succeed instead of
   reporting an error:

   ```
   4.0.0
   https://<domain>/download/VLC-Reimagined-4.0.0-win64-setup.exe
   Initial release.
   ```

## Releasing an update

1. **Bump the version** in `meson.build` (`project(..., version: '4.0.1-dev')`)
   and rebuild. The compiled version is what the app compares with the
   manifest.
2. **Package**:

   ```
   VERSION=4.0.1 extras/package/win32/package-redesign.sh
   ```

   This produces `VLC-Reimagined-4.0.1-win64-setup.exe`.
3. **Upload** the setup executable (GitHub Releases is recommended).
4. **Update the manifest** (a normal website deploy, no app rebuild):

   ```
   4.0.1
   https://github.com/<account>/<repo>/releases/download/v4.0.1/VLC-Reimagined-4.0.1-win64-setup.exe
   What changed in 4.0.1:
   - ...
   ```

5. That is it: users who keep the automatic check enabled see the dialog the
   next time they start the app, and anyone can use
   *Main menu → Check for Updates*.

> The installer created by `package-redesign.sh` installs into
> `%ProgramFiles%\VLC Reimagined` and requires administrator rights; the app
> closes itself right before the setup starts so that no file is locked.

## Testing before publishing

Use the environment override, a local HTTP server and an unreleased version
number in the manifest:

```sh
cd /path/to/manifest-dir
python3 -m http.server 8099
```

Then start the build with:

```
set VLC_REIMAGINED_UPDATE_URL=http://<wsl-ip>:8099/win64.txt
vlc.exe -vv --file-logging --logfile=%TEMP%\update-test.log
```

The log contains `Update manifest loaded from ...` when the check succeeds.
The download can be tested with any small `.exe` file; cancel at the install
prompt to avoid running it.

## Notes

* Downloads go to the Windows temporary folder and are not kept after a
  reboot.
* The installer is not code-signed, so Windows SmartScreen will warn about an
  unknown publisher (see the packaging notes).
* There is no cryptographic signature on the manifest beyond HTTPS. Keep the
  domain and DNS account secured: whoever controls them can ship an
  executable to your users.
