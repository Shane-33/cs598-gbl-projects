#!/usr/bin/env bash
# Exp1: Proteina stochastic sampling (sc), sc_scale_noise 0.45
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PROTEINA_DIR="${PROJECT_ROOT}/hands_on_protein/third_party/proteina"
CONFIG_SRC="${PROJECT_ROOT}/hands_on_protein/configs/inference_ucond_200m_notri_sc_noise045.yaml"
CONFIG_DST="${PROTEINA_DIR}/configs/experiment_config/inference_ucond_200m_notri_sc_noise045.yaml"

if [[ ! -d "${PROTEINA_DIR}" ]]; then
  echo "Proteina repo not found at: ${PROTEINA_DIR}"
  echo "Clone it under hands_on_protein/third_party/proteina first."
  exit 1
fi

if [[ ! -f "${CONFIG_SRC}" ]]; then
  echo "Missing tracked config: ${CONFIG_SRC}"
  exit 1
fi

if [[ -f "${PROJECT_ROOT}/.env" ]]; then
  echo "[info] Loading ${PROJECT_ROOT}/.env"
  set -a
  # shellcheck disable=SC1091
  source "${PROJECT_ROOT}/.env"
  set +a
else
  echo "[warn] No ${PROJECT_ROOT}/.env — set DATA_PATH and CKPT_PATH (see .env.example)"
fi

if ! command -v python &>/dev/null; then
  echo "[error] python not on PATH. Activate: conda activate proteina_env"
  exit 1
fi

if [[ -z "${CONDA_DEFAULT_ENV:-}" ]] && [[ -z "${VIRTUAL_ENV:-}" ]]; then
  echo "[warn] No conda/virtualenv detected — if imports fail: conda activate proteina_env"
fi

echo "[info] Copying experiment config into Proteina tree"
cp "${CONFIG_SRC}" "${CONFIG_DST}"

echo "[info] Using python: $(command -v python)"
cd "${PROTEINA_DIR}"
python proteinfoundation/inference.py --config_name inference_ucond_200m_notri_sc_noise045
