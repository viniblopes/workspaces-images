# Kasm Ubuntu Noble DevBox

Imagem Kasm customizada para desenvolvimento full-stack com suporte completo a Docker, Android, Flutter e ferramentas de desenvolvimento.

## 🚀 Ferramentas Incluídas

### Browsers & Communication
- **Google Chrome** - Navegador web principal
- **Chromium** - Navegador alternativo
- **Zoom** - Videoconferência (com suporte a webcam)

### IDEs & Editors
- **VS Code** - Editor de código da Microsoft
- **Antigravity IDE** - IDE do Google
- **Sublime Text** - Editor de texto avançado

### Database Tools
- **DBeaver** - Cliente universal de banco de dados

### API Development
- **Postman** - Plataforma de desenvolvimento de APIs

### Mobile Development
- **Android Studio** - IDE oficial para Android
- **Redroid** - Emulador Android em container
- **scrcpy** - Espelhamento de tela Android
- **Flutter SDK** - Framework de desenvolvimento mobile
- **FVM** - Flutter Version Manager
- **Android SDK Tools** - Ferramentas de linha de comando

### Graphics & Design
- **Gimp** - Editor de imagens

### DevOps & Infrastructure
- **Docker** - Containerização (Docker-in-Docker)
- **Docker Compose** - Orquestração de containers

### Utilities
- Ferramentas deluxe (git, curl, wget, vim, etc.)
- Ferramentas de desenvolvimento Python
- Java Development Kit (JDK 17)

## 📋 Pré-requisitos

- Kasm Workspaces instalado e configurado
- Docker CE
- Mínimo 8GB RAM recomendado
- 100GB+ de espaço em disco

### Para Proxmox LXC

Se você está rodando Kasm em um LXC no Proxmox:

1. **Habilitar nesting** no LXC:
   ```conf
   features: nesting=1
   ```

2. **Para suporte a webcam**, consulte o guia completo em:
   - [Configuração de Webcam no Proxmox LXC](./docs/webcam_proxmox_lxc_setup.md)

## 🏗️ Build da Imagem

### Build Local

```bash
cd /path/to/workspaces-images
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t kasm-devbox:latest .
```

### Build com Tag Customizada

```bash
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t seu-registry/kasm-devbox:1.0.0 .
```

## 🎯 Uso

### 1. Registrar a Imagem no Kasm

1. Acesse o painel administrativo do Kasm
2. Vá para **Workspaces** → **Workspace Registry**
3. Clique em **Add Workspace**
4. Configure:
   - **Workspace Type**: Container
   - **Docker Image**: `kasm-devbox:latest`
   - **Friendly Name**: Ubuntu Noble DevBox
   - **Description**: Ambiente de desenvolvimento completo
   - **Cores**: 4 (recomendado)
   - **Memory**: 8192 MB (recomendado)
   - **GPU**: Opcional

### 2. Criar uma Sessão

1. No painel do usuário, clique em **Launch** na workspace DevBox
2. Aguarde a inicialização (primeira vez pode demorar)
3. Acesse o desktop virtual

## 🔧 Configuração Pós-Instalação

### Flutter

Ao abrir um terminal pela primeira vez, execute:

```bash
flutter doctor -v
```

Isso verificará a instalação e mostrará o que precisa ser configurado.

### Android Development

#### Configurar Android SDK

As variáveis de ambiente já estão configuradas:
- `ANDROID_HOME=/opt/android-sdk`
- `ANDROID_SDK_ROOT=/opt/android-sdk`

#### Iniciar Redroid (Emulador Android)

```bash
start-redroid
```

Isso iniciará um container Android. Para conectar via ADB:

```bash
adb connect localhost:5555
```

Para espelhar a tela:

```bash
scrcpy --serial localhost:5555
```

#### Parar Redroid

```bash
stop-redroid
```

### FVM (Flutter Version Manager)

Instalar uma versão específica do Flutter:

```bash
fvm install 3.16.0
fvm use 3.16.0
```

Listar versões disponíveis:

```bash
fvm releases
```

### Docker

Docker já está rodando em modo DinD (Docker-in-Docker). Você pode usar normalmente:

```bash
docker ps
docker run hello-world
docker-compose up
```

## 📁 Estrutura de Diretórios

```
/home/kasm-user/
├── workspace/          # Diretório de trabalho principal
├── .android/           # Configurações do Android
├── .fvm/              # Versões do Flutter gerenciadas pelo FVM
└── Desktop/           # Ícones das aplicações
```

## 🎥 Webcam no Zoom

### Requisitos

1. **No Host Proxmox/LXC**: Configurar passthrough de dispositivo (veja guia completo)
2. **No LXC**: Instalar e configurar `v4l2loopback`

### Uso

1. Abra o Zoom
2. No painel de controle do Kasm (ícone no canto), clique em **Webcam**
3. Permita o acesso quando solicitado pelo navegador
4. A webcam deve aparecer nas configurações de vídeo do Zoom

