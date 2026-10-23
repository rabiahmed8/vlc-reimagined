#!/bin/bash
#############################################################################
# Build the Windows distribution of this VLC fork:
#   * a portable ZIP of the runtime tree
#   * a Windows setup (NSIS .exe)
#
# Run it from a WSL shell, after a successful `ninja -C build/win64-meson`:
#
#   extras/package/win32/package-redesign.sh
#
# Environment variables (all optional):
#   VERSION            version shown by the installer (default: 1.0.0)
#   PRODUCT_NAME       application name       (default: VLC Reimagined)
#   PRODUCT_PUBLISHER  vendor shown in setup  (default: VLC Reimagined)
#   PRODUCT_WEBSITE    website shown in setup (default: https://vlc-reimagined.vercel.app)
#   BUILD_DIR          meson build directory  (default: <repo>/build/win64-meson)
#   INSTALL_DIR        installed VLC tree     (default: <BUILD_DIR>/vlc-win64)
#   WORK_DIR           output directory       (default: <repo>/build/package)
#
# NOTE about redistribution: VLC is GPLv2+/LGPLv2.1+ and its name/logo are
# VideoLAN trademarks. Before publishing a modified build, ship the complete
# corresponding source and either get VideoLAN's permission to use the VLC
# name and cone, or rename/rebrand the application.
#############################################################################
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../../.." && pwd)
BUILD_DIR=${BUILD_DIR:-$ROOT/build/win64-meson}
INSTALL_DIR=${INSTALL_DIR:-$BUILD_DIR/vlc-win64}
WORK_DIR=${WORK_DIR:-$ROOT/build/package}
VERSION=${VERSION:-1.0.1}
PRODUCT_NAME=${PRODUCT_NAME:-"VLC Reimagined"}
PRODUCT_PUBLISHER=${PRODUCT_PUBLISHER:-"VLC Reimagined"}
PRODUCT_WEBSITE=${PRODUCT_WEBSITE:-"https://vlc-reimagined.vercel.app"}

MAKE_PORTABLE=1
MAKE_INSTALLER=1
for arg in "$@"; do
    case "$arg" in
        --no-portable)  MAKE_PORTABLE=0 ;;
        --no-installer) MAKE_INSTALLER=0 ;;
        -h|--help)      sed -n '2,26p' "$0"; exit 0 ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

[ -d "$INSTALL_DIR" ] || { echo "missing install tree: $INSTALL_DIR" >&2; exit 1; }

