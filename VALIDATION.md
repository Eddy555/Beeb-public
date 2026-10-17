# Validation scope

The public source starts from Beeb 0.8.2. Playback code is preserved apart from the app/Keychain namespace changing to the public template identifier. No credentials or signing account are supplied. Public changes add install documentation, portable setup configuration discovery/validation, release checking and source packaging. Artwork selection now uses plain homepage banners and episode-specific standard stills; the discovery cache namespace is refreshed for this policy.

Original development tests covered native 3840×2160 HLG stream decoding, sustained playback/seeking, native BBC captions on UHD/Full HD, subtitle clock mapping, stream policy, history, discovery, DASH parsing and fragment normalisation. The stream tests used macOS AVPlayer; simulator tests covered native subtitle rendering and app interfaces. A user separately confirmed temporary subtitles after skipping back on Apple TV. These are historical results, not a new test of the public edition on another person's account/device.

The setup helper's --check validates local configuration shape, matching certificate/key and validity period without starting a server. It cannot confirm BBC authorisation. Unit tests use synthetic temporary identities and never a maintainer's credentials.

Current public-edition verification results are recorded in RELEASE-CHECKS.md. No fresh personal-account provisioning, physical Apple TV installation, TwinVine credential transfer or live BBC playback is implied by an unsigned build or offline test pass. Those steps must be verified by each installer on their own setup.
