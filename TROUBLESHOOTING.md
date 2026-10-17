# Troubleshooting

| Problem | What to check |
| --- | --- |
| “Signing requires a development team” | Choose your own account/team on the BeebHD target. Public source has none selected. |
| Bundle identifier unavailable | Replace the template ID with your own unique value. Apply it consistently to build configurations. |
| Apple TV not discovered | Same LAN, Remote App and Devices screen open, local-network permission, IPv6/device discovery enabled; avoid guest isolation. See INSTALL.md for the two Xcode pairing interfaces. |
| Apple TV unavailable as a destination | Install matching tvOS platform support, finish pairing/device preparation and use compatible Xcode. |
| App stops launching days later | Renew its provisioning by running from Xcode again. Personal Team signing is temporary. Keep the same bundle ID/team. |
| Command line says Xcode is missing | Install full Xcode. For a nonstandard location, set DEVELOPER_DIR to that Xcode app's Contents/Developer folder. |
| No programmes or playback unavailable | Check ordinary BBC availability/network access. Test another episode/channel. BBC service changes can affect this independent client. |
| UHD-labelled episode plays HD | Confirm the identity is connected, the BBC currently offers a compatible rendition, and your own certificate remains accepted. Catalogue availability is distinct from received quality. |
| Setup helper Python/dependency error | Create .venv-setup using SETUP-UHD.md; avoid global pip. |
| No iP config found | Initialise your own TwinVine iP service or supply --config. A fresh TwinVine checkout is not a guarantee of usable UHD credentials. |
| Setup times out | Check private IPv4 address, same network and Python's firewall access; restart helper for a fresh complete URL. |
| Captions absent | Select English in native controls; check this version has captions. Live captions depend on the feed. |
| Automatic captions on rewind absent | Enable Show on Skip Back in Apple TV's Automatic Subtitles settings on a supported tvOS version; check a subtitle track is available. |
| No Skip intro/recap button | BBC must supply a matching marker for the actual playing version, and playback must be within its interval. |

When reporting a bug, include app version, tvOS/Xcode version, device model, public programme URL and a redacted error description. Remove setup URLs/tokens, certificate/private-key contents, provisioning profiles, device IDs, email addresses, local user paths and signed playback URLs. Never upload your TwinVine configuration or an entire device/Xcode log without inspecting it.
