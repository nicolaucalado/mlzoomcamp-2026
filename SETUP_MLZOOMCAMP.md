# Setup ML Zoomcamp 2026 — MacBook (macOS 26.7.1, Apple Silicon)

Ambiente configurado para exercícios do curso Machine Learning Zoomcamp 2026 e
atuação profissional em Ciência/Engenharia de Dados.

## Componentes instalados

| Componente | Versão | Como usar |
|---|---|---|
| Homebrew | 7.x | `brew install <pacote>` |
| uv | 0.13.x | gerenciador Python/deps |
| Python | 3.12.15 (via uv) | isolado por projeto |
| Git | 2.56.0 | versionamento |
| GitHub CLI (`gh`) | 2.102.0 | PRs, issues, auth |
| Ollama | 0.40.6 | LLMs locais (grátis/ilimitado) |
| Colima + Docker | 0.10.3 / 29.9.1 | containers/deployment |
| Docker Compose | 5.6.0 | orquestração |

## Modelos locais (Ollama) — grátis e ilimitado

| Modelo | Tamanho | Uso |
|---|---|---|
| `qwen2.5-coder:7b` | 4.7 GB | Principal (código/automação) |
| `qwen2.5-coder:3b` | 1.9 GB | Small model (rápido) |

Escolha pelo tamanho de RAM (8 GB neste Mac): 7B é o teto confortável.

```bash
ollama list              # listar instalados
ollama run qwen2.5-coder:7b   # teste interativo
brew services start ollama    # iniciar serviço (auto-start)
```

## Estrutura de diretórios

```
~/projects/
├── mlzoomcamp-2026/              # SEU repo (atividades)
│   ├── 01-02-regression/
│   ├── 03-classification/
│   ├── pyproject.toml
│   ├── requirements.txt
│   ├── requirements-all.txt
│   ├── uv.lock
│   └── .venv/
└── machine-learning-zoomcamp-official/   # repo oficial do curso
```

## Ambiente Python (uv)

```bash
cd ~/projects/mlzoomcamp-2026

uv sync                    # instala deps base
uv sync --extra dev --extra ml --extra deploy   # todos os grupos
uv add <pacote>            # adicionar dependência
uv run python script.py    # rodar no ambiente
uv run jupyter lab         # abrir JupyterLab
source .venv/bin/activate  # ativar manualmente
```

Kernel Jupyter registrado: **"Python (ML Zoomcamp 2026)"**

## Pacotes por categoria

- **Dados/ML base:** pandas, numpy, scipy, scikit-learn, pyarrow
- **Visualização:** matplotlib, seaborn
- **Notebooks:** jupyterlab, notebook, ipykernel, ipywidgets
- **Deploy:** flask, gunicorn, fastapi, uvicorn, boto3, mlflow
- **ML extra:** xgboost, lightgbm
- **Qualidade:** ruff, black, isort, pytest, pre-commit, mypy
- **Deep Learning (instalado):** tensorflow 2.21, torch 2.14
  (Apple MPS/GPU disponível: `torch.backends.mps.is_available()` → True)

## Docker (Colima)

```bash
colima start              # iniciar VM Docker
colima status
docker ps
docker run --rm hello-world
colima stop               # parar (libera RAM)
brew services start colima  # auto-start no login
```

Recursos alocados: 2 CPU / 3 GB RAM / 30 GB disco (ajustável em `colima start --help`).
Colima e Ollama estão configurados para iniciar automaticamente no login
(`brew services start colima` / `brew services start ollama`).

## Git / GitHub

- `user.name=nicolaucalado` / `user.email=nicolaucalado@gmail.com`
- Chave SSH: `~/.ssh/id_ed25519` (adicionar a pública no GitHub)
- Após adicionar a chave: `ssh -T git@github.com` deve responder com seu usuário

## Fluxo de trabalho sugerido

```bash
# Novo exercício
cd ~/projects/mlzoomcamp-2026
git checkout -b hw5
# trabalhando...
uv run jupyter lab
git add -A && git commit -m "HW5"
git push -u origin hw5
# abrir PR via gh
gh pr create --fill
```

## Automação: pre-commit

```bash
cd ~/projects/mlzoomcamp-2026
uv run pre-commit install    # ativa hooks no git
uv run pre-commit run --all-files
```

## Notas de performance (8 GB RAM)

- Prefira modelos 7B ou menores no Ollama.
- Ao rodar Colima, evite rodar LLM grande simultaneamente.
- Use `uv` em vez de pip para velocidade e resolução de dependências.
