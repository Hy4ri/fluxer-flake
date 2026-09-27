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
}@args:

import ./mkFluxer.nix (args // {
  pname = "fluxer";
  channel = "stable";
  version = (builtins.fromJSON (builtins.readFile ./version.json)).stable;
  extractDir = "Fluxer";
  hashMap = {
    x86_64-linux = "sha256-22eHsP4xPR/f9nL+w7BoXX4nQISS0oiKw0QAKnlGl34="; # deb-x64
    aarch64-linux = "sha256-2+2tUOWBAo7KlbslN1/Ihd13TvLkiT3K5Gu+G/403T4="; # deb-arm64
  };
})
