# Build and test

Use full Xcode with tvOS support. The project uses no external Swift packages. The build respects DEVELOPER_DIR. Users should follow INSTALL.md for signing and physical installation.

If the scripts are not executable after downloading from GitHub, run this once from the project folder:

```sh
chmod +x ./*.sh ./*.command scripts/*.py
```

## Unsigned device build

```sh
./build.sh
```

Creates build/BeebHD-unsigned.ipa. It still requires signing for an intended Apple TV; it is not a universal installer.

For public distribution, build in a neutral path outside your personal account directory, audit the entire IPA and verify that codesign reports no signature. The supplied release was built from a clean temporary source copy, then packaged with neutral ZIP metadata. Check future binaries independently:

```sh
python3 scripts/check-unsigned-ipa.py build/BeebHD-unsigned.ipa
```

The prebuilt release asset is named Beeb-0.8.2-public-unsigned.ipa and is distributed separately from the source ZIP with a SHA-256 checksum. The structural check cannot detect every possible identifying string; perform an additional private-identifier audit before publishing.

## Signed archive

Supply your own values, never a maintainer's identity:

```sh
APPLE_TEAM_ID=YOUR_TEAM_ID BEEB_BUNDLE_ID=com.youralias.Beeb ./build.sh
```

Keep generated archives and signing profiles out of the public repository.

## Tests

```sh
./test.sh
./test-history.sh
./test-playback-policy.sh
./test-playback-extras.sh
./test-catalogue.sh
./test-uhd.sh
./test-dash.sh
python3 Tests/test_public_release.py
.venv-setup/bin/python Tests/test_setup_helper.py
```

The final helper test requires the optional Python environment from SETUP-UHD.md. Tests use fixtures except explicit live modes. The DASH suite opens loopback sockets; it cannot run fully in a sandbox that denies local listeners. See VALIDATION.md and RELEASE-CHECKS.md for completed checks and limitations.

## Check and package public source

```sh
python3 scripts/check-public-release.py
python3 scripts/make-public-archive.py
```

The source ZIP is created under dist/. No upload is performed. See PUBLIC-RELEASE.md for Git identity and publication checks.
