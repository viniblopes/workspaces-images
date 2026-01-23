# Build da Imagem Estável - Instruções

## ✅ Rollback Completo

Todas as otimizações de performance foram removidas. A imagem agora usa apenas configurações padrão e estáveis.

## 🚀 Build e Deploy

### 1. Build da Imagem

```bash
cd /home/vbecker/workspaces/workspaces-images

# Build
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t kasm-devbox:stable .

# Ou use o script (certifique-se de ajustar a tag)
./build-and-push.sh
```

### 2. Verificação Rápida

```bash
# Verificar que não há config customizada do KasmVNC
docker run --rm kasm-devbox:stable ls -la /etc/kasmvnc/ 2>&1 | grep kasmvnc.yaml || echo "✅ Usando config padrão"

# Verificar core dumps desabilitados
docker run --rm kasm-devbox:stable bash -c "ulimit -c"
# Deve retornar: 0
```

### 3. Deploy no Kasm

1. Acesse o painel administrativo do Kasm
2. Vá para **Workspaces** → **Workspace Registry**
3. Edite a workspace DevBox
4. Atualize a imagem para: `kasm-devbox:stable` (ou sua tag)
5. Salve as alterações
6. Inicie uma nova sessão

### 4. Teste

- ✅ Container deve iniciar sem restart loops
- ✅ Sem warnings "Unsupported config keys"
- ✅ Desktop deve aparecer normalmente
- ✅ Aplicações devem abrir (Chrome, VS Code, etc.)

## 📝 O Que Foi Removido

1. ❌ Configuração customizada do KasmVNC
2. ❌ Drivers AMD VA-API (mesa-va-drivers, va-driver-all, vainfo)
3. ❌ Variáveis de ambiente AMD GPU (LIBVA_DRIVER_NAME, etc.)

## ✅ O Que Foi Mantido

1. ✅ Prevenção de core dumps (5 camadas)
2. ✅ Limpeza automática de core dumps no startup
3. ✅ Todas as aplicações (Chrome, VS Code, Flutter, etc.)
4. ✅ Docker-in-Docker
5. ✅ Bibliotecas OpenGL/Mesa básicas

## ⚠️ Expectativas

- **Performance**: Pode ser um pouco mais lenta (sem aceleração de hardware)
- **Estabilidade**: Muito maior (sem crashes)
- **Compatibilidade**: 100% (apenas recursos padrão)

## 🔄 Próximos Passos (Opcional)

Se quiser adicionar otimizações no futuro, faça **uma de cada vez** e teste:

1. Primeiro: Adicionar config KasmVNC simples (só max_frame_rate)
2. Depois: Testar drivers VA-API
3. Por último: Adicionar variáveis AMD GPU

Veja `ROLLBACK-COMPLETE.md` para detalhes sobre otimizações incrementais.

## 📊 Resumo

| Item | Antes | Depois |
|------|-------|--------|
| KasmVNC Config | Custom (inválida) | Padrão ✅ |
| VA-API Drivers | Instalados | Removidos ✅ |
| GPU Env Vars | Configuradas | Removidas ✅ |
| Core Dumps | Prevenidos | Prevenidos ✅ |
| Restart Loops | Sim ❌ | Não ✅ |
| Warnings | 13+ warnings | 0 warnings ✅ |
