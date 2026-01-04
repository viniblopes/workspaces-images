# Redroid - Android in Docker

Este diretório contém os scripts de instalação e validação do Redroid para a imagem Kasm.

## 📋 Arquivos

- **`install_redroid.sh`** - Script de instalação do Redroid e ferramentas Android
- **`validate_redroid.sh`** - Script de validação para testar a configuração
- **`custom_startup.sh`** - Script de inicialização customizado

## 🚀 Como Usar

### 1. Validar a Instalação

Após iniciar sua workspace Kasm, execute o script de validação:

```bash
# Tornar o script executável
chmod +x /path/to/validate_redroid.sh

# Executar a validação
./validate_redroid.sh
```

### 2. Carregar Variáveis de Ambiente

Se o script reportar que as variáveis de ambiente não estão configuradas:

```bash
# Carregar variáveis do Android SDK
source /etc/profile.d/android.sh

# Carregar variáveis do FVM (se usar Flutter)
source /etc/profile.d/fvm.sh

# Executar validação novamente
./validate_redroid.sh
```

## 🧪 O Que o Script de Validação Testa

O `validate_redroid.sh` verifica:

1. **ADB (Android Debug Bridge)** - Ferramenta de linha de comando para Android
2. **scrcpy** - Ferramenta de espelhamento de tela
3. **Android SDK** - SDK do Android e ferramentas de linha de comando
4. **Flutter** - Framework de desenvolvimento (se instalado)
5. **FVM** - Flutter Version Manager (se instalado)
6. **Dependências** - ffmpeg, wget, git, jq
7. **Conexão Redroid** - Tenta conectar ao dispositivo Android
8. **Variáveis de Ambiente** - Verifica ANDROID_HOME, PUB_CACHE, etc.

## 📱 Comandos Úteis do Redroid

### Conectar ao Redroid

```bash
# Conectar via ADB
adb connect localhost:5555

# Listar dispositivos
adb devices
```

### Espelhar Tela com scrcpy

```bash
# Iniciar espelhamento
scrcpy --serial localhost:5555

# Ou usar o launcher do desktop
# Procure por "scrcpy (Screen Mirror)" no menu de aplicativos
```

### Gerenciar Apps

```bash
# Instalar APK
adb install caminho/para/app.apk

# Listar apps instalados
adb shell pm list packages

# Desinstalar app
adb uninstall com.package.name

# Iniciar app
adb shell am start -n com.package.name/.MainActivity
```

### Informações do Dispositivo

```bash
# Versão do Android
adb shell getprop ro.build.version.release

# Modelo do dispositivo
adb shell getprop ro.product.model

# Informações de hardware
adb shell getprop | grep ro.product
```

### Screenshots e Gravação

```bash
# Tirar screenshot
adb shell screencap /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Gravar tela (Ctrl+C para parar)
adb shell screenrecord /sdcard/demo.mp4
adb pull /sdcard/demo.mp4
```

### Logs e Debug

```bash
# Ver logs em tempo real
adb logcat

# Filtrar logs por tag
adb logcat -s TAG_NAME

# Limpar logs
adb logcat -c
```

## 🔧 Desenvolvimento Flutter com Redroid

Se você usa Flutter, o Redroid funciona como um dispositivo Android normal:

```bash
# Verificar se Flutter detecta o dispositivo
flutter devices

# Executar app Flutter no Redroid
flutter run

# Executar em modo debug
flutter run -d <device-id>

# Hot reload
# Pressione 'r' no terminal durante execução

# Hot restart
# Pressione 'R' no terminal durante execução
```

## 🛠️ Ferramentas Instaladas

### Android SDK Tools

- **sdkmanager** - Gerenciador de pacotes do SDK
- **platform-tools** - Ferramentas de plataforma (adb, fastboot)
- **build-tools** - Ferramentas de build (versão 34.0.0)
- **platforms** - Android API 34

### Comandos SDK

```bash
# Listar pacotes instalados
sdkmanager --list_installed

# Listar pacotes disponíveis
sdkmanager --list

# Instalar pacote
sdkmanager "package-name"

# Atualizar todos os pacotes
sdkmanager --update
```

## 🐛 Troubleshooting

### Redroid não conecta

```bash
# Verificar se o container está rodando
docker ps | grep redroid

# Ver logs do container
docker logs <container-id>

# Reiniciar conexão ADB
adb kill-server
adb start-server
adb connect localhost:5555
```

### Flutter não encontrado

```bash
# Adicionar Flutter ao PATH
export PATH=/opt/flutter/flutter/bin:$PATH

# Verificar instalação
flutter doctor

# Aceitar licenças Android
flutter doctor --android-licenses
```

### Variáveis de ambiente não carregadas

```bash
# Carregar manualmente
source /etc/profile.d/android.sh
source /etc/profile.d/fvm.sh

# Adicionar ao seu .bashrc ou .zshrc para carregar automaticamente
echo 'source /etc/profile.d/android.sh' >> ~/.bashrc
echo 'source /etc/profile.d/fvm.sh' >> ~/.bashrc
```

## 📚 Recursos Adicionais

- [Documentação ADB](https://developer.android.com/studio/command-line/adb)
- [Documentação scrcpy](https://github.com/Genymobile/scrcpy)
- [Redroid GitHub](https://github.com/remote-android/redroid-doc)
- [Flutter Docs](https://flutter.dev/docs)

## ✅ Resultado Esperado da Validação

Quando tudo estiver configurado corretamente, você deve ver:

```
✓ All critical tests passed!

Next steps to use Redroid:
  1. adb connect localhost:5555  - Connect to Redroid
  2. adb devices                 - List connected devices
  3. scrcpy --serial localhost:5555 - Mirror Android screen
  4. adb install app.apk         - Install an APK
```
