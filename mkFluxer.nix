# Shared builder for Fluxer Electron desktop client derivations.
# Called by fluxer.nix (stable) and fluxer-canary.nix (canary).
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
  # Configuration parameters (passed by wrapper files)
  pname,
  channel,
  version,
  extractDir,
  hashMap,
  extraRuntimeLibs ? [],
  ...
}:

let
  archMap = {
    x86_64-linux = "x64";
    aarch64-linux = "arm64";
  };

  system = stdenv.hostPlatform.system;
  arch = archMap.${system} or (throw "Unsupported system: ${system}");
  hash = hashMap.${system} or (throw "Unsupported system: ${system}");

  baseRuntimeLibs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libgbm
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libxkbcommon
    libXrandr
    libXrender
    libXScrnSaver
    libXt
    libXtst
    libxcb
    libuuid
    libxml2
    nspr
    nss
    pango
    pipewire
    systemd
    wayland
    vulkan-loader
    libpulseaudio
    libkrb5
    libsecret
    libnotify
    stdenv.cc.cc
  ];

  runtimeLibs = baseRuntimeLibs ++ extraRuntimeLibs;
in

stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://web.fluxer.app/api/dl/desktop/${channel}/linux/${arch}/${version}/deb";
    inherit hash;
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-*.so.*" ];

  buildInputs = runtimeLibs;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt/${pname}"
    cp -r "opt/${extractDir}"/* "$out/opt/${pname}/"

    if [ -d usr/share ]; then
      mkdir -p $out/share
      cp -r usr/share/* $out/share/
    fi

    # Patch .desktop file if present
    if [ -f "$out/share/applications/${pname}.desktop" ]; then
      substituteInPlace "$out/share/applications/${pname}.desktop" \
        --replace-fail "/opt/${extractDir}/${pname}" "$out/bin/${pname}"
    fi

    mkdir -p $out/bin
    makeWrapper "$out/opt/${pname}/${pname}" "$out/bin/${pname}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}

    runHook postInstall
  '';

  meta = {
    description = "Fluxer${lib.optionalString (channel == "canary") " Canary"} - Free and open source instant messaging and VoIP platform${lib.optionalString (channel == "canary") " (canary channel)"}";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = pname;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
