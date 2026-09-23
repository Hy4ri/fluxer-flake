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
  hunspell,
  libfido2,
}@args:

import ./mkFluxer.nix (args // {
  pname = "fluxer-canary";
  channel = "canary";
  version = (builtins.fromJSON (builtins.readFile ./version.json)).canary;
  extractDir = "Fluxer Canary";
  hashMap = {
    x86_64-linux = "sha256-E4eszD0sFsIJTefYvY+yLn62mB8KLT21Ox/6G9Z7PZk="; # canary-deb-x64
    aarch64-linux = "sha256-0y0Pdb51vzscctL/FmD9EKGEg61g1n6nCraIo6nbkiw="; # canary-deb-arm64
  };
  extraRuntimeLibs = [ hunspell libfido2 ];
})
