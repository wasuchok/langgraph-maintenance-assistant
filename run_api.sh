#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

choose_python_bin() {
  if [[ -x ".venv312/bin/python" ]]; then
    echo ".venv312/bin/python"
    return 0
  fi

  if [[ -x "venv/bin/python" ]]; then
    echo "venv/bin/python"
    return 0
  fi

  cat <<'EOF' >&2
ไม่พบ virtualenv ที่พร้อมใช้งานสำหรับรัน Django API

ให้สร้าง environment ก่อน เช่น:
  /opt/homebrew/bin/python3.12 -m venv .venv312
  .venv312/bin/python -m pip install -r requirements.txt

จากนั้นรันใหม่:
  ./run_api.sh
EOF
  exit 1
}

PYTHON_BIN="$(choose_python_bin)"
HOST_VALUE="${HOST:-0.0.0.0}"
PORT_VALUE="${PORT:-8000}"

UVICORN_ARGS=(
  "config.asgi:application"
  "--host" "$HOST_VALUE"
  "--port" "$PORT_VALUE"
)

if [[ "${RELOAD:-false}" == "true" ]]; then
  UVICORN_ARGS+=("--reload")
fi

exec "$PYTHON_BIN" -m uvicorn "${UVICORN_ARGS[@]}" "$@"
