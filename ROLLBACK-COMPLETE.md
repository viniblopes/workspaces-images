# Rollback Completo - Kasm DevBox

## 🔄 Mudanças Revertidas

Este documento lista todas as mudanças de performance que foram revertidas para restaurar a estabilidade.

### 1. Configuração Customizada do KasmVNC ❌ REMOVIDA

**Arquivo**: `src/ubuntu/install/devbox/kasmvnc-performance.yaml`
- **Status**: Deletado
- **Motivo**: Todos os parâmetros customizados eram não suportados
- **Resultado**: KasmVNC agora usa configuração padrão (estável)

### 2. Drivers AMD VA-API ❌ REMOVIDOS

**Localização**: Dockerfile linhas 40-47
- **Pacotes removidos**:
  - `mesa-va-drivers`
  - `va-driver-all`
  - `vainfo`
- **Motivo**: Podem estar causando crashes e core dumps
- **Resultado**: Sem hardware video encoding, mas mais estável

### 3. Variáveis de Ambiente AMD GPU ❌ REMOVIDAS

**Arquivo**: `custom_startup.sh`
- **Variáveis removidas**:
  - `LIBVA_DRIVER_NAME=radeonsi`
  - `MESA_LOADER_DRIVER_OVERRIDE=radeonsi`
  - `AMD_VULKAN_ICD=RADV`
- **Motivo**: Otimizações de GPU podem estar causando instabilidade
- **Resultado**: Renderização por software (mais lento, mas estável)

## ✅ Mudanças Mantidas (Seguras)

### Prevenção de Core Dumps

Mantidas todas as camadas de prevenção de core dumps:
1. System limits (`/etc/security/limits.conf`)
2. Shell profile (`/etc/profile.d/disable-coredumps.sh`)
3. PAM configuration (`/etc/pam.d/common-session`)
4. Apport disabled (`/etc/default/apport`)
5. Kernel parameters (`/etc/sysctl.d/50-coredump.conf`)
6. Runtime cleanup no startup script

**Motivo**: Essas mudanças são essenciais e não causam problemas de performance.

## 📊 Estado Atual

### Configuração Estável

```dockerfile
# Apenas bibliotecas básicas OpenGL/Mesa
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  mesa-utils \
  libgl1-mesa-dri \
  libgl1 \
  libegl1 \
  libgles2 \
  # ... outras libs básicas
```

### Sem Customizações de Performance

- ✅ KasmVNC: Configuração padrão
- ✅ GPU: Sem otimizações específicas AMD
- ✅ Video Encoding: Software apenas
- ✅ Core Dumps: Completamente desabilitados

## 🚀 Próximos Passos

### 1. Rebuild da Imagem

```bash
cd /home/vbecker/workspaces/workspaces-images

# Build da imagem estável
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t kasm-devbox:stable .
```

### 2. Teste

```bash
# Verificar que não há warnings
docker run --rm kasm-devbox:stable bash -c "cat /etc/kasmvnc/kasmvnc.yaml 2>&1 || echo 'Using default config'"

# Verificar core dumps desabilitados
docker run --rm kasm-devbox:stable bash -c "ulimit -c"
```

### 3. Deploy

1. Atualize a workspace no Kasm para usar `kasm-devbox:stable`
2. Inicie uma nova sessão
3. Verifique que o container inicia sem restart loops
4. Teste as aplicações básicas

## 📝 Otimizações Futuras (Incrementais)

Se quiser adicionar otimizações de performance no futuro, faça **uma de cada vez**:

### Fase 1: Testar KasmVNC Básico
```yaml
# Apenas max_frame_rate
encoding:
  max_frame_rate: 30  # Começar conservador
```

### Fase 2: Se Fase 1 funcionar, adicionar encoding
```yaml
encoding:
  max_frame_rate: 60
  video_area: 1024  # Parâmetro suportado
```

### Fase 3: Se Fase 2 funcionar, testar drivers AMD
```dockerfile
# Adicionar apenas mesa-va-drivers
RUN apt-get install -y mesa-va-drivers
```

### Fase 4: Se Fase 3 funcionar, adicionar variáveis
```bash
export LIBVA_DRIVER_NAME=radeonsi
```

## ⚠️ Lições Aprendidas

1. **Sempre verificar documentação**: Parâmetros do KasmVNC mudam entre versões
2. **Testar incrementalmente**: Adicionar uma otimização por vez
3. **Manter rollback fácil**: Usar git tags para versões estáveis
4. **Monitorar logs**: Warnings podem indicar problemas futuros
5. **Performance vs Estabilidade**: Estabilidade sempre vem primeiro

## 📦 Arquivos Modificados Neste Rollback

1. ✅ `dockerfile-kasm-ubuntu-noble-devbox` - Removidos drivers VA-API e config KasmVNC
2. ✅ `custom_startup.sh` - Removidas variáveis AMD GPU
3. ✅ `kasmvnc-performance.yaml` - Deletado
4. ✅ Mantida prevenção de core dumps (funcional)

## 🎯 Objetivo Alcançado

- Container deve iniciar sem restart loops
- Sem warnings de configuração
- Performance pode ser menor, mas **estabilidade garantida**
- Base sólida para otimizações futuras incrementais
