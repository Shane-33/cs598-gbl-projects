#!/usr/bin/env bash
# Exp1: Proteina stochastic sampling (sc), sc_scale_noise 0.45
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDS_ON_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HANDS_ON_ROOT/.." && pwd)"
PROTEINA_ROOT="$HANDS_ON_ROOT/third_party/proteina"

if [[ ! -d "$PROTEINA_ROOT" ]]; then
  echo "[error] Proteina not found at $PROTEINA_ROOT"
  exit 1
fi

if [[ -f "$REPO_ROOT/.env" ]]; then
  echo "[info] Loading $REPO_ROOT/.env"
  set -a
  # shellcheck disable=SC1091
  source "$REPO_ROOT/.env"
  set +a
else
  echo "[warn] No $REPO_ROOT/.env — set DATA_PATH and CKPT_PATH before running (see .env.example)"
fi

if ! command -v python &>/dev/null; then
  echo "[error] python not on PATH."
  echo "       Activate the Proteina env: conda activate proteina_env"
  exit 1
fi

if [[ -z "${CONDA_DEFAULT_ENV:-}" ]] && [[ -z "${VIRTUAL_ENV:-}" ]]; then
  echo "[warn] No conda/virtualenv detected — if imports fail, run: conda activate proteina_env"
fi

echo "[info] Using python: $(command -v python)"
cd "$PROTEINA_ROOT"
exec python proteinfoundation/inference.py --config_name inference_ucond_200m_notri_sc_noise045
