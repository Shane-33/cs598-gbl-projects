#!/usr/bin/env bash
# CS598 hands-on: Proteina workstation setup helper (Linux).
# Non-destructive: creates conda env only if missing; no rm -rf or overwrite of data.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HANDS_ON_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$HANDS_ON_ROOT/.." && pwd)"
PROTEINA_ROOT="$HANDS_ON_ROOT/third_party/proteina"
ENV_NAME="proteina_env"

echo "============================================================"
echo "CS598 hands-on — Proteina workstation setup (checklist)"
echo "============================================================"
echo "[info] Repo root:      $REPO_ROOT"
echo "[info] Hands-on root:  $HANDS_ON_ROOT"
echo "[info] Proteina root:  $PROTEINA_ROOT"
echo ""

if [[ ! -d "$PROTEINA_ROOT" ]]; then
  echo "[error] Proteina directory not found: $PROTEINA_ROOT"
  exit 1
fi

PKG_MGR=""
if command -v mamba &>/dev/null; then
  PKG_MGR="mamba"
  echo "[info] Using: mamba"
elif command -v conda &>/dev/null; then
  PKG_MGR="conda"
  echo "[info] Using: conda"
else
  echo "[error] Neither 'mamba' nor 'conda' is on PATH."
  echo ""
  echo "Install Miniforge or Mambaforge (recommended on Linux), then re-run:"
  echo "  https://github.com/conda-forge/miniforge"
  echo ""
  echo "After installation, open a new shell and run this script again."
  exit 1
fi

if [[ ! -f "$PROTEINA_ROOT/environment.yaml" ]]; then
  echo "[error] Missing $PROTEINA_ROOT/environment.yaml"
  exit 1
fi

cd "$PROTEINA_ROOT"
echo "[info] Working directory: $(pwd)"
echo ""

if "$PKG_MGR" env list | grep -qE "^[[:space:]]*${ENV_NAME}[[:space:]]"; then
  echo "[ok] Conda environment '${ENV_NAME}' already exists — skipping env create."
else
  echo "[step] Creating environment '${ENV_NAME}' from environment.yaml ..."
  "$PKG_MGR" env create -f environment.yaml
  echo "[ok] Environment created."
fi

echo ""
echo "------------------------------------------------------------"
echo "Activate the environment (run this in your shell):"
echo "  conda activate ${ENV_NAME}"
echo "------------------------------------------------------------"
echo ""

echo "[step] Installing Proteina in editable mode (pip install -e .) ..."
"$PKG_MGR" run -n "${ENV_NAME}" pip install -e .
echo "[ok] pip install -e . finished."
echo ""

echo "============================================================"
echo "Manual steps / reminders (checklist)"
echo "============================================================"
echo ""
echo "1) Checkpoint: download"
echo "     proteina_v1.2_DFS_200M_notri.ckpt"
echo "   and Proteina 'additional files' per upstream README / release notes."
echo ""
echo "2) Place all checkpoint files under the directory you set as:"
echo "     CKPT_PATH"
echo "   (Hydra uses ckpt_path: \${oc.env:CKPT_PATH} in inference_base.yaml)"
echo ""
echo "3) At repo root (${REPO_ROOT}), create .env from .env.example:"
echo "     cp .env.example .env"
echo "   Set DATA_PATH and CKPT_PATH to your machine-local paths (do not commit .env)."
echo ""
echo "4) Download ProteinMPNN weights from the Proteina repo (after cd to Proteina root):"
echo "     cd \"$PROTEINA_ROOT\""
echo "     bash script_utils/download_pmpnn_weghts.sh"
echo ""
echo "5) Run baseline experiments (after conda activate ${ENV_NAME}):"
echo "     bash \"$HANDS_ON_ROOT/scripts/run_exp1_sc_noise045.sh\""
echo "     bash \"$HANDS_ON_ROOT/scripts/run_exp2_vf.sh\""
echo "     bash \"$HANDS_ON_ROOT/scripts/run_exp3_sc_noise060.sh\""
echo ""
echo "Done (setup helper). No destructive actions were performed."
echo "============================================================"
