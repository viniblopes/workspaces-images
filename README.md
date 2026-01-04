# Kasm Ubuntu Noble DevBox

Imagem Kasm customizada para desenvolvimento full-stack com Docker-in-Docker, Flutter, Android e ferramentas de desenvolvimento.

## 🚀 Ferramentas Incluídas

- **Docker-in-Docker** - Containerização completa
- **Browsers**: Chrome, Chromium
- **IDEs**: VS Code, Antigravity IDE, Sublime Text
- **Database**: DBeaver
- **API**: Postman
- **Mobile**: Flutter SDK, FVM, Redroid, Android SDK Tools
- **Graphics**: Gimp
- **Communication**: Zoom (com suporte a webcam)

## 📦 Imagem no Docker Hub

```bash
docker pull viniblopes/kasm-ubuntu-noble-devbox:latest
```

## 🏗️ Build Local

```bash
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t kasm-devbox:latest .
```

## 📋 Uso no Kasm Workspaces

1. Acesse o painel administrativo do Kasm
2. **Workspaces** → **Workspace Registry** → **Add Workspace**
3. Configure:
   - **Docker Image**: `viniblopes/kasm-ubuntu-noble-devbox:latest`
   - **Friendly Name**: Ubuntu Noble DevBox
   - **Cores**: 4 (recomendado)
   - **Memory**: 8192 MB (recomendado)

## 📚 Documentação Completa

Consulte [README-devbox.md](README-devbox.md) para documentação detalhada incluindo:
- Configuração pós-instalação
- Uso de Flutter e FVM
- Configuração de webcam para Proxmox LXC
- Troubleshooting

## 🔧 Estrutura do Projeto

```
.
├── dockerfile-kasm-ubuntu-noble-devbox    # Dockerfile principal
├── README-devbox.md                       # Documentação completa
├── build-and-push.sh                      # Script de build e push
└── src/ubuntu/install/                    # Scripts de instalação
    ├── antigravity/                       # Antigravity IDE
    ├── dbeaver/                           # DBeaver
    ├── flutter/                           # Flutter SDK
    ├── fvm/                               # Flutter Version Manager
    ├── devbox/                            # Custom startup
    └── redroid/                           # Redroid (modificado)
```

## 📊 Tamanho da Imagem

- **Tamanho**: ~10.5 GB
- **Base**: Ubuntu Noble 24.04 LTS

## 🔗 Links

- **Docker Hub**: https://hub.docker.com/r/viniblopes/kasm-ubuntu-noble-devbox
- **Kasm Workspaces**: https://kasmweb.com

## 📝 Licença

Baseado no projeto [Kasm Workspaces Images](https://github.com/kasmtech/workspaces-images)
