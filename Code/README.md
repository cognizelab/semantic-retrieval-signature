# Code

This directory contains the MATLAB code used for the repository demos and for
multivariate predictive modelling of semantic distance.

## Contents

- `example/data_demo.mat`: small demonstration dataset with feature matrix `X`,
  target vector `Y`, and subject labels `subj`.
- `example/regression_tpls.m`: T-PLS regression demo.
- `example/regression_svr.m`: SVR regression demo.
- `mvpa/`: custom MATLAB MVPA framework and bundled algorithm dependencies.

## Running The Demo

From the repository root:

```matlab
run(fullfile('Code', 'example', 'regression_tpls.m'))
run(fullfile('Code', 'example', 'regression_svr.m'))
```

Both scripts automatically add `Code/mvpa` to the MATLAB path and load
`Code/example/data_demo.mat`.

## Main Analysis Entry Points

- `mat_cv`: cross-validation framework for regression and classification.
- `mat_bootstrap`: bootstrap test for feature weights and optional Haufe maps.
- `mat_permutation`: optional permutation test.
- `mat_report_correlation`: summary metrics for regression outputs.
- `mat_plot_correlation`: diagnostic plot for true and predicted values.

The demos use a reduced bootstrap count for quick review. For manuscript-scale
analyses, use the parameter settings reported in the main README and manuscript
Methods.

On the tested Windows 11 / MATLAB R2023b system, the T-PLS demo completed in
approximately 6 seconds and the SVR demo completed in approximately 5 seconds,
excluding MATLAB application startup time.
