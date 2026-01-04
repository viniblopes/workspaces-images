# Arquivos Necessários para Build da Imagem DevBox

Este repositório foi simplificado para conter apenas os arquivos necessários para buildar a imagem `kasm-ubuntu-noble-devbox`.

## Arquivos Mantidos

### Dockerfile e Scripts
- `dockerfile-kasm-ubuntu-noble-devbox` - Dockerfile principal
- `src/ubuntu/install/` - Scripts de instalação necessários
  - Scripts customizados: antigravity, dbeaver, flutter, fvm, devbox
  - Scripts do Kasm: dind, tools, chrome, chromium, sublime_text, vs_code, postman, gimp, zoom, redroid, cleanup

### Documentação
- `README.md` - Documentação principal
- `README-devbox.md` - Documentação detalhada
- `LICENSE.md` - Licença do projeto

### Utilitários
- `build-and-push.sh` - Script para build e push da imagem

## Arquivos Removidos

Todos os outros Dockerfiles e documentações do repositório original Kasm foram removidos pois não são necessários para buildar a imagem devbox.

## Como Usar

### Build Local
```bash
./build-and-push.sh
```

Ou manualmente:
```bash
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t kasm-devbox:latest .
```

### Pull do Docker Hub
```bash
docker pull viniblopes/kasm-ubuntu-noble-devbox:latest
```

## Estrutura Simplificada

```
.
├── README.md                              # Este arquivo
├── README-devbox.md                       # Documentação completa
├── LICENSE.md                             # Licença
├── dockerfile-kasm-ubuntu-noble-devbox    # Dockerfile
├── build-and-push.sh                      # Script de build
└── src/ubuntu/install/                    # Scripts de instalação
    ├── antigravity/
    ├── dbeaver/
    ├── devbox/
    ├── flutter/
    ├── fvm/
    ├── redroid/
    ├── dind/
    ├── tools/
    ├── misc/
    ├── chrome/
    ├── chromium/
    ├── sublime_text/
    ├── vs_code/
    ├── postman/
    ├── gimp/
    ├── zoom/
    └── cleanup/
```
