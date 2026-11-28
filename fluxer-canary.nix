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
    x86_64-linux = "sha256-nuTJfH40R7ON2gkmz6wCz7wRbQqurjguGcWWcQxkTms="; # canary-deb-x64
    aarch64-linux = "sha256-nDOLEuR3dXh7OIXq6lX8LviD6zsIRzJK6Fk2l8nKHYA="; # canary-deb-arm64
  };
  extraRuntimeLibs = [ hunspell libfido2 ];
})
