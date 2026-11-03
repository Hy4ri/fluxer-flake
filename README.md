# Fluxer Nix Flake

[![Fluxer Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.fluxer.app%2Fdl%2Fdesktop%2Fstable%2Flinux%2Fx64%2Flatest&query=%24.version&label=stable&color=blue&logo=fluxer)](https://fluxer.app)
[![Canary Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.fluxer.app%2Fdl%2Fdesktop%2Fcanary%2Flinux%2Fx64%2Flatest&query=%24.version&label=canary&color=purple&logo=fluxer)](https://fluxer.app/canary)
[![Update Status](https://img.shields.io/github/actions/workflow/status/Hy4ri/fluxer-flake/update.yml?label=auto-update)](https://github.com/Hy4ri/fluxer-flake/actions/workflows/update.yml)

Run and install the [Fluxer](https://fluxer.app) desktop client on NixOS, Home Manager, or any Linux system with Nix.

Fluxer is an open-source, self-hostable chat platform for friends, groups, and communities, with messages, voice and video calls, and media sharing.

The flake is updated automatically every day.

## Packages

| Package | What it is | Command |
|---|---|---|
| `fluxer` (default) | Stable desktop client | `fluxer` |
| `fluxer-canary` | Canary (preview) desktop client | `fluxer-canary` |

Platforms: Linux `x86_64` and `aarch64`.

## Try it without installing

You need Nix with [flakes enabled](https://wiki.nixos.org/wiki/Flakes).

```bash
nix run github:Hy4ri/fluxer-flake                 # stable
nix run github:Hy4ri/fluxer-flake#fluxer-canary   # canary
```

## Install

There are **two ways** to install. **Pick one.** They give the same result.

| Option | Use it when |
|---|---|
| **A. Overlay** | You want to write `pkgs.fluxer`, like any other nixpkgs package. |
| **B. Direct package** | You do not want to use overlays. |

### Step 1: Add the flake input (needed for both options)

In your system `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fluxer.url = "github:Hy4ri/fluxer-flake";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; }; # lets your modules use `inputs`
      modules = [ ./configuration.nix ];
    };
  };
}
```

> Already have a flake? Add only the `fluxer.url` line, and make sure `inputs` reaches your modules (`specialArgs` for NixOS, `extraSpecialArgs` for Home Manager).

### Step 2, Option A: Overlay

In `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
{
  nixpkgs.overlays = [ inputs.fluxer.overlays.default ];

  environment.systemPackages = [
    pkgs.fluxer
    # pkgs.fluxer-canary
  ];
}
```

For Home Manager, keep the overlay line and use `home.packages = [ pkgs.fluxer ];` instead.

Want only one channel in `pkgs`? Use `overlays.fluxer` or `overlays.fluxer-canary` instead of `overlays.default`.

### Step 2, Option B: Direct package

In `configuration.nix`:

```nix
{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    inputs.fluxer.packages.${pkgs.stdenv.hostPlatform.system}.fluxer
    # inputs.fluxer.packages.${pkgs.stdenv.hostPlatform.system}.fluxer-canary
  ];
}
```

For Home Manager, put the same line in `home.packages`.

### Step 3: Rebuild

```bash
sudo nixos-rebuild switch --flake .#myhost
```

## Updates

A GitHub Action checks for new Fluxer releases every day, tests the build, and commits the new version. To get it, update your lock file:

```bash
nix flake update fluxer
```

## License

This flake packaging is provided under the AGPL-3.0 license. Fluxer itself is also AGPL-3.0. Refer to the [Fluxer repository](https://github.com/fluxerapp/fluxer) for details.

## Support

If this flake helps you, you can support my work on [GitHub Sponsors](https://github.com/sponsors/hy4ri) or [Ko-fi](https://ko-fi.com/m_5_7). A star on the repo also helps.