### Troubleshooting

Se a webcam não aparecer:

```bash
# Verificar se v4l2loopback está carregado
lsmod | grep v4l2loopback

# Listar dispositivos de vídeo
ls -la /dev/video*

# Verificar logs do Kasm
docker logs -f kasm_agent
```

## 🐛 Troubleshooting

### Core Dump Files Filling Disk

**Problema**: Container não inicia ou está lento devido a arquivos `core.*` enormes no Desktop

**Causa**: Algum aplicativo (Chrome, VS Code, etc.) está crashando e gerando core dumps

**Solução**:

1. **Se o container está rodando**:
   ```bash
   # Acesse o container
   docker exec -it <container-id> bash
   
   # Remova os core dumps
   rm -f ~/Desktop/core.*
   rm -f ~/core.*
   ```

2. **Se o container não inicia**:
   ```bash
   # Use o script de emergência
   cd /path/to/workspaces-images
   ./emergency-cleanup.sh <container-name>
   ```

3. **Prevenção**: Reconstrua a imagem com as correções mais recentes que desabilitam core dumps

**Verificar se core dumps estão desabilitados**:
```bash
# Dentro do container
ulimit -c
# Deve retornar: 0
```


### Build Falha

**Problema**: Erro durante o build da imagem

**Solução**:
```bash
# Limpar cache do Docker
docker builder prune -a

# Tentar build novamente
docker build --no-cache -f dockerfile-kasm-ubuntu-noble-devbox -t kasm-devbox:latest .
```

### Flutter não encontrado

**Problema**: Comando `flutter` não encontrado

**Solução**:
```bash
# Recarregar variáveis de ambiente
source /etc/profile.d/flutter.sh

# Ou reiniciar o terminal
```

### Docker não inicia

**Problema**: Docker daemon não está rodando

**Solução**:
```bash
# Verificar se o LXC tem nesting habilitado
# No host Proxmox:
pct config <CTID> | grep nesting

# Deve mostrar: features: nesting=1
```

### Redroid não inicia

**Problema**: Container Redroid falha ao iniciar

**Solução**:
```bash
# Verificar logs
docker logs redroid-13

# Recriar container
docker rm -f redroid-13
start-redroid
```

### Antigravity IDE não instala

**Problema**: Erro ao adicionar repositório do Google

**Solução**:
```bash
# Verificar conectividade
curl -I https://us-central1-apt.pkg.dev

# Reinstalar manualmente
sudo apt update
sudo apt install antigravity
```

## 🔐 Segurança

### Considerações

- Esta imagem roda Docker-in-Docker, que requer privilégios elevados
- Redroid também requer modo privilegiado para funcionar corretamente
- Não exponha esta imagem diretamente à internet sem proteção adequada
- Use sempre através do Kasm Workspaces com autenticação

### Recomendações

1. Configure autenticação forte no Kasm
2. Use HTTPS para acesso ao Kasm
3. Limite acesso por IP se possível
4. Mantenha a imagem atualizada regularmente

## 📊 Recursos Recomendados

### Mínimo
- **CPU**: 2 cores
- **RAM**: 4GB
- **Disk**: 50GB

### Recomendado
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Disk**: 100GB+

### Ideal (para desenvolvimento Android/Flutter)
- **CPU**: 8+ cores
- **RAM**: 16GB+
- **Disk**: 200GB+
- **GPU**: Passthrough (opcional, para melhor performance)

## 🔄 Atualizações

### Atualizar a Imagem

```bash
# Rebuild com mesma tag
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t kasm-devbox:latest .

# Ou com nova versão
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t kasm-devbox:2.0.0 .
```

### Atualizar Ferramentas Dentro da Imagem

As ferramentas são instaladas durante o build. Para atualizar:

1. Reconstrua a imagem (isso baixará as versões mais recentes)
2. Ou, dentro de uma sessão ativa:
   ```bash
   sudo apt update
   sudo apt upgrade
   ```

## 📚 Recursos Adicionais

- [Kasm Workspaces Documentation](https://kasmweb.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Android Developer Guide](https://developer.android.com)
- [Redroid GitHub](https://github.com/remote-android/redroid-doc)
- [Docker Documentation](https://docs.docker.com)

## 🤝 Contribuindo

Para melhorias nesta imagem:

1. Modifique os scripts em `src/ubuntu/install/`
2. Atualize o Dockerfile se necessário
3. Teste o build
4. Documente as mudanças

## 📝 Licença

Esta imagem é baseada no projeto Kasm Workspaces Images e segue a mesma licença.

## ✨ Créditos

- **Kasm Technologies** - Base images e framework
- **Google** - Antigravity IDE, Flutter, Android
- **Comunidade Open Source** - Todas as ferramentas incluídas

---

**Desenvolvido para uso com Kasm Workspaces** 🚀
