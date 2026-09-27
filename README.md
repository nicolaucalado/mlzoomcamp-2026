# ML Zoomcamp 2026

Homeworks and projects for [Machine Learning Zoomcamp 2026](https://github.com/DataTalksClub/machine-learning-zoomcamp) (DataTalks.Club), by Nicolau Calado Jofilsan.

Notebooks are bilingual (English / Portuguese).

## Contents

| Notebook | Modules | Topics |
| --- | --- | --- |
| `Atividade01_HW1_HW2_ML_Zoomcamp_2026.ipynb` | 1 and 2 | NumPy, linear algebra and Pandas; linear regression from scratch, regularization, train/validation/test split, RMSE |

## Data

The notebooks use the pinned 2026 release `car_fuel_efficiency_2026.csv` from the course repository (`cohorts/2026/data/`). The first cell downloads it automatically when the file is not present in the working directory.

## How to run

Install the dependencies with `pip install pandas numpy matplotlib jupyterlab`, open the notebook and run all cells from a fresh kernel. Tested with Python 3.13.14, pandas 3.0.6 and numpy 2.5.0 on Windows.

## Notes on methodology

Every split calls `np.random.seed` before `np.random.shuffle`, so the results are reproducible. A random row-level split is appropriate for this dataset because each row is an independent car. When rows are grouped by person, session or patient, the split has to be done by group, otherwise the reported metric is inflated by leakage.
