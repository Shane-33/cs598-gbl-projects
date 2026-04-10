````markdown
# CS598 GBL — Generative Modeling for Biomedicine & Life Sciences

This repository is the workspace for my course projects in **CS598: Generative Modeling for Biomedicine & Life Sciences**.

It contains two main parts:

- `hands_on_protein/` — the course **hands-on protein design challenge**
- `final_project/` — the **final project** for the course

The repository is organized to stay portable across different machines. Machine-specific paths, model checkpoints, downloaded assets, and large generated outputs should not be committed to git.

## Repository structure

```text
cs598-gbl-projects/
├── README.md
├── .env.example
├── .gitignore
├── hands_on_protein/
└── final_project/
````

## hands_on_protein

This directory contains the code, configs, scripts, and evaluation workflow for the **protein design hands-on challenge**.

The current plan is to use **Proteina** for protein backbone generation and compare several sampling settings under the same checkpoint family. The workflow is organized so experiments can be run on a workstation and later analyzed in a reproducible way.

This part of the repository includes:

* experiment configs
* run scripts
* evaluation-related files
* result summaries and report materials

## final_project

This directory is reserved for the **course final project**.

It will be developed separately from the hands-on challenge, while still sharing the same top-level repository structure for easier organization and reproducibility.

## Notes

* Large files such as checkpoints, downloaded model assets, databases, and generated outputs are not tracked in git.
* Environment-specific values should be stored in `.env` and not committed.
* This repository is mainly for project organization, experiment scripts, and report-related materials.