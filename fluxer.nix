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
}:

let
  version = (builtins.fromJSON (builtins.readFile ./version.json)).stable;

  archMap = {
    x86_64-linux = "x64";
    aarch64-linux = "arm64";
  };

  hashMap = {
    x86_64-linux = "sha256-oAV9M5c2WbiHX8HtZZYqC8RoQCvWxE6DDDMvhs285CA="; # deb-x64
    aarch64-linux = "sha256-FAB9aR0DzSdqu7U2vLqpiQ4a5UtfIOMIy2xehg1OeFM="; # deb-arm64
  };

  system = stdenv.hostPlatform.system;
  arch = archMap.${system} or (throw "Unsupported system: ${system}");
  hash = hashMap.${system} or (throw "Unsupported system: ${system}");

  runtimeLibs = [
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
in

stdenv.mkDerivation {
  pname = "fluxer";
  inherit version;

  src = fetchurl {
    url = "https://web.fluxer.app/api/dl/desktop/stable/linux/${arch}/${version}/deb";
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

    mkdir -p $out/opt/fluxer
    cp -r opt/Fluxer/* $out/opt/fluxer/

    if [ -d usr/share ]; then
      mkdir -p $out/share
      cp -r usr/share/* $out/share/
    fi

    substituteInPlace $out/share/applications/fluxer.desktop \
      --replace-fail /opt/Fluxer/fluxer $out/bin/fluxer

    mkdir -p $out/bin
    makeWrapper $out/opt/fluxer/fluxer $out/bin/fluxer \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --set PATH ${lib.makeBinPath [ xdg-utils ]}

    runHook postInstall
  '';

  meta = {
    description = "Fluxer - Free and open source instant messaging and VoIP platform";
    homepage = "https://fluxer.app";
    license = lib.licenses.agpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "fluxer";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}
