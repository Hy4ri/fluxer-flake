# Fluxer Nix Flake

[![Fluxer Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.fluxer.app%2Fdl%2Fdesktop%2Fstable%2Flinux%2Fx64%2Flatest&query=%24.version&label=stable&color=blue&logo=fluxer)](https://fluxer.app)
[![Canary Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.fluxer.app%2Fdl%2Fdesktop%2Fcanary%2Flinux%2Fx64%2Flatest&query=%24.version&label=canary&color=purple&logo=fluxer)](https://fluxer.app/canary)
[![Update Status](https://img.shields.io/github/actions/workflow/status/Hy4ri/fluxer-flake/update.yml?label=auto-update)](https://github.com/Hy4ri/fluxer-flake/actions/workflows/update.yml)

Nix flake for [Fluxer](https://fluxer.app) — a free and open source instant messaging and VoIP platform.  
Provides reproducible, declarative packaging of Fluxer for NixOS, Home Manager, and `nix run`.

---

## What is Fluxer?

[Fluxer](https://fluxer.app) is a modern communication platform for friends, groups, and communities — built for real-time messaging, voice and video calls, and rich media sharing. It is fully self-hostable and available under the AGPL-3.0 license.

This flake packages the [Electron desktop client](https://github.com/fluxerapp/fluxer) for Linux, offering two channels:

| Package | Description | Platforms |
|---------|-------------|-----------|
| `fluxer` | Stable desktop client (v0.0.8) | Linux (x86_64, aarch64) |
| `fluxer-canary` | Canary desktop client (v0.0.225) | Linux (x86_64, aarch64) |

---

## Prerequisites

- **Nix** with [flakes](https://nixos.wiki/wiki/Flakes) enabled
- **Linux** (x86_64 or aarch64)
- *(Optional)* [NixOS](https://nixos.org/) or [Home Manager](https://github.com/nix-community/home-manager) for declarative installation

---

## Quick Start

Try Fluxer immediately without installing permanently:

```bash
# Run the stable desktop client
nix run github:Hy4ri/fluxer-flake

# Run the canary desktop client
nix run github:Hy4ri/fluxer-flake#fluxer-canary
```

> **Note:** Replace `Hy4ri` with the GitHub username or organization that hosts this flake.

---

## Installation

### 1. Add the Flake Input

In your NixOS configuration or Home Manager flake:

```nix
{
  inputs.fluxer.url = "github:Hy4ri/fluxer-flake";
}
```

### 2. Choose an Overlay Strategy

#### A) Default overlay (both packages)

```nix
# NixOS (configuration.nix)
nixpkgs.overlays = [ inputs.fluxer.overlays.default ];

# Home Manager
home-manager.users.<user>.nixpkgs.overlays = [ inputs.fluxer.overlays.default ];
```

Then install:

```nix
# NixOS
environment.systemPackages = [ pkgs.fluxer pkgs.fluxer-canary ];

# Home Manager
home.packages = [ pkgs.fluxer pkgs.fluxer-canary ];
```

#### B) Individual overlays (only what you need)

```nix
nixpkgs.overlays = [ inputs.fluxer.overlays.fluxer ];       # stable only
nixpkgs.overlays = [ inputs.fluxer.overlays.fluxer-canary ]; # canary only
```

### 3. Direct Package Reference (Without Overlays)

```nix
{
  inputs.fluxer.url = "github:Hy4ri/fluxer-flake";

  outputs = { self, nixpkgs, fluxer }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            fluxer.packages.${pkgs.system}.fluxer
            fluxer.packages.${pkgs.system}.fluxer-canary
          ];
        })
      ];
    };
  };
}
```

---

## Verifying the Installation

```bash
# Check that the binary runs
nix run github:Hy4ri/fluxer-flake

# Or if installed locally
fluxer --help
fluxer-canary --help
```

---

## Updating

### Automatic Updates (CI)

This flake includes a **GitHub Actions workflow** that checks for new Fluxer releases every day at 17:00 UTC. When a new version is detected, it:

1. Fetches the latest version from the [Fluxer API](https://api.fluxer.app)
2. Downloads the `.deb` binaries and computes SHA-256 hashes
3. Updates `version.json`, `fluxer.nix`, and `fluxer-canary.nix`
4. Commits and pushes the changes automatically

The workflow also supports **manual triggering** from the GitHub Actions tab.

### Manual Update

```bash
# Update to the latest versions (both channels)
./update-version.sh
```

The script will:
1. Fetch current versions from the Fluxer API
2. Download `.deb` binaries for all architectures (stable downloads are hashed locally; canary hashes come from the API)
3. Compute SRI-format hashes and update the Nix expressions
4. Update `version.json`

After running, commit the changes:

```bash
git add version.json fluxer.nix fluxer-canary.nix
git commit -m "chore: update fluxer versions"
```

---

## Project Structure

```
.
├── flake.nix               # Flake entry point: packages, overlays, outputs
├── fluxer.nix              # Package derivation for the stable desktop client
├── fluxer-canary.nix       # Package derivation for the canary desktop client
├── version.json            # Current versions for both channels
├── update-version.sh       # Script to fetch new releases and update hashes
├── .github/
│   └── workflows/
│       └── update.yml      # GitHub Actions: daily auto-update workflow
├── .gitignore
└── README.md
```

### Key Files Explained

| File | Purpose |
|------|---------|
| `flake.nix` | Defines the flake's inputs (nixpkgs unstable), supported systems (x86_64, aarch64 Linux), packages, and overlays. Sets `allowUnfree = true` since Fluxer binaries are proprietary-built. |
| `fluxer.nix` | Derivation that extracts the `.deb` package, wraps the Electron binary with all required library paths (Alsa, CUPS, GL, Wayland, X11, etc.), sets up desktop icons, and creates the `fluxer` launcher. |
| `fluxer-canary.nix` | Same as `fluxer.nix` but for the canary channel — separate app ID, binary name, desktop entry, and hash set. |
| `version.json` | Single source of truth for both channel versions. Both derivations read from this file. |
| `update-version.sh` | Automation script that fetches release metadata, downloads binaries, computes SRI hashes, and wires everything into the Nix expressions. |

---

## Troubleshooting

### "Unsupported system" error

Fluxer desktop is **Linux-only** with `x86_64-linux` and `aarch64-linux` support.

### Hash mismatch during build

If you see a hash mismatch, the version in `version.json` may be stale. Run `./update-version.sh` to refresh.

### `autoPatchelfHook` warnings

Some non-critical shared library warnings may appear during the build — these are typically harmless. The derivation includes a comprehensive set of `buildInputs` covering all known Electron and Fluxer native module dependencies.

### Desktop app won't launch

If the app fails to start, check that required system libraries are available. The derivation wraps the binary with `LD_LIBRARY_PATH`, but Wayland/X11 session components may need additional configuration:

```bash
# Test from the command line
nix run .#fluxer

# Check for missing libraries
nix run .#fluxer -- --no-sandbox  # if sandboxing is an issue
```

### `nix run` doesn't find the package

Ensure you're using the correct attribute path:

```bash
# Default (stable)
nix run github:Hy4ri/fluxer-flake

# Canary
nix run github:Hy4ri/fluxer-flake#fluxer-canary

# Local
nix run .#fluxer
nix run .#fluxer-canary
```

---

## License

This flake packaging is provided under the **AGPL-3.0** license.

Fluxer itself is also licensed under AGPL-3.0. Refer to the [Fluxer repository](https://github.com/fluxerapp/fluxer) for details.
