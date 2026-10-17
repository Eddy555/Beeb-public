# Optional one-time 4K HLG setup

Install Beeb and verify HD first: [INSTALL.md](INSTALL.md). UHD needs compatible BBC content, Apple TV 4K, an HLG-capable display connection and **your own working TwinVine iP configuration**. This repository does not provide a client certificate, private key or shared login. Without those prerequisites, HD remains available.

## 1. Prepare your own TwinVine installation

Use the upstream [TwinVine installation guide](https://github.com/vinefeeder/TwinVine#installation). Its services and layout can change independently of Beeb. A typical checkout uses `uv sync` and `uv run envied --help` to initialise the environment/services. Follow upstream instructions for its configuration and iP service. Beeb does not need the unrelated downloader, DRM/CDM or proxy features during playback.

The Beeb helper supports these iP config locations beneath the TwinVine folder:

```text
packages/envied/src/envied/services/_repos/<service-checkout>/iP/config.yaml
packages/envied/src/envied/services/iP/config.yaml
```

You can also supply the exact file with `--config`. It must contain a `certificate` field (base64 of the PEM client certificate and matching unencrypted private key) and a nonempty single-line `user_agent` field. Use your existing service configuration; do not paste it into issues, chats or this repository. The helper validates the certificate/key pair and validity period, but only the BBC can determine whether it accepts the identity. Initialising TwinVine alone does not guarantee that a usable iP identity is available. If it is missing, obtain/configure it through the upstream service's supported setup; do not request a maintainer's personal identity.

## 2. Create a small setup-helper environment

The helper can run without depending on TwinVine's Python environment. In Terminal, type `cd `, drag the extracted Beeb folder onto the Terminal window, then press Return. With Python 3.10 or later installed, run:

```sh
chmod +x ./*.sh ./*.command scripts/*.py
python3 -m venv .venv-setup
.venv-setup/bin/python -m pip install -r scripts/requirements-setup.txt
```

This installs PyYAML and cryptography into a private local virtual environment. No global Python packages are modified. Python can be obtained from [python.org](https://www.python.org/downloads/macos/). Keep `.venv-setup` out of Git; it is ignored by this project.

## 3. Check the configuration without transferring it

If TwinVine is at `~/TwinVine`:

```sh
./setup-uhd.command --check
```

Otherwise set its actual folder for this command:

```sh
TWINVINE_DIR="$HOME/Apps/TwinVine" ./setup-uhd.command --check
```

Or choose the exact configuration file:

```sh
./setup-uhd.command --config "$HOME/Apps/TwinVine/packages/envied/src/envied/services/iP/config.yaml" --check
```

Replace the example paths with your own. The check prints no certificate, private key, user-agent value or pairing token and does not contact BBC. An existing TwinVine `.venv/bin/python` is a fallback if `.venv-setup` is absent; `BEEB_SETUP_PYTHON` can select another interpreter with the required dependencies.

## 4. Start the one-time helper

Keep Mac and Apple TV on the same private local network. Run the same command **without `--check`**. For the default location:

```sh
./setup-uhd.command
```

Leave the Terminal open. It prints an HTTPS setup URL containing a certificate fingerprint and one-use token. Treat the complete URL as a secret: anyone who can reach that helper and has the URL could retrieve the setup package. Do not open it in a browser or post a screenshot containing it. The URL normally expires after 15 minutes and can be consumed once.

If the helper selects the wrong interface, choose your Mac's private LAN IPv4 address explicitly:

```sh
./setup-uhd.command --host 192.168.1.123
```

That address is an example. Find your actual address in macOS System Settings → Network → your connection → Details. Do not use `127.0.0.1` for an Apple TV on another device. Allow the Python helper through the macOS firewall for your private network if prompted; do not forward its port on your router.

## 5. Connect from Beeb

1. Open **Beeb → Settings → 4K HLG · TwinVine**.
2. Focus **One-time setup URL**. Paste the complete URL using the iPhone Apple TV Remote keyboard, or enter it with the available text-input method. An iPhone is convenient, not required by the protocol.
3. Choose **Connect TwinVine**. Allow Beeb local-network access if the system asks.
4. Wait for **UHD identity connected** and the message that playback runs directly on Apple TV. The helper stops after transfer; you can close Terminal and switch off the Mac.

The URL's fingerprint pins the local helper's TLS certificate. The identity and retained import package go into the app's device-only Keychain. No identity is bundled into the source or another installer's build.

## 6. Verify an actual UHD episode

Choose a currently available UHD-listed episode and press Play. The app tries compatible UHD, then HD. Show the player controls: **4K HDR** requires received 2160p video and HLG/PQ source signalling. A catalogue 4K label alone is not proof that playback selected UHD. Your TV's HLG/HDR information display can help confirm the physical output path.

If it plays in HD, check connected status, current episode availability, certificate validity and BBC access. A local setup check cannot guarantee BBC authorisation or UHD availability. Native subtitles can work with UHD; a caption failure does not deliberately select HD.

## Renewal, removal and troubleshooting

- Expired or already-used URL: stop/restart the helper for a new link.
- No config or multiple configs: pass `--config` for the intended iP file.
- Invalid/expired identity: update your own upstream setup, then reconnect. Do not share credentials in bug reports.
- Timeout: check the Mac address, same LAN, Python firewall permission and guest-network isolation.
- Setup lost after installing a different bundle ID/team: reconnect for that app. Keep the same identifier and team when updating.
- **Forget UHD identity** removes the app's setup records/identity reference; it does not revoke the certificate at the issuing service or delete TwinVine's local files.

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md). The integration supports tested static unprotected on-demand presentations, not arbitrary protected streams or guaranteed UHD for every episode.
