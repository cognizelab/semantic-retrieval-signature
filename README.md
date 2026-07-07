# Semantic Distance Signature

This repository contains the code, demonstration data, word-pair stimuli, ROI
definitions, and group-level neural signature maps for the manuscript:

> Zhuang, K., Liang, X., Smallwood, J., Jefferies, E., & Vatansever, D.
> Model-based semantic distance reveals adaptive coordination of distinct
> cognitive systems in flexible knowledge retrieval.

The study combines static word-embedding models, task fMRI, and multivariate
predictive modelling to identify a whole-brain semantic distance signature.
Larger semantic distances between probe-target word pairs correspond to greater
controlled retrieval demands.

## Repository Contents

- `Code/`: MATLAB MVPA code and a small demonstration dataset for running
  T-PLS and SVR analyses.
- `Semantic distance signature/`: group-level semantic distance signature maps
  in CIFTI and NIFTI formats.
- `ROIs/`: MMP atlas labels and ROI files for parcels implicated in the
  semantic distance signature.
- `Word-pair stimulus/`: the 3-AFC word-pair stimuli used in the task.

## Key Materials And Figure Overview

This section highlights the main research outputs provided with the repository:
the whole-brain semantic distance signature, demonstration analyses for
trial-level prediction, and ROI-level functional-system decomposition. Full
methodological details, figure legends, and result interpretation are provided
in the main manuscript and the Supplementary Information.

### 1. Whole-Brain Topography Of Semantic Retrieval Demands

[![Fig-1-1.jpg](https://i.postimg.cc/MHkHPcQr/Fig-1-1.jpg)](https://postimg.cc/hzrKhtM9)

The whole-brain semantic distance signature is provided in CIFTI and NIFTI
formats in `Semantic distance signature/`.

### 2. Trial-Level Prediction Of Semantic Distance

[![B.png](https://i.postimg.cc/9Q5TZgmV/B.png)](https://postimg.cc/4mPmT5HF)

The MATLAB examples in `Code/example/` demonstrate the T-PLS and SVR prediction
workflow on a small demo dataset. Full manuscript-scale prediction analyses
depend on restricted-access participant-level fMRI response estimates described
in the manuscript. The word-pair stimuli used to construct the semantic distance
estimates are provided in `Word-pair stimulus/`.

### 3. Functional-System Decomposition

[![C.jpg](https://i.postimg.cc/VNMN45Tr/C.jpg)](https://postimg.cc/jWxKSqRt)

Information on the core ROIs and functional-system assignments within the
semantic distance signature is provided in `ROIs/`.

## System Requirements

### Software

- MATLAB. The code uses MATLAB syntax and functions from the Statistics and
  Machine Learning Toolbox for SVR (`fitrsvm`).
- Optional: Parallel Computing Toolbox for large bootstrap or permutation runs.
- Optional for viewing maps: Connectome Workbench or another CIFTI/NIFTI viewer.

### Tested Environment

- Operating system: Windows 11.
- MATLAB: R2023b Update 5 with Statistics and Machine Learning Toolbox.
- Hardware: no non-standard hardware is required for the demo. A normal desktop
  or laptop with at least 8 GB RAM is sufficient for `Code/example/data_demo.mat`.
- Full manuscript-scale fMRI analyses require substantially more memory and
  storage because they operate on trial-level whole-brain beta maps.

## Installation

Clone the repository and add the MATLAB MVPA code to the path:

```matlab
addpath(genpath(fullfile('Code', 'mvpa')));
```

Typical install time on a normal desktop is under 5 minutes after MATLAB is
already installed. The repository includes the MATLAB code needed for the demo;
no MATLAB package installation is required.

## Demo

The demonstration uses the small dataset in `Code/example/data_demo.mat`.
Run the examples from the repository root:

```matlab
run(fullfile('Code', 'example', 'regression_tpls.m'))
run(fullfile('Code', 'example', 'regression_svr.m'))
```

The scripts add `Code/mvpa` to the MATLAB path automatically, so they can also
be launched directly from `Code/example`.

### Expected Demo Output

Each demo should create these MATLAB workspace variables:

- `out`: model quality, predictions, selected parameters, bootstrap statistics,
  and report fields.
- `log`: model settings, cross-validation folds, retained observations/features,
  and covariate handling metadata.
- `bootweight`: bootstrapped feature weights.

The T-PLS demo also computes Haufe-transformed bootstrap weights and stores them
in `Haufeweight`. The SVR demo skips permutation testing by default for a quick
installation check; set `runPermutation = true` in `regression_svr.m` to run
the optional permutation test.

For the quick demos, the scripts use `demoBootstrapN = 100`. The manuscript
analyses used 5,000 bootstrap/permutation iterations where reported.

On the tested Windows 11 / MATLAB R2023b system, the T-PLS demo completed in
approximately 6 seconds and the SVR demo completed in approximately 5 seconds,
excluding MATLAB application startup time.

## Running On Your Own Data

The main MVPA entry point is:

```matlab
[out, log] = mat_cv(x, y, c, model, cv, param);
```

Inputs:

- `x`: observations by features matrix. In the manuscript analyses, features
  were whole-brain grayordinates or voxels.
- `y`: target variable. In the primary analysis, this was model-derived semantic
  distance for each trial.
- `c`: optional covariates. Use `[]` when no covariates are included.
- `model`: for this repository's examples, use `'tpls'` or `'svr'`.
- `cv`: outer cross-validation setting. Use `[]` for leave-one-out style
  cross-validation, or provide explicit folds through `param`.
- `param.groupCV`: subject IDs for leave-one-subject-out cross-validation.

For the main T-PLS model used in the manuscript, the parameter search used
component values `1:25` and thresholds `0.05:0.05:1`; the reported optimal
setting was 2 components and a threshold of 0.65.

## Manuscript Reproduction Notes

This repository provides the custom MATLAB code and group-level outputs needed
to inspect and reuse the semantic distance signature. Full end-to-end
reproduction of every manuscript result also depends on restricted-access fMRI
data and external tools described in the manuscript:

- [Qunex](https://qunex.yale.edu/) / HCP minimal preprocessing for fMRI
  preprocessing.
- [GLMsingle](https://github.com/cvnlab/GLMsingle) for single-trial fMRI
  response estimates.
- Static word embeddings from the [Hugging Face Hub](https://huggingface.co/),
  including Word2Vec, FastText, GloVe, ConceptNet Numberbatch v19.08, and RWSGwn.
- A custom [Embedding toolkit](https://github.com/lc451574367/Embedding) for
  word-vector extraction.
- [T-PLS](https://github.com/sangillee/TPLSm) for whole-brain predictive
  modelling.
- [OPNMF](https://github.com/cognizelab/fmatrix-OPNMF) for functional system
  decomposition.
- [NiMARE](https://nimare.readthedocs.io/en/stable/) for meta-analytic decoding.
- [UMAP](https://umap-learn.readthedocs.io/en/latest/) for two-dimensional
  projection of high-dimensional ROI features.

## License

This repository is released under the GNU General Public License v3.0. See
`LICENSE`.
