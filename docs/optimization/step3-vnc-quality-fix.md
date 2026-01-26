# Etapa 3: Correção de Qualidade do VNC

## 📊 Objetivo

Eliminar artefatos visuais (distorções, borrões) durante o scroll no Antigravity e outras aplicações, melhorando as configurações de qualidade do KasmVNC.

## 🔧 Implementação

### Problema Identificado

O usuário reportou **artefatos visuais** durante o scroll, indicando que as configurações atuais de compressão do VNC estão muito agressivas:

- `DynamicQualityMin: 7` - Muito baixo para scroll suave
- `DynamicQualityMax: 8` - Causando artefatos de compressão
- `TreatLossless: 10` - Não agressivo o suficiente para clareza de texto

### Solução Implementada

Criado script `/src/ubuntu/install/misc/optimize_vnc.sh` que configura o KasmVNC via arquivo YAML `/etc/kasmvnc/kasmvnc.yaml`.

#### Configurações Aplicadas

| Parâmetro | Antes | Depois | Impacto |
|-----------|-------|--------|---------|
| `DynamicQualityMin` | 7 | **8** | Maior qualidade durante movimento/scroll |
| `DynamicQualityMax` | 8 | **9** | Qualidade máxima para conteúdo estático |
| `TreatLossless` | 10 | **7** | Atualizações lossless mais frequentes para texto |
| `FrameRate` | 60 | **60** | Mantido para scroll suave |
| `VideoArea` | 45 | **60** | Melhor detecção de regiões de vídeo |
| `VideoTime` | 5 | **3** | Transição mais rápida para modo vídeo |
| `WebpVideoQuality` | - | **8** | Alta qualidade para encoding WebP |
| `JpegVideoQuality` | - | **8** | Alta qualidade para encoding JPEG |
| `PreferBandwidth` | - | **false** | Prioriza qualidade sobre largura de banda |

### Arquivos Modificados

1. **[NEW]** `src/ubuntu/install/misc/optimize_vnc.sh` - Script de otimização
2. **[MODIFIED]** `dockerfile-kasm-ubuntu-noble-devbox` - Adicionada execução do script

## 📝 Próximos Passos

1. **Commit e Push** das mudanças
2. **Rebuild** da imagem Docker
3. **Testar** eliminação de artefatos visuais
4. **Medir** impacto no CPU (pode aumentar levemente)
5. **Documentar** resultados

## ⚠️ Trade-offs

- ✅ **Benefício**: Eliminação de artefatos visuais, texto mais nítido
- ⚠️ **Custo**: CPU pode aumentar ~5-10% (trade-off aceitável)
- ✅ **Framerate**: Mantido em 60fps para experiência suave

## 🎯 Critérios de Sucesso

- ✅ Sem artefatos visuais durante scroll
- ✅ Texto nítido e legível em todos os momentos
- ✅ Experiência 60fps mantida
- ✅ Todas as aplicações renderizam corretamente
