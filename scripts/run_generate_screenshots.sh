#!/usr/bin/env bash
set -euo pipefail

# Optional: set DEVICE_ID to force a specific device.
# Example:
# DEVICE_ID=E3592F85-F0DE-4C34-9C14-AC1CE128052C ./scripts/run_generate_screenshots.sh
DEVICE_ID="${DEVICE_ID:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "${SCRIPT_DIR}/../example" >/dev/null
OUTPUT_DIR="${SCREENSHOT_OUTPUT_DIR:-screenshots_patrol}"
mkdir -p "${OUTPUT_DIR}"
find "${OUTPUT_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
MARKER_FILE="$(mktemp)"
cleanup_marker() {
  rm -f "${MARKER_FILE}"
}
trap cleanup_marker EXIT

select_preferred_flutter_device_id() {
  local devices_json
  if [[ -n "${FLUTTER_DEVICES_JSON:-}" ]]; then
    devices_json="${FLUTTER_DEVICES_JSON}"
  else
    devices_json="$(flutter --no-version-check --suppress-analytics devices --machine)"
  fi
  FLUTTER_DEVICES_JSON="${devices_json}" python3 - <<'PY'
import json
import os

devices = json.loads(os.environ.get('FLUTTER_DEVICES_JSON', '[]') or '[]')
fallback = ''
for device in devices:
    device_id = str(device.get('id') or '').strip()
    if not device_id:
        continue
    fallback = fallback or device_id
    if str(device.get('name') or '').startswith('iPhone'):
        print(device_id)
        break
else:
    print(fallback)
PY
}

PATROL_ARGS=(test --target=integration_test/screenshot_patrol_test_generated_test.dart --verbose)
PATROL_ARGS+=(--dart-define "PATROL_SCREENSHOT_DIR=${PWD}/${OUTPUT_DIR}")
if [[ -z "${DEVICE_ID}" ]]; then
  DEVICE_ID="$(select_preferred_flutter_device_id)"
fi
if [[ -n "${DEVICE_ID}" ]]; then
  echo "Using Patrol device id: ${DEVICE_ID}"
  PATROL_ARGS+=(--device "${DEVICE_ID}")
fi

patrol "${PATROL_ARGS[@]}"

copied=0
SEARCH_ROOTS=()
if [[ -n "${DEVICE_ID}" && -d "${HOME}/Library/Developer/CoreSimulator/Devices/${DEVICE_ID}" ]]; then
  SEARCH_ROOTS+=("${HOME}/Library/Developer/CoreSimulator/Devices/${DEVICE_ID}")
else
  SEARCH_ROOTS+=("${HOME}/Library/Developer/CoreSimulator/Devices")
fi
SEARCH_ROOTS+=("${HOME}/Library/Containers")
for root in "${SEARCH_ROOTS[@]}"; do
  [[ -d "${root}" ]] || continue
  while IFS= read -r -d '' file; do
    cp "${file}" "${OUTPUT_DIR}/$(basename "${file}")"
    copied=$((copied + 1))
  done < <(find "${root}" -type f -path "*/patrol_screenshots/*" -newer "${MARKER_FILE}" -print0 2>/dev/null || true)
done
if (( copied > 0 )); then
  echo "Collected ${copied} sandboxed Patrol screenshot file(s)."
fi

echo "Screenshot folder contents (${PWD}/${OUTPUT_DIR}):"
ls -lah "${OUTPUT_DIR}"

popd >/dev/null
