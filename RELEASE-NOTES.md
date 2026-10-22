# Beeb 0.10.8 — homescreen choices, live captions and RED streams

Changes since public release 0.10.7:

- Added Settings → Display 4K UHD category, enabled by default. Turn it off to hide 4K UHD in Classic/Modern Topbar, Modern Sidebar and Browse categories; the preference is saved independently of TwinVine setup.
- Settings → Homescreen Layout: Classic or Modern. Modern offers Topbar or Sidebar and retains your preference.
- Immersive modern artwork and navigation that scroll away as you browse; Beeb's icon glows pink while its text remains white.
- Readable, icon-led category cards; continuous category and A–Z browsing; a single lazy grid for indexed UHD programmes.
- RED in every live player's controls, opening Red Button and Red Button UHD when available. An unavailable additional stream leaves the current channel playing.
- Native live subtitles using BBC's timed caption feed, confirmed working on Apple TV by the maintainer.
- Back navigation to the previous screen, sidebar dismissal, and native Cancel/Back in Additional Streams without changing channel.
- Current BBC episode discovery for more reliable HD/UHD loading and version selection.

## Downloads

- `Beeb-0.10.8-public-unsigned.ipa`: physical arm64 Apple TV, tvOS 17+. Sign both the app and the included Top Shelf extension using your own appropriate tvOS provisioning before installation. Standard Beeb icon; no TEST badge, signing profile or UHD identity.
- `Beeb-0.10.8-public-source.zip`: matching GPL source, Xcode project, instructions and optional TwinVine setup helper.
- Matching `.sha256` files.

Keep the same signing team and app identifier when updating to retain app/Keychain access. See INSTALL-IPA.md and INSTALL.md in the source package.

Catch-up UHD still needs your own working TwinVine setup. HD and normal live playback do not. Live Red Button UHD is event-dependent and only works when a compatible BBC event feed is supplied; it is separate from catch-up UHD setup. Channel/caption availability follows BBC's supplied feeds.

Unofficial, not produced or endorsed by the BBC. GPL-3.0-or-later; attribution is retained in NOTICE.md.
