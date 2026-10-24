# ML Zoomcamp 2026 — Nicolau Calado Jofilsan

Homeworks and projects for [DataTalks.Club's Machine Learning Zoomcamp 2026](https://github.com/DataTalksClub/machine-learning-zoomcamp), by **Nicolau Calado Jofilsan**.

**EN.** Notebooks are bilingual (English and Portuguese): every explanation, question header and answer appears in both languages, so the work can be read and reproduced by either audience.
**PT.** Os notebooks são bilíngues (inglês e português): cada explicação, cabeçalho de questão e resposta aparece nas duas línguas, para que o trabalho possa ser lido e reproduzido por qualquer um dos dois públicos.

## Contents / Conteúdo

| Folder | Module(s) | Notebook | Topics |
|---|---|---|---|
| [`01-02-regression/`](01-02-regression/) | 1–2 | `Atividade01_HW1_HW2_ML_Zoomcamp_2026.ipynb` | NumPy, linear algebra, Pandas basics; linear regression from scratch, regularization, train/validation/test split, RMSE |
| [`03-classification/`](03-classification/) | 3 | `Atividade03_HW3_ML_Zoomcamp_2026.ipynb` | Lead scoring; missing values, correlation matrix, mutual information, one-hot encoding, logistic regression, feature elimination, regularization |
| [`04-evaluation/`](04-evaluation/) | 4 | `Atividade04_HW4_ML_Zoomcamp_2026.ipynb` | Evaluation metrics for classification; ROC AUC as a feature-ranking score, model AUC, precision/recall threshold curves, F1, 5-fold cross-validation, choosing `C` by cross-validation |
| [`05-deployment/`](05-deployment/) | 5 | `Atividade05_HW5_ML_Zoomcamp_2026.ipynb`, `q3_predict.py` | Deploying a model; artifact integrity check (SHA-256) before unpickling, locked environment with `uv`, scoring with the loaded pipeline, serving with FastAPI, reading a Dockerfile, running the container |

**EN.** A root-level file with the same name as the modules 1–2 notebook is a placeholder: the original homework submission pointed to that URL before the repo was reorganized into per-module folders, so it stays in place and links to the current location instead of breaking.
**PT.** Um arquivo na raiz com o mesmo nome do notebook dos módulos 1–2 é um ponteiro: o envio original da atividade apontava para essa URL antes de o repositório ser reorganizado em pastas por módulo, então ele permanece no lugar e aponta para o local atual, em vez de quebrar o link.

## Data / Dados

**EN.** Each notebook downloads its pinned 2026 dataset directly from the course repository (`cohorts/2026/data/`) the first time it runs, if the file isn't already in the working directory.
**PT.** Cada notebook baixa sua base fixada de 2026 diretamente do repositório do curso (`cohorts/2026/data/`) na primeira execução, caso o arquivo ainda não esteja no diretório de trabalho.

## How to run / Como executar

```
pip install pandas numpy scikit-learn matplotlib jupyterlab
```

**EN.** Tested on Windows with Python 3.13.14, pandas 3.0.6, numpy 2.5.0 and scikit-learn 1.8.0. Run from a fresh kernel (Restart & Run All, or equivalent) to confirm the notebook reproduces end to end.
**PT.** Testado no Windows com Python 3.13.14, pandas 3.0.6, numpy 2.5.0 e scikit-learn 1.8.0. Execute a partir de um kernel limpo (Restart & Run All, ou equivalente) para confirmar que o notebook reproduz do início ao fim.

**EN.** Module 5 uses [`uv`](https://docs.astral.sh/uv/) instead of `pip`: the course folder pins Python 3.11.15 and exact package versions in `uv.lock`, so the notebook downloads the course files and you create the reference environment with `uv sync --locked` (uv fetches the right Python by itself). The container steps need Docker.
**PT.** O módulo 5 usa o [`uv`](https://docs.astral.sh/uv/) em vez do `pip`: a pasta do curso fixa o Python 3.11.15 e as versões exatas dos pacotes no `uv.lock`, então o notebook baixa os arquivos do curso e você cria o ambiente de referência com `uv sync --locked` (o uv obtém o Python correto sozinho). Os passos do contêiner precisam do Docker.

## Notes on methodology / Observações sobre metodologia

**EN.**
- Every split sets a fixed random seed before shuffling, so results are reproducible — but the seed is not the same across homeworks: modules 1–3 use `random_state=42`, module 4 uses `random_state=1`, exactly as each assignment specifies. The two sets of results are not comparable row-for-row, even where they share a dataset.
- Encoders (`DictVectorizer`) are fit on the training data only and then applied to validation/test data — in module 4's cross-validation, this means refitting the encoder inside every fold, not once on the full training set.
- Random row-level splits suit these datasets because each row is an independent lead. When rows are grouped by person, session or patient, the split should be done by group instead, or the metric will be inflated.
- Module 5: the pickled model is verified by SHA-256 before it is loaded (unpickling an untrusted file can execute code), and it is run with the scikit-learn version it was trained with (1.7.2), taken from the lockfile rather than from whatever is installed locally.

**PT.**
- Cada divisão fixa uma semente aleatória antes de embaralhar, então os resultados são reprodutíveis — mas a semente não é a mesma entre as atividades: os módulos 1–3 usam `random_state=42`, o módulo 4 usa `random_state=1`, exatamente como cada enunciado especifica. Os dois conjuntos de resultados não são comparáveis número a número, mesmo compartilhando uma base.
- Os codificadores (`DictVectorizer`) são ajustados só nos dados de treino e depois aplicados à validação/teste — na validação cruzada do módulo 4, isso significa reajustar o codificador dentro de cada parte, não uma única vez no treino completo.
- Divisões aleatórias por linha são adequadas a essas bases porque cada linha é um lead independente. Quando as linhas são agrupadas por pessoa, sessão ou paciente, a divisão deveria ser feita por grupo, ou a métrica fica inflada.
- Módulo 5: o modelo salvo em pickle é verificado por SHA-256 antes de ser carregado (abrir um arquivo não confiável pode executar código) e roda com a versão do scikit-learn usada no treino (1.7.2), tirada do arquivo de travas e não do que estiver instalado localmente.
