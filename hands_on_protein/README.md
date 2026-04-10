# CS598 hands-on — protein design (Proteina)

Portable workspace for the **protein design hands-on challenge**: unconditional Cα backbone generation with **Proteina**, optional **ProteinMPNN**-based designability, and the course **CS598-GBL** evaluation stack.

## Project goal

Run three **baseline samplers** on the **same checkpoint** (`proteina_v1.2_DFS_200M_notri.ckpt`) over a shared length grid, then score designs (designability + course metrics) and summarize results for the hands-on report.

## Directory structure

```text
hands_on_protein/
├── README.md                 # this file
├── WORKSTATION_CHECKLIST.md
├── configs/                  # your experiment notes / overrides (optional)
├── data/                     # local downloads (gitignored)
├── outputs/                  # generated PDBs / runs (gitignored)
├── results/                  # small tables, figures (tracked; avoid huge blobs)
├── report/                   # write-up assets
├── scripts/                  # setup + run_exp*.sh
└── third_party/
    ├── proteina/             # upstream Proteina (editable install)
    ├── ProteinMPNN/
    └── CS598-GBL/protein/    # course evaluation pipeline
```

## Third-party dependencies

| Component | Role |
|-----------|------|
| **Proteina** | Flow-based Cα generator; inference via `proteinfoundation/inference.py` |
| **ProteinMPNN** | Sequence design for designability / structural consistency checks |
| **CS598-GBL `protein/`** | Course evaluation metrics and formatting |

## Baseline comparison design

| Exp | Config name | Sampler | Notes |
|-----|-------------|---------|--------|
| **1** | `inference_ucond_200m_notri_sc_noise045` | `sc`, noise **0.45** | Default-class stochastic baseline |
| **2** | `inference_ucond_200m_notri_vf` | **`vf`** | Deterministic ODE / flow-matching path |
| **3** | `inference_ucond_200m_notri_sc_noise060` | `sc`, noise **0.60** | Same SDE family, higher noise scale |

All three set `ckpt_name: proteina_v1.2_DFS_200M_notri.ckpt`, `nres_lens:90–128`, `nsamples_per_len: 10`.

## Reason for choosing these baselines

- **Same checkpoint** — differences reflect **sampling**, not capacity or training.
- **Controlled comparison** — only `sampling_mode` and `sc_scale_noise` change between stochastic runs; `vf` isolates deterministic dynamics.
- **Report-friendly** — three clear knobs with interpretable tradeoffs (diversity vs stability, ODE vs SDE).

## What is not committed to git

- **Checkpoints** (`.ckpt`, etc.) and **Proteina additional files**
- **`data/`** and **`outputs/`** (see root `.gitignore`)
- **Large databases** (e.g. Foldseek DB trees under ignored paths)
- **`.env`** (use `.env.example` at repo root)

## Workstation setup

1. Clone the parent repo; copy **`.env.example`** → **`.env`** at repo root; set **`DATA_PATH`** and **`CKPT_PATH`**.
2. On Linux, run **`scripts/setup_workstation.sh`** (mamba/conda, `proteina_env`, `pip install -e .` in `third_party/proteina`).
3. Download **`proteina_v1.2_DFS_200M_notri.ckpt`** + additional files; place checkpoints under **`CKPT_PATH`**.
4. From **`third_party/proteina`**: **`bash script_utils/download_pmpnn_weghts.sh`**.
5. **`conda activate proteina_env`**, then run the experiment scripts below.

## Run commands (three baselines)

From anywhere, after activating the env:

```bash
bash hands_on_protein/scripts/run_exp1_sc_noise045.sh
bash hands_on_protein/scripts/run_exp2_vf.sh
bash hands_on_protein/scripts/run_exp3_sc_noise060.sh
```

Paths are resolved from the script location; the repo-root **`.env`** is sourced when present so **`DATA_PATH`** / **`CKPT_PATH`** apply without hardcoding.

## Evaluation plan

1. **Generate** backbones with each baseline (PDBs / run outputs under `outputs/` or Proteina defaults).
2. **Designability** — use Proteina’s built-in metric path (ProteinMPNN weights required) and/or course scripts.
3. **Adapt outputs** to the **CS598-GBL protein** evaluation format (CSV/layout expected by the grader or notebook).
4. **Run evaluation** — course notebook or metric runner; collect summary statistics for `results/` and the report.

See **`WORKSTATION_CHECKLIST.md`** for a terse step-by-step checklist.
