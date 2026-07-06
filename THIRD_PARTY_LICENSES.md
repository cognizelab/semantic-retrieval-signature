# Third-Party Licenses And Notices

Project-authored code and documentation in this repository are distributed under
the GNU General Public License v3.0, as stated in the root `LICENSE` file.

Some MATLAB files under `Code/mvpa` are bundled third-party or adapted research
utilities. Those files retain their original copyright, license notices, and
citation requirements. The root GPL-3.0 license does not remove or replace those
notices.

## Bundled Components

### TPLSm

- Path: `Code/mvpa/algorithm/thresholded partial least squares/`
- Upstream description: MATLAB package for Thresholded Partial Least Squares.
- Repository notice: the component includes its own `LICENSE` file containing
  the GNU General Public License v3.0.
- Citation listed by the bundled README: Lee, S., Bradlow, E. T., & Kable, J. W.
  (2022). Fast Construction of Interpretable Whole-brain Decoders. Cell Reports
  Methods.

### al_violin

- Path: `Code/mvpa/dependency/al_violin/`
- Copyright: Antoine Legouhy, 2021.
- Repository notice: `license.txt` contains a BSD-style redistribution license.

### Precision-Recall Curve Utilities

- Path: `Code/mvpa/utility/ROC/`
- Copyright: Kay H. Brodersen and Cheng Soon Ong, ETH Zurich, 2010.
- Repository notice: `README` contains a BSD-style redistribution license.
- Citation listed by the bundled README: Brodersen, Ong, Stephan, and Buhmann
  (2010), "The binormal assumption on precision-recall curves", ICPR.

### Canlab / Tor Wager Utilities

- Path: `Code/mvpa/dependency/Tor Wager/` and selected helper code referencing
  CanlabCore.
- Repository notice: several files include copyright and GPL-compatible notices
  in their headers, including GNU GPL language.
- Users should retain the file-level notices when redistributing these files.

### ParforProgressbar And Progress Utilities

- Path: `Code/mvpa/utility/progress/`
- Repository notice: the bundled README credits ParforProgressbar and related
  MATLAB File Exchange progress-monitor utilities.
- No standalone license file is included in this repository for every progress
  utility; retain upstream attribution and file-level notices.

### Relevance Vector Regression Utilities

- Path: `Code/mvpa/algorithm/relevance vector regression/`
- Repository notice: files include attribution to the Wellcome Department of
  Imaging Neuroscience and the Machine Learning & Neuroimaging Laboratory.
- Users should retain the file-level notices and cite the relevant RVR/PRT
  sources when using these utilities.

### Kernel Ridge Regression Utilities

- Path: `Code/mvpa/algorithm/kernel ridge regression/`
- Repository notice: bundled MATLAB implementation and demonstration files.
- A separate upstream license is not included in this repository; retain
  attribution and file-level notices if redistributing.

### Integrated PLS / Discriminant Analysis Library

- Path: `Code/mvpa/algorithm/integrated library for partial least squares regression and discriminant analysis/`
- Repository notice: files include author/contact comments for the libPLS-style
  MATLAB routines; several files also contain MathWorks copyright comments.
- A separate upstream license is not included in this repository; retain
  attribution and file-level notices if redistributing.

## License Boundary

If you redistribute or modify this repository, keep:

- the root GPL-3.0 `LICENSE`;
- this `THIRD_PARTY_LICENSES.md` notice file;
- any third-party license files and file-level copyright notices in place.
