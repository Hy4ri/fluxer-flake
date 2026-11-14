# Shared builder for Fluxer Electron desktop client derivations.
# Called by fluxer.nix (stable) and fluxer-canary.nix (canary).
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
    libva
    stdenv.cc.cc
  ];

  runtimeLibs = baseRuntimeLibs ++ extraRuntimeLibs;

  appName = "app.fluxer.FluxerDesktop${lib.optionalString (channel == "canary") "Canary"}";
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
    wrapGAppsHook3
  ];

  autoPatchelfIgnoreMissingDeps = [ "libc.musl-*.so.*" ];

  # Fluxer re-launches itself through process.execPath (its own .desktop
  # entry, autostart entry, and app.relaunch), which bypasses the wrapper.
  # Put the dlopen()ed libs and the host driver dir in RUNPATH so the bare
  # binary still finds libEGL, libva, and the GPU drivers.
  runtimeDependencies = map lib.getLib runtimeLibs;
  appendRunpaths = [ "/run/opengl-driver/lib" ];

  # GTK needs the gsettings schemas to read desktop settings (text scale,
  # theme, file chooser). Without them, Fluxer only works when the launching
  # environment happens to provide them.
  buildInputs = runtimeLibs ++ [ gsettings-desktop-schemas ];

  # Build one wrapper ourselves, with the GApps args added (see preFixup).
  dontWrapGApps = true;

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
    if [ -f "$out/share/applications/${appName}.desktop" ]; then
      substituteInPlace "$out/share/applications/${appName}.desktop" \
        --replace-fail "/opt/${extractDir}/${pname}" "$out/bin/${pname}"
      substituteInPlace "$out/share/applications/${appName}.desktop" \
        --replace-fail "${pname}-launcher" "${pname}"
    fi

    runHook postInstall
  '';

  # gappsWrapperArgs is only filled in just before fixup.
  preFixup = ''
    mkdir -p $out/bin
    makeWrapper "$out/opt/${pname}/${pname}" "$out/bin/${pname}" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --suffix LD_LIBRARY_PATH : /run/opengl-driver/lib \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
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
