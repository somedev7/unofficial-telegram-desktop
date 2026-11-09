#!/usr/bin/env bash
# Rebrand an upstream tdesktop checkout in place.
#   branding/apply.sh /path/to/tdesktop
# Fails loudly if upstream moved anything we replace, so the branding
# never silently disappears after an update.
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
SRC=$(cd "${1:?usage: apply.sh <tdesktop checkout>}" && pwd)
# shellcheck source=branding.env
source "$HERE/branding.env"

replace() { # <file relative to SRC> <old literal> <new literal>
	local file="$SRC/$1"
	[ -f "$file" ] || { echo "branding: $1 is missing" >&2; exit 1; }
	python3 -I - "$file" "$2" "$3" <<'PY'
import sys
path, old, new = sys.argv[1:]
text = open(path, encoding="utf-8").read()
if old not in text:
    sys.exit(f"branding: {old!r} not found in {path}")
open(path, "w", encoding="utf-8").write(text.replace(old, new))
PY
}

# 1. Images: overwrite only files that upstream still has.
OUT="$HERE/out"
[ -d "$OUT/Telegram/Resources/art" ] || { echo "branding: run branding/render.py first" >&2; exit 1; }
( cd "$OUT" && find . -type f ) | while read -r f; do
	[ -f "$SRC/$f" ] || { echo "branding: upstream has no $f" >&2; exit 1; }
	cp "$OUT/$f" "$SRC/$f"
done

# 2. Names.
replace Telegram/SourceFiles/core/version.h \
	'constexpr auto AppName = "Telegram Desktop"_cs;' \
	"constexpr auto AppName = \"$APP_NAME\"_cs;"
for f in Telegram/SourceFiles/window/main_window.cpp \
		Telegram/SourceFiles/window/window_restore_shell.cpp \
		Telegram/SourceFiles/window/window_saved_windows.cpp; do
	replace "$f" 'u"Telegram"_q' "u\"$APP_SHORT_NAME\"_q"
done

# 3. Application id (desktop file, D-Bus name, icon name in the icon theme).
replace Telegram/SourceFiles/platform/linux/specific_linux.cpp \
	'u"org.telegram.desktop._%1"_q' "u\"$APP_ID._%1\"_q"
replace Telegram/SourceFiles/platform/linux/specific_linux.cpp \
	'return u"org.telegram.desktop"_q;' "return u\"$APP_ID\"_q;"

# 4. .desktop template the app installs into ~/.local/share/applications.
replace lib/xdg/org.telegram.desktop.desktop 'Name=Telegram' "Name=$APP_SHORT_NAME"
replace lib/xdg/org.telegram.desktop.desktop 'Icon=org.telegram.desktop' "Icon=$APP_ID"

echo "branding: applied ($APP_NAME, $APP_ID)"
