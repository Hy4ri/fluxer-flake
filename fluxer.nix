{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libgbm,
  libX11,
  libXcomposite,
  libXcursor,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libxkbcommon,
  libXrandr,
  libXrender,
  libXScrnSaver,
  libXt,
  libXtst,
  libxcb,
  libuuid,
  libxml2,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  wayland,
  vulkan-loader,
  libpulseaudio,
  libkrb5,
  xdg-utils,
  libsecret,
  libnotify,
  libva,
}@args:

import ./mkFluxer.nix (args // {
  pname = "fluxer";
  channel = "stable";
  version = (builtins.fromJSON (builtins.readFile ./version.json)).stable;
  extractDir = "Fluxer";
  hashMap = {
    x86_64-linux = "sha256-sOHwWDW8m7lLJQD5CxlyG+fw2w1TNs5oRoWtyrWteE4="; # deb-x64
    aarch64-linux = "sha256-5ei4RNPvKIy6Uxs6f9cVX0tE3LjhQ4Ey7rpkchsT0es="; # deb-arm64
  };
})