VERSION_MAJOR=${VERSION%%.*}
VERSION_REST=${VERSION#*.}
VERSION_MINOR=${VERSION_REST%%.*}

STAGE=$WORK_DIR/VLC-Reimagined-$VERSION-win64
echo "== staging $INSTALL_DIR -> $STAGE"
mkdir -p "$WORK_DIR"
rm -rf "$STAGE"
mkdir -p "$STAGE"
# sdk/, lib/vlc import libraries and WiX description are not runtime files
( cd "$INSTALL_DIR" && tar -cf - --exclude=sdk --exclude='*.a' --exclude='*.pdb' --exclude=config.wxi . ) \
    | ( cd "$STAGE" && tar -xf - )

# Refresh the gcc runtime DLLs that live outside the install prefix.
for d in libssp-0.dll libgcc_s_seh-1.dll; do
    cp -f "/usr/lib/gcc/x86_64-w64-mingw32/13-win32/$d" "$STAGE/" 2>/dev/null || true
done
cp -f /usr/x86_64-w64-mingw32/lib/libwinpthread-1.dll "$STAGE/" 2>/dev/null || true

echo "== stripping binaries"
find "$STAGE" -type f \( -name '*.dll' -o -name '*.exe' \) -print0 \
    | xargs -0 -r x86_64-w64-mingw32-strip --strip-unneeded
echo "   $(du -sh "$STAGE" | cut -f1)"

if [ "$MAKE_PORTABLE" = 1 ]; then
    echo "== building portable archive"
    # The presence of a "portable" folder next to vlc.exe switches the app to
    # portable mode: settings, media library and cache stay in that folder.
    mkdir -p "$STAGE/portable"
    cat > "$STAGE/portable/README.txt" <<'EOF'
VLC Reimagined -- portable mode

This copy keeps all of its settings, playlists and cache inside this folder.
Delete the "portable" folder to use the normal profile in %APPDATA% instead.
EOF
    rm -f "$WORK_DIR/VLC-Reimagined-$VERSION-win64-portable.zip"
    ( cd "$WORK_DIR" && zip -qr "VLC-Reimagined-$VERSION-win64-portable.zip" "VLC-Reimagined-$VERSION-win64" )
    ls -lh "$WORK_DIR/VLC-Reimagined-$VERSION-win64-portable.zip"
fi

if [ "$MAKE_INSTALLER" = 1 ]; then
    echo "== preparing installer files"
    NSIS_SRC=$ROOT/extras/package/win32/NSIS
    mkdir -p "$STAGE/NSIS"
    cp -a "$NSIS_SRC/helpers" "$NSIS_SRC/languages" "$STAGE/"
    cp -a "$NSIS_SRC/vlc_branding.bmp" "$STAGE/NSIS/"
    cp -a "$NSIS_SRC/nsProcess.nsh" "$STAGE/NSIS/"

    # The installer normally uses the nsProcess NSIS plugin, which only exists
    # as a 32-bit DLL and needs an i686 mingw compiler. Use a portable check
    # instead: a running vlc.exe cannot be opened for appending.
    python3 - "$STAGE/helpers/utils.nsh" <<'PY'
import re, sys
path = sys.argv[1]
src = open(path, encoding='utf-8', errors='surrogateescape').read()
new = r'''Function CheckRunningProcesses
    IfFileExists "$INSTDIR\vlc.exe" 0 end
    ; The in-app updater closes VLC right after launching this setup: wait up
    ; to six seconds for vlc.exe to be released before asking the user.
    StrCpy $R1 0
  retry:
    ClearErrors
    FileOpen $R0 "$INSTDIR\vlc.exe" a
    IfErrors 0 close
    IntOp $R1 $R1 + 1
    IntCmp $R1 12 ask wait wait
  wait:
    Sleep 500
    Goto retry
  ask:
    IfSilent stop
    MessageBox MB_OKCANCEL|MB_ICONQUESTION "$(MessageBox_VLCRunning)" IDCANCEL stop
    ClearErrors
    FileOpen $R0 "$INSTDIR\vlc.exe" a
    IfErrors 0 close
    MessageBox MB_OK|MB_ICONEXCLAMATION "$(MessageBox_VLCUnableToClose)"
    Goto stop
  close:
    FileClose $R0
    Goto end
  stop:
    MessageBox MB_OK|MB_ICONEXCLAMATION "$(MessageBox_InstallAborted)"
    Quit
  end:
FunctionEnd
'''
out, n = re.subn(r'Function CheckRunningProcesses.*?\nFunctionEnd', lambda m: new, src, flags=re.S)
if n != 1:
    sys.exit('could not patch CheckRunningProcesses')
open(path, 'w', encoding='utf-8', errors='surrogateescape').write(out)
PY

    echo "== generating vlc.win32.nsi"
    NLS_TRUE=';'
    [ -d "$STAGE/locale" ] && NLS_TRUE=''
    SKINS_TRUE=';'
    [ -d "$STAGE/skins" ] && SKINS_TRUE=''
    LUA_TRUE=';'
    [ -d "$STAGE/lua" ] && LUA_TRUE=''

    sed \
        -e "s|@VERSION@|$VERSION|g" \
        -e "s|@VERSION_MAJOR@|$VERSION_MAJOR|g" \
        -e "s|@VERSION_MINOR@|$VERSION_MINOR|g" \
        -e "s|@HAVE_WIN64_TRUE@| |g" \
        -e "s|@HAVE_WIN64_FALSE@|;|g" \
        -e "s|@HAVE_ARM64_TRUE@|;|g" \
        -e "s|@HAVE_ARM64_FALSE@| |g" \
        -e "s|@PROGRAMFILES@|PROGRAMFILES64|g" \
        -e "s|@HAVE_NLS_TRUE@|$NLS_TRUE|g" \
        -e "s|@BUILD_SKINS_TRUE@|$SKINS_TRUE|g" \
        -e "s|@BUILD_LUA_TRUE@|$LUA_TRUE|g" \
        "$NSIS_SRC/vlc.win32.nsi.in" > "$STAGE/vlc.win32.nsi"

    sed -i \
        -e "s|^!define PRODUCT_NAME .*|!define PRODUCT_NAME \"$PRODUCT_NAME\"|" \
        -e "s|^!define PRODUCT_PUBLISHER .*|!define PRODUCT_PUBLISHER \"$PRODUCT_PUBLISHER\"|" \
        -e "s|^!define PRODUCT_WEB_SITE .*|!define PRODUCT_WEB_SITE \"$PRODUCT_WEBSITE\"|" \
        "$STAGE/vlc.win32.nsi"

    # Make the setup coexist with an official VLC installation: separate
    # install directory, registry root, media-client registration, ProgIDs and
    # autoplay handlers.
    echo "== patching installer for side-by-side coexistence"
    PRODUCT_NAME="$PRODUCT_NAME" python3 - "$STAGE" <<'PY'
import os, pathlib, re, sys

stage = pathlib.Path(sys.argv[1])
name = os.environ["PRODUCT_NAME"]
nsi = stage / "vlc.win32.nsi"

def sub(path, old, new, count=0):
    src = path.read_text(encoding="utf-8", errors="surrogateescape")
    if old not in src:
        sys.exit(f"missing {old!r} in {path.name}")
    path.write_text(src.replace(old, new) if count == 0
                    else src.replace(old, new, count),
                    encoding="utf-8", errors="surrogateescape")

# ---- main installer script ------------------------------------------------
sub(nsi, '!define PRODUCT_DIR_REGKEY "Software\\VideoLAN\\VLC"',
          '!define PRODUCT_DIR_REGKEY "Software\\VLCReimagined"')
sub(nsi, 'InstallDir "$PROGRAMFILES64\\${PRODUCT_PUBLISHER}\\VLC"',
          f'InstallDir "$PROGRAMFILES64\\{name}"')
sub(nsi, 'StrCpy $INSTDIR "$PROGRAMFILES64\\${PRODUCT_PUBLISHER}\\VLC"',
          f'StrCpy $INSTDIR "$PROGRAMFILES64\\{name}"')
sub(nsi, 'RMDir /r $SMPROGRAMS\\${PRODUCT_PUBLISHER}',
          'RMDir /r "$SMPROGRAMS\\${PRODUCT_PUBLISHER}"')
sub(nsi, '"Software\\RegisteredApplications" "VLC"',
          f'"Software\\RegisteredApplications" "{name}"')
sub(nsi, 'Software\\Clients\\Media\\VLC',
          f'Software\\Clients\\Media\\{name}')
sub(nsi, '"VLC - The video swiss knife"',
          f'"{name} - The video swiss knife"')
sub(nsi, 'VLCPlay', 'VLCReimaginedPlay')
sub(nsi, '"VLC.', '"VLCReimagined.')
# Never delete the VideoLAN registry tree: it belongs to the official VLC.
sub(nsi, 'DeleteRegKey HKLM Software\\VideoLAN',
          'DeleteRegKey HKLM Software\\VLCReimagined')
sub(nsi, 'DeleteRegKey HKLM Software\\Clients\\Media\\VLC Reimagined',
          f'DeleteRegKey HKLM "Software\\Clients\\Media\\{name}"')

# ---- file association helpers --------------------------------------------
ext = stage / "helpers" / "extensions.nsh"
sub(ext, 'Software\\Clients\\Media\\VLC',
         f'Software\\Clients\\Media\\{name}')
sub(ext, 'VLC$R0', 'VLCReimagined$R0')
sub(ext, '"VLC.backup"', '"VLCReimagined.backup"')
sub(ext, '(VLC)', f'({name})')
PY

    echo "== running makensis"
    ( cd "$STAGE" && makensis -V2 vlc.win32.nsi )
    mv -f "$WORK_DIR/vlc-$VERSION-win64.exe" "$WORK_DIR/VLC-Reimagined-$VERSION-win64-setup.exe"
    ls -lh "$WORK_DIR/VLC-Reimagined-$VERSION-win64-setup.exe"
fi

echo
echo "done:"
ls -lh "$WORK_DIR"/VLC-Reimagined-"$VERSION"-win64-portable.zip \
      "$WORK_DIR"/VLC-Reimagined-"$VERSION"-win64-setup.exe 2>/dev/null || true
