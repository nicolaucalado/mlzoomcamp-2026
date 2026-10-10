# ML Zoomcamp 2026

Homeworks and projects for [Machine Learning Zoomcamp 2026](https://github.com/DataTalksClub/machine-learning-zoomcamp) (DataTalks.Club), by Nicolau Calado Jofilsan.

Notebooks are bilingual (English / Portuguese).

## Contents

| Folder | Modules | Notebook | Topics |
| --- | --- | --- | --- |
| root | 1 and 2 | `Atividade01_HW1_HW2_ML_Zoomcamp_2026.ipynb` | NumPy, linear algebra and Pandas; linear regression from scratch, regularization, train/validation/test split, RMSE |
| `03-classification/` | 3 | `Atividade03_HW3_ML_Zoomcamp_2026.ipynb` | Lead scoring: missing values, correlation matrix, mutual information, one-hot encoding, logistic regression, feature elimination, regularization |

Note on layout: the modules 1 and 2 notebook stays at the repository root because its URL was submitted with those homeworks. Later modules live in their own folders.

## Data

Each notebook uses the pinned 2026 release published in the course repository (`cohorts/2026/data/`) and downloads it automatically when the file is not present in the working directory.

## How to run

Install the dependencies with `pip install pandas numpy scikit-learn matplotlib jupyterlab`, open a notebook and run all cells from a fresh kernel. Tested with Python 3.13.14, pandas 3.0.6, numpy 2.5.0 and scikit-learn on Windows.

## Notes on methodology

Every split calls a fixed random seed before shuffling, so the results are reproducible. Encoders are fitted on the training set only and applied to validation and test, which keeps information from leaking across the split. A random row-level split is appropriate for these datasets because each row is an independent observation. When rows are grouped by person, session or patient, the split has to be done by group, otherwise the reported metric is inflated by leakage.
