# Changes

## 0.10.7 (build 28), compared with public release 0.8.2

### Browse and discover

- Added a minimal Search tab covering the cached BBC A–Z programme catalogue, matching titles and synopses. Uses the native Apple TV keyboard, with dictation and the iPhone keyboard where supported.
- Added a 4K UHD category backed by a bundled snapshot, cached discoveries and a daily refresh of BBC's UHD webpage. Replaces the earlier full-catalogue episode scan. The BBC editorial list is not guaranteed to include every currently available UHD programme.
- Programme pages opened from 4K UHD retain all seasons and episodes; individual UHD episodes are tagged rather than hiding the HD episodes.
- Larger homepage banner with less image cropping, left/right remote navigation, no arrow buttons or page counter, and consistent spacing before Continue Watching.
- Larger homepage programme cards without redundant “Explore programme” text or episode-count lines. Stream Every Episode uses clickable portrait-only posters.
- Removed extra UHD episode counts, explanatory text and refresh timestamps from the UHD listing.

### Watch

- Added an Info button showing programme/episode title, thumbnail, full synopsis, original broadcast date, runtime, quality and guidance where provided by the BBC.
- Replaced the native expanding-summary path that caused Info freezes/watchdog crashes with a bounded, scrollable description card. Removed redundant date/runtime text, the duplicate year above the title and the Close Info button.
- Back hides Info or playback controls; a second immediate Back exits playback.
- Added native on-demand playback speeds: 0.5×, 0.75×, 1×, 1.25×, 1.5× and 2×.
- Received-quality badges now read 4K, FHD (1080p), HD (720p) or SD. Kept the outlined style, improved contrast and spacing beside episode metadata, and removed the redundant live-text suffix. The 4K badge reports resolution, not HDR status; compatible HLG HDR playback remains supported.

### Live TV and installation

- Added landscape live-channel cards to Apple TV Top Shelf: place Beeb in the top row, press Up, then select a channel to start playback. Includes current programme artwork with channel fallback cards.
- Added Settings choices for 16 BBC One regions and three BBC Two feeds, applied when starting channels from Live or Top Shelf. Top Shelf artwork still uses the default channel schedule.
- Included the Top Shelf extension in the unsigned IPA, with matching version/build and separate bundle identifier.
- Removed AppleDouble/Finder ZIP metadata that could cause an extension installation error. Updated public release checks and signing guidance.

### Existing features retained

4K HLG HDR using your own TwinVine UHD setup; automatic HD fallback; native English subtitles including Show on Skip Back where supported; skip intro/recap where BBC timings exist; Continue Watching, Up next, bookmarks and live TV.

Native audio menus remain in use. Reduce Loud Sounds selection was checked in the simulator; Enhance Dialogue was not available there and is not advertised as a new Beeb capability. Availability depends on tvOS and the supported audio setup.

## 0.8.2

Initial public GitHub release, with matching source and an unsigned tvOS IPA. Included UHD playback, native subtitles, intro/recap skipping, local viewing history, saved programmes, live channels, logo-free banners and individual episode artwork where available.
