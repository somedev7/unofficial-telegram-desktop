# Unofficial Telegram Desktop

<img src="branding/preview.png" alt="Logo preview" width="600">

An **unofficial** build of [Telegram Desktop](https://github.com/telegramdesktop/tdesktop) for Linux x64.
It is upstream's code at a release tag plus a couple of small patches,
rebuilt automatically from every stable upstream release by
[GitHub Actions](.github/workflows/build.yml), in the same Docker
environment upstream uses for its official Linux builds.

Not affiliated with Telegram. The app uses the Telegram API.

## What is different from the official app

- **Notification content while the app or the screen is locked**
  ([0001](patches/0001-show-notification-content-while-locked.patch)).
  Upstream replaces sender, chat and text with "You have a new message"
  while the local passcode lock is active, and also while the desktop
  screen is locked (on Linux the XDG desktop portal reports it). Here the
  *Settings > Notifications > Show* choice applies in both states.
  The app itself still can't be opened without the passcode, and the
  reply / mark-as-read buttons stay hidden while either lock is on.
- **Your own api_id / api_hash, set at runtime**
  ([0002](patches/0002-read-api-credentials-at-runtime.patch)).
  No credentials are built in. They are taken from the
  `TDESKTOP_API_ID` + `TDESKTOP_API_HASH` environment variables or from
  `~/.local/share/TelegramDesktop/api_credentials.json`
  (`{"api_id": 12345, "api_hash": "0123…"}`). If there are none, the app
  asks for them on launch. Get yours at <https://my.telegram.org> >
  *API development tools*.
- **Menu entry for the portable build**
  ([0003](patches/0003-portable-desktop-integration.patch)).
  Upstream skips the `.desktop` file and icon when the updater is off
  (it assumes a distro package). Here the app installs them with the full
  path to the binary.
- **Name and logo**: "Unofficial Telegram Desktop", app id
  `unofficial.telegram.desktop`, own icon ([branding](branding/)), as the
  [Telegram API terms](https://core.telegram.org/api/terms) require.
- No built-in updater and no crash reports.

## Install

1. Download `unofficial-telegram-desktop-<version>-linux-x64.tar.xz` from
   [Releases](../../releases) and check it against the `.sha256` file.
2. Unpack it anywhere and run `UnofficialTelegram/Telegram`. On the first
   launch the app adds itself to the applications menu.

It uses the same data folder as the official app
(`~/.local/share/TelegramDesktop`), so an existing login is picked up.

- Back up `tdata` before the first launch.
- Quit the official app first: both can't run on one data folder at once.
- Don't go back to an older version than the one that last used the folder.

## How a release is built

`.github/workflows/build.yml` runs every 3 hours:

1. Takes the latest stable upstream release.
2. Applies `patches/*.patch` and `branding/apply.sh`.
3. Builds with upstream's `Telegram/build/docker/centos_env`.
4. Publishes a release with the same tag.

`branding/apply.sh` fails instead of silently skipping if upstream moved
something it replaces. The logo sources are in `branding/src/`;
`branding/render.py` renders the PNGs.

## License

GPLv3, like upstream ([LICENSE](LICENSE), [upstream LEGAL](https://github.com/telegramdesktop/tdesktop/blob/dev/LEGAL)).
The complete source of every release is the upstream tag it names plus this
repository at the commit linked in the release notes.
