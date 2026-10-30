# Learning in public — Módulo 9 do ML Zoomcamp 2026 (deep learning sem servidor)

Para o campo "Learning in public links" da tarefa 9, cole o link do post depois de publicar.

**Publique só depois de rodar o contêiner na sua máquina (passo da questão 6).** O texto abaixo diz que o contêiner Lambda foi invocado localmente; isso precisa ser verdade quando você publicar.

Antes de publicar:
- Digite "@Alexey" e escolha o perfil na lista do LinkedIn; o mesmo para @DataTalks.Club. Sem isso vira texto simples e não notifica.
- Confira se o link do repositório abre e se a pasta `09-serverless` já está lá.
- O enunciado pede para remover credenciais e dados privados de logs e prints. Se usar print do terminal, confira o caminho de pastas e o nome de usuário que aparecem nele.
- Os números do artigo em revisão ficaram de fora de propósito, como combinado.

---

## Versão em português

Módulo 9 do ML Zoomcamp 2026: deep learning sem servidor ✅

O classificador de cabelo do módulo anterior virou um modelo ONNX congelado. Eu o executei com ONNX Runtime, reproduzi o pré-processamento da imagem, empacotei tudo em um handler compatível com o AWS Lambda e invoquei o contêiner Lambda na minha própria máquina, sem conta na nuvem.

O que aprendi, além dos comandos:

🔹 O pré-processamento faz parte do modelo. Tamanho, interpolação, ordem dos canais e normalização precisam ser idênticos entre o notebook e o contêiner. O mesmo código roda nos dois lugares, e é isso que garante que as duas respostas coincidam.

🔹 Integridade antes de tudo. O modelo e a imagem foram conferidos por SHA-256 antes do uso, e a imagem base do contêiner é fixada por digest, não só por tag.

🔹 Carregar o modelo uma vez, fora do handler. Assim as invocações seguintes não pagam o custo de abrir o arquivo de 80 MB.

🤔 O que me fez parar: o handler baixa qualquer URL que receber. Num serviço real isso abre espaço para falsificação de requisição, e o certo seria aceitar só hosts confiáveis. E uma probabilidade confiante em uma única foto não diz nada sobre a qualidade do modelo, que no módulo anterior acertou cerca de 72% nas imagens de avaliação.

Como pesquisador, o paralelo é direto: um serviço que responde rápido não é, por isso, um serviço que responde certo.

➡️ Próximo passo: módulo 10, Kubernetes e TensorFlow Serving.

Repositório (notebook bilíngue EN/PT): https://github.com/nicolaucalado/mlzoomcamp-2026

Obrigado @Alexey Grigorev e @DataTalks.Club pelo curso.

#mlzoomcamp #cienciadedados #python #onnx #aws

---

## English version

Module 9 of ML Zoomcamp 2026: serverless deep learning ✅

The hair classifier from the previous module became a frozen ONNX model. I ran it with ONNX Runtime, reproduced the image preprocessing, wrapped everything in an AWS Lambda-compatible handler and invoked the Lambda container on my own machine, with no cloud account.

What I learned, beyond the commands:

🔹 Preprocessing is part of the model. Size, interpolation, channel order and normalization have to be identical between the notebook and the container. The same code runs in both places, which is what makes the two answers agree.

🔹 Integrity first. The model and the image were checked by SHA-256 before use, and the container base image is pinned by digest, not just by tag.

🔹 Load the model once, outside the handler. That way later invocations do not pay for opening an 80 MB file.

🤔 What made me stop: the handler downloads whatever URL it receives. In a real service that opens the door to request forgery, and the right fix is to accept trusted hosts only. And a confident probability on one photo says nothing about model quality, which in the previous module got about 72% right on the held-out images.

As a researcher, the parallel is direct: a service that answers fast is not necessarily a service that answers right.

➡️ Next: module 10, Kubernetes and TensorFlow Serving.

Repo (bilingual EN/PT notebook): https://github.com/nicolaucalado/mlzoomcamp-2026

Thanks @Alexey Grigorev and @DataTalks.Club for the course.

#mlzoomcamp #datascience #python #onnx #aws
