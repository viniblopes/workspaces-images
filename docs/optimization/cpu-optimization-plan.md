# Plano de Otimização de CPU - Kasm Image

## Status Atual

**Data de início**: 2026-01-25  
**CPU Usage Baseline**: 
- Xvnc: 80% CPU
- Antigravity: 50%+ CPU (múltiplos processos) - **NÃO SERÁ MODIFICADO**
- ffmpeg: 3.8% CPU
- Outros serviços: ~10% CPU

**Objetivo**: Reduzir consumo de CPU em 15-30% sem modificar o Antigravity

---

## Abordagem Incremental

Cada etapa será implementada, testada e validada antes de prosseguir para a próxima.

### ✅ Etapa 0: Baseline e Preparação
- [x] Análise inicial de CPU
- [x] Identificação de processos principais
- [x] Criação do plano de otimização
- [ ] Medição detalhada do baseline

### 📋 Etapa 1: Desabilitar Serviços Desnecessários
**Impacto estimado**: 5-10% redução de CPU  
**Risco**: Baixo  
**Reversível**: Sim

**Ações**:
- [ ] Desabilitar `whoopsie` (crash reporter do Ubuntu)
- [ ] Desabilitar `cups` (serviço de impressão)
- [ ] Medir impacto no CPU

**Arquivos afetados**:
- Configuração do supervisor ou systemd

**Como testar**:
```bash
# Antes
top -b -n 1 | head -20

# Verificar serviços
service --status-all | grep -E 'whoopsie|cups'

# Depois da mudança
top -b -n 1 | head -20
```

---

### 📋 Etapa 2: Otimizar Streaming de Áudio (FFmpeg)
**Impacto estimado**: 1-4% redução de CPU (ou 3.8% se desabilitar)  
**Risco**: Baixo (se áudio não for crítico)  
**Reversível**: Sim

**Opções**:
- **Opção A**: Reduzir bitrate de 128k para 64k
- **Opção B**: Desabilitar completamente o streaming de áudio

**Arquivos afetados**:
- Configuração do KasmVNC/supervisor que inicia o ffmpeg

**Como testar**:
```bash
# Verificar processo ffmpeg
ps aux | grep ffmpeg

# Testar áudio no navegador (se necessário)
# Medir CPU antes e depois
```

---

### 📋 Etapa 3: Otimizar KasmVNC
**Impacto estimado**: 8-16% redução de CPU do Xvnc  
**Risco**: Médio (pode afetar qualidade visual)  
**Reversível**: Sim

**Ações**:
- [ ] Reduzir framerate de 60fps para 30fps
- [ ] Ajustar compressão de vídeo
- [ ] Otimizar codec (se possível)

**Arquivos afetados**:
- Configuração do KasmVNC
- Variáveis de ambiente do VNC

**Como testar**:
```bash
# Verificar configuração atual do VNC
cat ~/.vnc/config 2>/dev/null || echo "Config not found"

# Medir CPU do Xvnc
ps aux | grep Xvnc

# Testar qualidade visual navegando na interface
```

---

### 📋 Etapa 4: Revisar Docker-in-Docker
**Impacto estimado**: Variável (daemon não está rodando atualmente)  
**Risco**: Baixo se não estiver em uso  
**Reversível**: Sim

**Ações**:
- [ ] Confirmar se Docker é necessário
- [ ] Se não: remover inicialização do Docker
- [ ] Se sim: otimizar configuração do daemon

**Arquivos afetados**:
- `src/ubuntu/install/dind/custom_startup.sh`
- `src/ubuntu/install/devbox/custom_startup.sh`
- `src/ubuntu/install/dind/daemon.json`

**Como testar**:
```bash
# Verificar se Docker está rodando
docker ps 2>/dev/null || echo "Docker not running"

# Se necessário, testar funcionalidade Docker
```

---

## Medições e Progresso

### Baseline (Antes das Otimizações)
```
Data: 2026-01-25 18:37
Load average: 1.14, 1.11, 0.95
CPU: 24.7% us, 11.4% sy, 62.7% id

Top Processes:
- Xvnc: 80% CPU
- Antigravity (zygote): 50% CPU
- Antigravity (main): 30% CPU
- ffmpeg: 3.8% CPU
- xfwm4: 1.1% CPU
```

### Após Etapa 1: Serviços
```
Data: [A PREENCHER]
Load average: 
CPU: 

Mudanças observadas:
- 
```

### Após Etapa 2: Áudio
```
Data: [A PREENCHER]
Load average: 
CPU: 

Mudanças observadas:
- 
```

### Após Etapa 3: VNC
```
Data: [A PREENCHER]
Load average: 
CPU: 

Mudanças observadas:
- 
```

### Após Etapa 4: Docker
```
Data: [A PREENCHER]
Load average: 
CPU: 

Mudanças observadas:
- 
```

---

## Notas e Observações

### Decisões Tomadas
- **Antigravity**: Não será modificado neste momento (solicitação do usuário)
- **Abordagem**: Incremental, testando cada etapa antes de prosseguir

### Questões Pendentes
1. **Docker**: Está sendo usado? (daemon não está rodando atualmente)
2. **Áudio**: É necessário streaming de áudio?
3. **Qualidade vs Performance**: Preferência do usuário para VNC

### Próximos Passos
- [ ] Responder questões pendentes
- [ ] Iniciar Etapa 1: Desabilitar serviços
- [ ] Medir e documentar resultados
- [ ] Prosseguir para próxima etapa

---

## Rollback Plan

Caso alguma otimização cause problemas:

1. **Serviços**: Reabilitar com `service <nome> start`
2. **Áudio**: Restaurar configuração original do ffmpeg
3. **VNC**: Restaurar configuração original do KasmVNC
4. **Docker**: Restaurar scripts de startup originais

Todos os arquivos originais devem ser backupeados antes das modificações.
