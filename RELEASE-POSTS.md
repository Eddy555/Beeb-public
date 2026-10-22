# Social post drafts

Replace `[GITHUB_UPDATE_URL]` / `GITHUB_UPDATE_URL` with the published update URL before posting, and attach the revised Beeb 0.10.8 banner. These drafts have not been posted.

## Twitter / X

Beeb 0.10.8 for Apple TV: Classic or Modern homescreens, topbar/sidebar choices, live subtitles, RED streams, cleaner categories, continuous browsing, better Back navigation and playback fixes.

Unsigned IPA + open source: [GITHUB_UPDATE_URL]

## Reddit

**Title:** Beeb 0.10.8: new homescreen layouts, live subtitles and Red Button streams for Apple TV

I've put together another update to Beeb, my independent, open-source BBC player for Apple TV. The graphic shows what's changed since the last public release, **0.10.7**:

- **New homescreen layouts:** choose **Classic** or **Modern** in Settings. Modern gives you a floating **Topbar** or a **Sidebar**. Classic keeps the earlier compact topbar and framed banner.
- **Immersive modern homescreens:** large programme artwork and Beeb's pink focus glow. The navigation and banner scroll away as you move down into programme rows.
- **Your preference is remembered:** Settings → Homescreen Layout. The Topbar/Sidebar choice appears under Modern and is retained when you switch to Classic and back.
- **Press the RED button:** it's an option in every live player's controls. Open **Red Button** or **Red Button UHD** when BBC is broadcasting those feeds. If an additional feed is unavailable, your current channel keeps playing.
- **Live TV subtitles:** BBC's live captions now work through Apple's native subtitle rendering and controls. I've checked them on Apple TV; availability depends on the channel supplying captions.
- **Continuous browsing:** scroll through categories, A–Z and the indexed 4K UHD listing without Previous/Next buttons. Programme batches load as needed rather than loading everything at launch.
- **A cleaner Browse screen:** wider, readable category cards with icons.
- **Better Back behaviour:** return to the previous screen, close the sidebar, or dismiss the Additional Streams menu without changing channel. There's also a Cancel button.
- **More reliable episode loading:** updated BBC playback discovery and version selection, fixing the incorrect-format error when opening some episodes.

**[GitHub update, unsigned IPA and source](GITHUB_UPDATE_URL)**

The IPA uses the regular Beeb icon, with no TEST label. **You'll need to sign it yourself before installing**, including the bundled Top Shelf extension. Matching source and signing/setup instructions are included. Keep your existing app identifier and signing setup when updating if you want to retain app data.

The existing 4K HLG HDR playback, Search, programme Info, Continue Watching, Top Shelf, regional feeds and other features are still there. **TwinVine remains optional for catch-up UHD setup; HD and normal live TV don't need it.** Red Button UHD is a separate, event-dependent live feed, not a permanent UHD simulcast.

Beeb is unofficial and isn't affiliated with or endorsed by the BBC. Feedback is welcome, especially on which homescreen layout you prefer.
