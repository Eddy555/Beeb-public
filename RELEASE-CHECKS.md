# Public edition verification

## Current release: 0.10.7 (28)

- Unsigned physical-device tvOS Release build passed; the app and Top Shelf extension both use version 0.10.7 (28), with distinct public bundle identifiers.
- Both executables are arm64 and contain no code-signature load command. The IPA contains no provisioning profiles, AppleDouble entries or detected private account paths/key markers. Archive integrity and SHA-256 verification passed.
- Original sectioned Top Shelf provider restored; purple-background prototype excluded. Regional feed preferences remain active when a channel starts.
- Latest simulator checks cover Info dismissal and immediate second-Back exit, speed selection, regional settings, and Reduce Loud Sounds selection persistence. Enhance Dialogue was not available in that simulator and is not claimed as a new feature.
- Source privacy/release checks and matching-source packaging are required before publication. No new physical-device installation of 0.10.7 is claimed.

## Historical 0.8.2 preparation checks

- Known private-installer names, account/team/certificate identifiers, original bundle namespace and absolute account paths absent from the public source tree in the preparation audit.
- Source-only release checker: no selected signing team, prohibited artefact types, local account paths, detected key/token patterns, symlinks or unreviewed PNG metadata.
- Xcode project property-list syntax and shell syntax.
- All 12 shipped PNG pixel streams match the original runtime assets; only ancillary metadata was removed. Asset catalogue image references resolve.
- Swift playback sources match 0.8.2 apart from replacing the private app/Keychain namespace with the public template namespace. Catalogue/discovery artwork selection is updated separately: plain homepage banners, episode-specific stills, and a fresh discovery cache namespace.
- Resolver parsing, URL handling, quality selection and selector filtering.
- History persistence, completion/Up next, ordering, removal and corruption recovery.
- Automatic UHD priority, HD fallback, cancellation/error handling and quality badges.
- Version-specific skip markers, HDR/duration metadata, caption parsing/timing, subtitle discovery fixtures and live schedule boundaries.
- Catalogue pagination, ordering, lightweight launch/cache and saved-programme migration.
- Artwork regression checks: distinct episode stills override a shared show logo; missing stills fall back gracefully; homepage banners use plain promotional/default images at the large recipe and never a logo-only fallback. Catalogue/lifecycle/saved-programme and playback-extras suites passed again after the artwork change.
- UHD metadata, codec/range validation, protected-source rejection and unavailable-service handling.
- Offline DASH parser, HLG signalling, protection rejection, range parsing and fragment-padding normalisation subset.
- Three provisioning-helper tests: config discovery/ambiguity, malformed inputs/header injection, and synthetic valid/expired/mismatched certificate-key pairs with no secret output or server startup.
- Three release-boundary tests: reject profiles/selected teams/local paths; exclude builds/Git/environments; reject symlinks.

## Additional installation verification

- A full signed Release archive of the updated public source built successfully after the earlier environment restrictions were removed. Signing team, unique bundle identifier and a separate home-screen display name were supplied as local build overrides; they are not stored in this public project or source archive.
- Installation on a paired physical Apple TV succeeded, and the installed-app list confirmed the separate app alongside the existing installation. Foreground launch was denied because the Apple TV was asleep, so launch and physical playback remain unverified in this installation check.
- Full DASH HTTP loopback/range and padded-fragment regression tests passed after local socket access became available.
- Local signed archives, profiles, build logs and device identifiers remain outside the public source tree. No personally signed IPA is supplied for distribution.

## Unsigned prebuilt release

- Release build from a clean temporary source directory succeeded with code signing disabled, using the public template bundle identifier.
- The initial 0.8.2 unsigned IPA contained the main tvOS app without a Top Shelf extension. The current release also includes the unsigned Top Shelf extension described above. No provisioning profile, code signature, signing certificate or bundled UHD identity is supplied.
- codesign confirmed the app is not signed; executable load commands contain no code signature. The app targets physical arm64 Apple TV devices, with tvOS 17 minimum deployment.
- All payload files were scanned for the original installer's known personal names, account/team/certificate identifiers, original private bundle ID and personal account paths: no matches found. ZIP metadata uses neutral timestamps and no owner extras.
- SHA-256 accompanies the IPA. Matching source is supplied separately under the project licence. The unsigned IPA has not been installed directly, because normal Apple TV installation requires signing first.
- Third-party re-signing instructions are based on upstream documentation. That workflow has not been tested end to end on a new user's account. Xcode source installation remains the documented fallback.

## Not performed

- Signing/provisioning with an unrelated new installer's Apple account.
- Installation on an unrelated user's Apple TV.
- A fresh TwinVine installation, real credential transfer, or live BBC UHD authorisation on a new user's setup.

These require the installer's own account/device and, for UHD, their own accepted identity. Follow INSTALL.md and SETUP-UHD.md. See VALIDATION.md for historical playback evidence; do not describe those earlier results as new public-edition device testing.
