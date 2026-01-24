# Melhorias de Performance KasmVNC - Plano Incremental

## 🎯 Objetivo
Melhorar performance do streaming KasmVNC após aumento de DPI/resolução, testando mudanças incrementalmente.

## 📊 Níveis de Melhoria (do Mais Seguro ao Mais Agressivo)

### Nível 1: Configurações de Encoding (MAIS SEGURO) ⭐
**Impacto**: Médio | **Risco**: Muito Baixo

Ajustar compressão e qualidade do stream sem mexer no servidor.

**Arquivo**: Configuração do Kasm (Admin Panel)
**Mudanças**:
- Encoding: JPEG → WebP (melhor compressão)
- Quality: 5 → 7 (melhor qualidade com pouco impacto)
- Frame Rate: 24 → 30 fps

**Como testar**: Admin → Workspaces → [devbox] → Streaming Settings

---

### Nível 2: Otimizações de Rede (SEGURO) ⭐⭐
**Impacto**: Médio | **Risco**: Baixo

Melhorar buffer e compressão de rede.

**Arquivo**: Docker Run Config Override
**Mudanças**:
```json
{
  "environment": {
    "KASM_VNC_COMPRESSION_LEVEL": "2",
    "KASM_VNC_JPEG_QUALITY": "7",
    "KASM_VNC_WEBP_QUALITY": "7",
    "KASM_VNC_FRAME_RATE": "30"
  }
}
```

---

### Nível 3: Shared Memory (MODERADO) ⭐⭐⭐
**Impacto**: Alto | **Risco**: Médio

Aumentar /dev/shm para melhor performance de buffer.

**Arquivo**: Docker Run Config Override
**Mudanças**:
```json
{
  "shm_size": "2gb"
}
```

**Nota**: Você já tem `--disable-dev-shm-usage` no Antigravity, isso é bom.

---

### Nível 4: Configuração KasmVNC (MODERADO) ⭐⭐⭐⭐
**Impacto**: Alto | **Risco**: Médio-Alto

Criar arquivo de configuração customizado do KasmVNC.

**Arquivo**: `src/ubuntu/install/devbox/kasmvnc.yaml` (NOVO)
**Mudanças**: Ver arquivo separado

---

### Nível 5: Compilação Customizada (AVANÇADO) ⭐⭐⭐⭐⭐
**Impacto**: Muito Alto | **Risco**: Alto

Compilar KasmVNC com otimizações específicas.

**Nota**: **NÃO RECOMENDADO** inicialmente. Só se níveis 1-4 não funcionarem.

---

## 🚀 Plano de Execução Recomendado

### Fase 1: Testes Rápidos (Sem Rebuild)
1. ✅ Nível 1: Ajustar no Admin Panel
2. ✅ Testar por 30 minutos
3. ✅ Se melhorar → continuar | Se piorar → reverter

### Fase 2: Configurações Docker (Rebuild Rápido)
1. ✅ Nível 2: Adicionar variáveis de ambiente
2. ✅ Rebuild da imagem
3. ✅ Testar por 1 hora
4. ✅ Se melhorar → continuar | Se piorar → reverter

### Fase 3: Shared Memory (Rebuild Rápido)
1. ✅ Nível 3: Adicionar shm_size
2. ✅ Rebuild da imagem
3. ✅ Testar por 2 horas
4. ✅ Se melhorar → continuar | Se piorar → reverter

### Fase 4: Configuração Avançada (Rebuild Completo)
1. ✅ Nível 4: Criar kasmvnc.yaml
2. ✅ Rebuild completo
3. ✅ Testar por 1 dia
4. ✅ Se estável → commit | Se instável → reverter

---

## 📝 Checklist de Teste

Para cada nível, verificar:
- [ ] Stream está fluido?
- [ ] Latência aceitável?
- [ ] Sem core dumps?
- [ ] CPU/RAM estáveis?
- [ ] Antigravity funciona bem?

---

## 🔄 Como Reverter

### Se algo der errado:
1. **Nível 1-2**: Reverter no Admin Panel
2. **Nível 3-4**: Fazer rollback da imagem anterior
3. **Git**: `git checkout <arquivo>` para reverter mudanças

---

## 💡 Recomendação Inicial

**Comece com Nível 1** (Admin Panel):
- Zero risco
- Sem rebuild
- Resultados imediatos
- Fácil de reverter

Se funcionar bem, avançamos para Nível 2.

---

## 📊 Métricas para Acompanhar

```bash
# Dentro do container
# CPU/RAM
top

# Processos KasmVNC
ps aux | grep vnc

# Logs do KasmVNC
tail -f ~/.vnc/*.log
```
