{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  gsettings-desktop-schemas,
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
  hunspell,
  libfido2,
}@args:

import ./mkFluxer.nix (args // {
  pname = "fluxer-canary";
  channel = "canary";
  version = (builtins.fromJSON (builtins.readFile ./version.json)).canary;
  extractDir = "fluxer-canary";
  hashMap = {
    x86_64-linux = "sha256-B4oqu+10V7i2GVF5Ix3Ir/Bti3UOxOZ4E/VWb8pAerY="; # canary-deb-x64
    aarch64-linux = "sha256-QZr7Y7E+mRekCVUFyUCWmWrRth9RF66cgk3W0HjLupU="; # canary-deb-arm64
  };
  extraRuntimeLibs = [ hunspell libfido2 ];
})
