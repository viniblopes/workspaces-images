# Ajuste de Resolução HiDPI - Configurações Recomendadas

## 🎯 Problema
As configurações de HiDPI deixaram a resolução muito alta, causando lentidão.

## 📊 Configuração Atual (Muito Alta)
```json
{
  "environment": {
    "GDK_SCALE": "2",           // 2x = Dobra a resolução
    "GDK_DPI_SCALE": "0.75",    // Reduz DPI em 25%
    "QT_SCALE_FACTOR": "0.75"   // Reduz Qt em 25%
  }
}
```

**Resultado**: Resolução efetiva muito alta (ex: 3840x2160 se tela for 1920x1080)

---

## ✅ Configurações Recomendadas (Balanceadas)

### Opção A: Escala 1.5x (RECOMENDADO)
Melhor balanço entre qualidade e performance.

```json
{
  "environment": {
    "GDK_SCALE": "1.5",
    "GDK_DPI_SCALE": "1",
    "QT_SCALE_FACTOR": "1.5",
    "KASM_VNC_COMPRESSION_LEVEL": "2",
    "KASM_VNC_JPEG_QUALITY": "7",
    "KASM_VNC_WEBP_QUALITY": "7",
    "KASM_VNC_FRAME_RATE": "30"
  }
}
```

**Resultado**: ~50% menos pixels que config atual, ainda com boa qualidade

---

### Opção B: Escala 1.25x (Mais Performance)
Se Opção A ainda estiver pesada.

```json
{
  "environment": {
    "GDK_SCALE": "1.25",
    "GDK_DPI_SCALE": "1",
    "QT_SCALE_FACTOR": "1.25",
    "KASM_VNC_COMPRESSION_LEVEL": "2",
    "KASM_VNC_JPEG_QUALITY": "7",
    "KASM_VNC_WEBP_QUALITY": "7",
    "KASM_VNC_FRAME_RATE": "30"
  }
}
```

**Resultado**: ~65% menos pixels que config atual, muito mais rápido

---

### Opção C: Sem Escala (Máxima Performance)
Se você não precisa de HiDPI.

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

**Resultado**: Resolução nativa, máxima performance

---

## 🔧 Como Aplicar

### No Kasm Admin Panel:
1. **Admin → Workspaces → [devbox] → Edit**
2. **Docker Run Config Override**
3. Substituir a seção `environment` por uma das opções acima
4. **Save**
5. **Restart workspace**
6. **Testar**

---

## 📊 Comparação de Performance

| Configuração | Pixels | Performance | Qualidade Visual |
|--------------|--------|-------------|------------------|
| Atual (2x) | 100% | ⭐ Lento | ⭐⭐⭐⭐⭐ Excelente |
| Opção A (1.5x) | ~56% | ⭐⭐⭐ Bom | ⭐⭐⭐⭐ Muito Bom |
| Opção B (1.25x) | ~39% | ⭐⭐⭐⭐ Muito Bom | ⭐⭐⭐ Bom |
| Opção C (1x) | ~25% | ⭐⭐⭐⭐⭐ Excelente | ⭐⭐ OK |

---

## 💡 Recomendação

**Comece com Opção A (1.5x)**:
- Boa qualidade visual
- Performance muito melhor que atual
- Fácil de ajustar se necessário

Se ainda estiver lento, tente Opção B (1.25x).

---

## 🎮 Configuração Completa Recomendada (com GPU)

```json
{
  "hostname": "kasm",
  "environment": {
    "GDK_SCALE": "1.5",
    "GDK_DPI_SCALE": "1",
    "QT_SCALE_FACTOR": "1.5",
    "HW3D": "true",
    "DRINODE": "/dev/dri/renderD128",
    "KASM_VNC_COMPRESSION_LEVEL": "2",
    "KASM_VNC_JPEG_QUALITY": "7",
    "KASM_VNC_WEBP_QUALITY": "7",
    "KASM_VNC_FRAME_RATE": "30"
  },
  "devices": [
    "/dev/dri/card0:/dev/dri/card0:rwm",
    "/dev/dri/renderD128:/dev/dri/renderD128:rwm"
  ],
  "group_add": ["video", "render"],
  "shm_size": "2gb"
}
```

---

## ⚡ Teste Rápido

Você pode testar diferentes escalas **sem rebuild**:

1. Mudar no Admin Panel
2. Restart workspace
3. Testar por 10-15 minutos
4. Ajustar se necessário

**Sem rebuild = testes rápidos!** 🚀
