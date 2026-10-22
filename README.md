<p align="center">
  <img src="BeebHD/Assets.xcassets/BeebMark.imageset/mark.png" alt="Beeb app logo" width="96">
</p>

# Beeb

**An independent BBC player for Apple TV, with 4K HLG HDR and Apple's native playback controls.**

Beeb is a native SwiftUI app for **tvOS 17 and later**. Browse BBC programmes, watch live television, save shows and pick up where you left off. When a compatible UHD version and your own UHD setup are available, Beeb plays the original 4K HLG stream without video transcoding.

This is an unofficial project, not produced or endorsed by the BBC. Choose **source code** to build with Xcode, or the **prebuilt unsigned IPA** to sign locally without compiling Beeb. Both require your own Apple signing account and device provisioning. There is no App Store/TestFlight release or universally installable signed IPA.

[Install from source](#install-on-apple-tv) · [Install the unsigned IPA](INSTALL-IPA.md) · [Set up UHD with TwinVine](#optional-4k-hlg-setup-with-twinvine) · [Troubleshooting](TROUBLESHOOTING.md)

![Beeb Modern Sidebar homepage](docs/screenshots/modern-sidebar.png)

*The homescreen and Settings captures show the native 0.10.8 interface using cached BBC listings and artwork. The older playback screenshots below are from the [original Reddit announcement](https://www.reddit.com/r/iplayer/comments/1x7kzsi/i_built_beeb_an_unofficial_apple_tv_bbc_player/); current playback quality badges read 4K, FHD, HD or SD.*

**Current prepared release: 0.10.8 (build 36).** See [the changelog](CHANGELOG.md).

## New since 0.10.7

- **Homescreen Layout:** choose Classic or Modern in Settings. Modern offers a floating Topbar or a Sidebar, and remembers your navigation choice when you switch layouts.
- **Modern homescreens:** large programme artwork, pink focus accents and navigation that scrolls away with the banner as you browse the rows below.
- **Cleaner Browse:** readable icon-led category cards and continuous browsing through categories and A–Z; 4K UHD cards also appear in one lazy grid. No Previous/Next controls for those listings.
- **RED additional streams:** a RED action in every live player opens Red Button or Red Button UHD. Event feeds depend on BBC availability; an unavailable feed leaves your current channel playing.
- **Live subtitles:** BBC's separate live timed-text feed is exposed through Apple's native subtitle controls. Captions use the stream's timing, including when seeking back. Confirmed working on Apple TV by the maintainer.
- **Better Back navigation:** return to the previous programme/menu screen, close the sidebar, or dismiss Additional Streams without choosing another channel. The dialog also offers Cancel.
- **More reliable episode loading:** updated BBC episode discovery and version selection for both HD and UHD playback.

![Homescreen Layout options in Settings](docs/screenshots/homescreen-settings.png)

<details>
<summary>Classic, Modern Topbar and redesigned Browse</summary>

![Classic homescreen](docs/screenshots/classic-home.png)

![Modern Topbar homescreen](docs/screenshots/modern-topbar.png)

![Readable native categories](docs/screenshots/browse-categories.png)

</details>

## What Beeb can do

| Feature | How it works |
| --- | --- |
| **4K HLG HDR playback** | Plays compatible BBC UHD episodes using the original encoded video, audio and HLG metadata. Requires Apple TV 4K, a compatible display connection and optional TwinVine setup. |
| **Automatic quality selection** | The pink logo Play button tries compatible UHD first, then the best available HD/SD stream if UHD is unavailable or not configured. |
| **Programme Info** | The Info button shows the title, episode subtitle, programme thumbnail, full synopsis, running time, original BBC broadcast date and guidance where supplied. A bounded description layout avoids a tvOS native-summary crash. Back hides Info or player controls; a second press exits playback immediately. |
| **Playback speed** | Native on-demand speed menu beside Info, with 0.5×, 0.75×, 1×, 1.25×, 1.5× and 2× options. Live channels keep normal speed. |
| **Regional channels** | Settings offers 16 BBC One regions and three BBC Two feeds. The chosen feed plays from Live or a Top Shelf channel card. Top Shelf artwork uses the default channel schedule. |
| **Native English subtitles** | BBC TTML captions become a proper HLS WebVTT track for on-demand and supported live feeds. Apple's player handles rendering, selection and subtitle appearance. Live captions depend on BBC supplying a compatible timed-text feed. |
| **Subtitles after skipping back** | With Apple's **Show on Skip Back** setting enabled on supported tvOS versions, skipping back 10 seconds can temporarily show captions. This behaviour has been checked on Apple TV. |
| **Skip intro and recap** | Native contextual buttons use BBC-supplied timings matched to the version actually playing. Buttons appear only during a supplied skip interval. |
| **Received-quality badge** | Shows an outlined 4K, FHD, HD or SD badge beside the episode metadata in the playback controls. The 4K label requires a received picture of at least 2160p; it does not infer HDR from BBC catalogue flags. |
| **4K UHD category** | A saved UHD listing is available immediately. Beeb refreshes BBC’s UHD webpage daily, keeps cached discoveries, and checks episode-level availability when you open a programme. No full-catalogue episode scan. |
| **Search** | Search the full cached BBC programme catalogue by title and synopsis using the native Apple TV keyboard, iPhone keyboard or Siri Remote dictation where supported. |
| **Continue Watching and Up next** | Saves progress locally across launches. Resume an episode, start over, remove a show from the row or open the next episode after completion. |
| **Programme discovery** | Featured programmes, readable categories, continuous category/A–Z browsing, series selectors and ordered episode lists. Episodes load on demand rather than indexing the whole catalogue at launch. |
| **Saved programmes** | Bookmark a show and open its current available episodes later. |
| **Live channels on Top Shelf** | Move Beeb to the home screen’s top row, press Up to its landscape channel cards, then Select to start that channel directly. Play/Pause starts it too. Current programme artwork is cached, with a channel card fallback. |
| **RED additional streams** | During live TV, select RED beside Info to open Red Button or Red Button UHD. An unavailable additional feed leaves the current channel playing. The curated UHD event feed uses a rolling DASH-to-HLS bridge on Apple TV, without video transcoding, and is only available when BBC supplies a compatible live HLG event. It is separate from catch-up TwinVine setup. |
| **Live television** | BBC channel tiles show the scheduled programme's title and artwork. Live quality and subtitles depend on the supplied feed. |
| **Artwork suited to each view** | Plain promotional images for homepage banners, individual episode stills for episode cards, programme artwork for show listings, and clickable portrait-only posters in Stream Every Episode. Larger homepage cards omit redundant action text. |

## Screenshots

### 4K HDR with native playback controls

![Vigil playing in Beeb with the 4K HDR badge and native subtitle control visible](docs/screenshots/vigil-4k-hdr.png)

### Native subtitles during UHD playback

![Blue Lights playing with Apple's native subtitle rendering and Beeb's 4K HDR badge](docs/screenshots/blue-lights-native-subtitles.png)

<details>
<summary>Beeb on the Apple TV home screen</summary>

![Beeb's icon and Top Shelf artwork on the Apple TV home screen](docs/screenshots/apple-tv-home-screen.png)

</details>

## Install on Apple TV

### Choose your download

- **Public source ZIP:** build and sign through Xcode using the steps below.
- **Beeb-0.10.8-public-unsigned.ipa:** a prebuilt arm64 tvOS app, intended as a separate GitHub Release asset with a SHA-256 file. **Requires your own signing before installation.** Follow [the IPA signing/install guide](INSTALL-IPA.md). It contains no provisioning profile, developer signature or UHD identity.

Download the **[unsigned IPA and matching source ZIP from GitHub Releases](https://github.com/usefulappmaker/Beeb-public/releases/latest)**. The source ZIP intentionally excludes compiled binaries; the IPA is a separate release download.

### What you need

- A **Mac** with the full **Xcode** app and tvOS platform support compatible with your Apple TV's operating system. Command Line Tools alone are insufficient.
- An **Apple account** added to Xcode for signing your own installation.
- An **Apple TV HD or Apple TV 4K running tvOS 17+**, on the same local network as your Mac.
- Access to BBC services. Availability and service restrictions still apply.

**HD and live TV do not require TwinVine.** For UHD, also use Apple TV 4K, an HLG-compatible display/HDMI connection, suitable BBC content and your own working TwinVine iP configuration.

### Build, sign and run

1. On this repository's GitHub page choose **Code → Download ZIP**, then extract it. Open **BeebHD.xcodeproj** in Xcode.
2. In **Xcode → Settings → Accounts**, add your own Apple account.
3. Select **Signing & Capabilities** for both **BeebHD** and **BeebTopShelf**, enable **Automatically manage signing**, and choose your own **Team**. The public project intentionally has no team selected.
4. In the project’s **Build Settings**, set the user-defined **BEEB_APP_BUNDLE_IDENTIFIER** to your own unique value, such as `com.youralias.Beeb`, for Debug and Release. This sets the app identifier and the matching `.TopShelf` extension identifier together. Leave the app-specific Keychain entitlement in place.
5. On Apple TV open **Settings → Remotes and Devices → Remote App and Devices**. In newer Xcode, use **Xcode → Open Developer Tool → Device Hub → Pair Nearby Device → Apple TV**. In older Xcode use **Window → Devices and Simulators → Devices**. Select the TV and enter its displayed pairing code.
6. Choose the **BeebHD scheme** and your **physical Apple TV** as the run destination, then press **Command-R**. Xcode builds, signs, installs and launches **Beeb**.
7. Open an available programme and press the pink Play logo. Confirm HD playback works before adding UHD setup.

A free **Personal Team** requires periodic reprovisioning and has seven-day limits. When signing expires, Run from Xcode again. Paid developer profiles also expire. Keep your bundle identifier and team unchanged when updating to preserve access to the same app data and Keychain setup. See [Apple's account guidance](https://developer.apple.com/help/account/basics/about-your-developer-account).

For pairing details, update instructions and signing errors, see the full [installation guide](INSTALL.md). This source-install route requires a Mac; an unsigned IPA cannot simply be opened on Apple TV.

## Optional 4K HLG setup with TwinVine

**TwinVine is used for the one-time UHD authentication setup. After connecting, the Mac is not needed for playback.** Beeb fetches streams directly on Apple TV.

### 1. Prepare your own TwinVine iP configuration

Follow the upstream [TwinVine installation and configuration instructions](https://github.com/vinefeeder/TwinVine#installation), including initialising its **iP** service. You need your own working configuration containing a usable client certificate/private key and its configured User-Agent. Installing TwinVine alone does not guarantee that UHD access is available.

No client identity, private key or shared account is supplied in Beeb. Do not upload your TwinVine configuration or ask another installer to share theirs.

### 2. Prepare the Beeb setup helper

Install **Python 3.10+** if needed. In Terminal, open the extracted Beeb folder and run:

```sh
chmod +x ./*.sh ./*.command scripts/*.py
python3 -m venv .venv-setup
.venv-setup/bin/python -m pip install -r scripts/requirements-setup.txt
```

This installs the helper's dependencies into a local virtual environment.

### 3. Check your configuration

For TwinVine installed at `~/TwinVine`:

```sh
./setup-uhd.command --check
```

For a different installation folder:

```sh
TWINVINE_DIR="$HOME/Apps/TwinVine" ./setup-uhd.command --check
```

Replace the example path with your own. The helper supports direct and remote-repository iP service layouts. If discovery fails or finds multiple configurations, supply the exact file:

```sh
./setup-uhd.command --config "$HOME/Apps/TwinVine/packages/envied/src/envied/services/iP/config.yaml" --check
```

This check validates the local configuration and matching certificate/key without starting a server or displaying credentials. Only a real playback request can establish whether BBC currently accepts the identity.

### 4. Transfer setup to Apple TV

1. Run the same helper command **without `--check`**, keeping any custom path arguments. For the default location:

   ```sh
   ./setup-uhd.command
   ```

2. Leave Terminal open. It prints a complete one-time HTTPS setup URL, normally valid for 15 minutes. Keep it private and do not open it in a browser.
3. In **Beeb → Settings → 4K HLG · TwinVine**, focus **One-time setup URL** and enter the complete link. The iPhone Apple TV Remote keyboard is a convenient way to paste it.
4. Choose **Connect TwinVine** and allow local-network access if asked.
5. Wait for **UHD identity connected**. The helper stops after transfer; the Mac can now be switched off.

The transfer uses pinned TLS. Beeb retains the setup package and metadata in device-only Keychain storage. Never share the setup URL: it contains the one-use token needed to retrieve the identity.

### 5. Check UHD playback

Choose a currently available UHD-listed episode and press Play. Show the player controls and check for **4K**. A catalogue badge describes advertised availability; the playback badge reflects the received stream. If UHD is unavailable or your identity is not accepted, Beeb can fall back to HD.

For local-network/interface problems, explicit config paths, expired links and identity renewal, follow [SETUP-UHD.md](SETUP-UHD.md) and [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Catalogue updates and 4K browsing

Use **Settings → Display 4K UHD category** to show or hide this category in the topbar/sidebar and Browse. It is enabled by default and does not change TwinVine setup or playback quality.

Open **Browse → Categories → 4K UHD** to see programmes with UHD-listed episodes. Opening a programme from this category selects a season with UHD episodes when available, while showing every episode in the season. Individual 4K episodes have a badge. The received playback quality can still fall back to HD if UHD is unavailable or your setup is not accepted.

The app includes a public metadata snapshot so 4K browsing and Search work immediately. While Beeb is open, the UHD index refreshes once daily from the [BBC’s UHD programme page](https://www.bbc.co.uk/iplayer/help/questions/programme-availability/uhd-content). This downloads one webpage, merges its programme links with saved UHD discoveries, and caches the result. Beeb no longer scans every programme’s episode lists in the background. Individual episode availability is checked when you open a programme, and UHD discoveries made during normal browsing are saved automatically. No Mac or hosted indexing service is required.

Search covers the full cached A–Z programme catalogue, including films, rather than just viewed programmes. Its separate daily refresh downloads programme listing pages without fetching each programme’s episodes. Results match programme titles and synopses; this is not a full-text search of every individual episode subtitle. Dictation and the iPhone keyboard depend on the Apple TV’s system settings and remote/device support.

**Check for updates** in the UHD category refreshes the BBC UHD webpage. Failed updates retain saved listings and retry later. Refresh timestamps are stored internally; the category keeps its interface minimal. This is an editorial index plus cached discoveries, so it is not guaranteed exhaustive or a promise that every episode is currently UHD. BBC metadata, regional availability and live UHD events can differ from the on-demand catalogue. Actual 4K/HDR delivery is checked during playback, and no TwinVine credentials are part of the catalogue cache or bundled snapshot.

## How playback works

Beeb is written in **Swift and SwiftUI**, using **AVPlayer/AVKit** for playback. HD stream discovery adapts get_iplayer's request and selection logic; optional UHD authentication follows TwinVine's iP service.

For supported UHD presentations, Beeb translates the BBC's static **MPEG-DASH** manifest into local **HLS** playlists. A small on-device bridge normalises fragment padding while preserving encoded samples, timing and HLG metadata. Video is not transcoded. This works around the delivery-format mismatch; it does not add general native DASH support to tvOS.

BBC **TTML captions become segmented WebVTT** advertised as a real HLS subtitle rendition. Apple's player renders them. A caption fetch failure does not deliberately downgrade an already selected UHD stream.

## Limits and local data

- No offline downloads or BBC account/history synchronisation.
- Saved programmes and watch progress stay locally in the app.
- UHD depends on the actual episode/version, compatible equipment and an accepted identity.
- Dynamic, multi-period and protected DASH presentations are not supported by this bridge.
- BBC services and TwinVine's configuration can change independently of this project.
- The public source contains no preconfigured signing team or UHD credentials. Each installer signs their own build.

## Build, tests and contribution

[Developer build/test commands](DEVELOPMENT.md) · [Validation scope](VALIDATION.md) · [Release checks](RELEASE-CHECKS.md) · [Source publishing guide](PUBLIC-RELEASE.md)

When reporting a problem, include the app/tvOS version, device model, public programme URL and a redacted error description. Keep certificates, private keys, setup links, signing profiles, device identifiers and signed stream URLs out of issues and logs.

## Licence and acknowledgements

Beeb is distributed under **[GPL-3.0-or-later](LICENSE.txt)**. Stream-discovery work adapts **get_iplayer 3.36**; the UHD access flow follows **TwinVine's iP service**, by stabbedbybrick. See [NOTICE.md](NOTICE.md) for attribution and details. Programme images and video belong to their respective rights holders; screenshots document the app's interface and playback.
