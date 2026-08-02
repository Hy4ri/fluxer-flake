#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANNELS=("stable" "canary")
ARCHES=("x64" "arm64")

cleanup () {
  rm -f "${TEMP_FILES[@]}" 2>/dev/null || true
}
TEMP_FILES=()
trap cleanup EXIT

declare -A NEW_VERSIONS
declare -A NEW_HASHES

get_hash () {
  local url="$1"
  local temp_file
  temp_file=$(mktemp)
  TEMP_FILES+=("$temp_file")

  # Some CDNs require a browser-like User-Agent to serve .deb files directly.
  if ! curl -fsSL -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" "$url" -o "$temp_file"; then
    return 1
  fi

  local raw_hash
  raw_hash=$(sha256sum "$temp_file" | cut -d' ' -f1)
  nix hash convert --hash-algo sha256 --to sri "$raw_hash"
}

for channel in "${CHANNELS[@]}"; do
  echo "=== Processing $channel channel ==="

  for arch in "${ARCHES[@]}"; do
    # Always fetch the per-arch manifest to avoid cross-arch hash mismatches
    manifest=$(curl -fsSL --connect-timeout 10 --max-time 30 --retry 3 --retry-delay 3 --retry-all-errors "https://api.fluxer.app/dl/desktop/$channel/linux/$arch/latest" || true)

    # Grab the version from the first arch (both arches share the same version)
    if [[ "$arch" == "x64" ]]; then
      version=$(echo "$manifest" | jq -r '.version')

      if [[ -z "$version" || "$version" == "null" ]]; then
        echo "Error: Failed to fetch $channel version"
        exit 1
      fi

      NEW_VERSIONS[$channel]=$version
      echo "  Version: $version"
    fi

    # Prefer the API-provided sha256 when available, fall back to downloading
    api_hash=$(echo "$manifest" | jq -r ".files.deb.sha256 // empty")

    if [[ -n "$api_hash" && "$api_hash" != "null" ]]; then
      echo "  $arch: using API hash"
      sri_hash=$(nix hash convert --hash-algo sha256 --to sri "$api_hash")
    else
      echo "  $arch: downloading to compute hash..."
      url="https://web.fluxer.app/api/dl/desktop/$channel/linux/$arch/${NEW_VERSIONS[$channel]}/deb"
      sri_hash=$(get_hash "$url") || { echo "Error: Failed to download $channel $arch"; exit 1; }
    fi

    if [[ -z "$sri_hash" ]]; then
      echo "Error: Empty hash for $channel $arch"
      exit 1
    fi

    echo "  $arch SRI: $sri_hash"
    NEW_HASHES["${channel}_${arch}"]=$sri_hash
  done
done

echo ""
echo "=== Updating version.json ==="
cat > "$SCRIPT_DIR/version.json" << EOF
{
  "stable": "${NEW_VERSIONS[stable]}",
  "canary": "${NEW_VERSIONS[canary]}"
}
EOF

echo "=== Updating fluxer.nix ==="
sed -i "/# deb-x64/ s|\"sha256-[A-Za-z0-9+/]*=*\"|\"${NEW_HASHES[stable_x64]}\"|" "$SCRIPT_DIR/fluxer.nix"
sed -i "/# deb-arm64/ s|\"sha256-[A-Za-z0-9+/]*=*\"|\"${NEW_HASHES[stable_arm64]}\"|" "$SCRIPT_DIR/fluxer.nix"

echo "=== Updating fluxer-canary.nix ==="
sed -i "/# canary-deb-x64/ s|\"sha256-[A-Za-z0-9+/]*=*\"|\"${NEW_HASHES[canary_x64]}\"|" "$SCRIPT_DIR/fluxer-canary.nix"
sed -i "/# canary-deb-arm64/ s|\"sha256-[A-Za-z0-9+/]*=*\"|\"${NEW_HASHES[canary_arm64]}\"|" "$SCRIPT_DIR/fluxer-canary.nix"

echo ""
echo "============================================"
echo "Success! Updated:"
echo "  stable:  ${NEW_VERSIONS[stable]}"
echo "  canary:  ${NEW_VERSIONS[canary]}"
echo "============================================"
