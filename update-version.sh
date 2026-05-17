#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHANNELS=("stable" "canary")
ARCHES=("x64" "arm64")
PLACEHOLDER="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

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
  if curl -sL -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" "$url" -o "$temp_file"; then
    local raw_hash
    raw_hash=$(sha256sum "$temp_file" | cut -d' ' -f1)
    nix hash convert --hash-algo sha256 --to sri "$raw_hash"
  fi
}

for channel in "${CHANNELS[@]}"; do
  echo "=== Processing $channel channel ==="

  manifest=$(curl -s "https://api.fluxer.app/dl/desktop/$channel/linux/x64/latest")
  version=$(echo "$manifest" | jq -r '.version')

  if [[ -z "$version" || "$version" == "null" ]]; then
    echo "Error: Failed to fetch $channel version"
    exit 1
  fi

  NEW_VERSIONS[$channel]=$version
  echo "  Version: $version"

  for arch in "${ARCHES[@]}"; do
    # Canary API provides sha256; stable does not
    api_hash=$(echo "$manifest" | jq -r ".files.deb.sha256 // empty")

    if [[ "$arch" == "arm64" ]]; then
      arm_manifest=$(curl -s "https://api.fluxer.app/dl/desktop/$channel/linux/arm64/latest")
      api_hash=$(echo "$arm_manifest" | jq -r ".files.deb.sha256 // empty")
    fi

    if [[ -n "$api_hash" && "$api_hash" != "null" ]]; then
      echo "  $arch: using API hash"
      sri_hash=$(nix hash convert --hash-algo sha256 --to sri "$api_hash")
    else
      echo "  $arch: downloading to compute hash..."
      url="https://web.fluxer.app/api/dl/desktop/$channel/linux/$arch/$version/deb"
      sri_hash=$(get_hash "$url")
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
