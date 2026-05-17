# Fluxer Nix Flake

[![Fluxer Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.fluxer.app%2Fdl%2Fdesktop%2Fstable%2Flinux%2Fx64%2Flatest&query=%24.version&label=stable&color=blue&logo=fluxer)](https://fluxer.app)
[![Canary Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.fluxer.app%2Fdl%2Fdesktop%2Fcanary%2Flinux%2Fx64%2Flatest&query=%24.version&label=canary&color=purple&logo=fluxer)](https://fluxer.app/canary)
[![Update Status](https://img.shields.io/github/actions/workflow/status/Hy4ri/fluxer-flake/update.yml?label=auto-update)](https://github.com/Hy4ri/fluxer-flake/actions/workflows/update.yml)

---

## What is Fluxer?

[Fluxer](https://fluxer.app) is a modern communication platform for friends, groups, and communities — built for real-time messaging, voice and video calls, and rich media sharing. It is fully self-hostable and available under the AGPL-3.0 license.

This flake packages the [Electron desktop client](https://github.com/fluxerapp/fluxer) for Linux, offering two channels:

| Package | Description | Platforms |
|---------|-------------|-----------|
| `fluxer` | Stable desktop client | Linux (x86_64, aarch64) |
| `fluxer-canary` | Canary desktop client | Linux (x86_64, aarch64) |

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

## License

This flake packaging is provided under the **AGPL-3.0** license.

Fluxer itself is also licensed under AGPL-3.0. Refer to the [Fluxer repository](https://github.com/fluxerapp/fluxer) for details.
