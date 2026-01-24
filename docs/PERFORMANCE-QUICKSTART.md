# Guia Rápido: Melhorar Performance KasmVNC

## ✅ Core Dumps Resolvidos!

Agora vamos melhorar performance de forma segura e incremental.

## 🎯 Começar Aqui: Nível 1 (SEM REBUILD)

### No Kasm Admin Panel:

1. **Admin → Workspaces → [devbox] → Edit**
2. Role até **Streaming Settings**
3. Ajuste:
   - **Encoding**: JPEG → **WebP**
   - **Quality**: 5 → **7**
   - **FPS**: 24 → **30**
   - **Compression**: 3 → **2**
4. **Save**
5. **Teste por 30 minutos**

### Verificar Melhoria:
- Stream mais fluido?
- Latência OK?
- Sem travamentos?

**✅ Se melhorou**: Avançar para Nível 2
**❌ Se piorou**: Reverter configurações

---

## 🚀 Nível 2: Variáveis de Ambiente (REBUILD RÁPIDO)

### Aplicar:
```bash
cd /home/vbecker/workspaces/workspaces-images
./apply-level2-performance.sh
```

### Build:
```bash
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t devbox:perf-v2 .
```

### Testar por 1 hora

### Reverter se necessário:
```bash
mv dockerfile-kasm-ubuntu-noble-devbox.backup dockerfile-kasm-ubuntu-noble-devbox
```

---

## 📊 Nível 3: Shared Memory (REBUILD RÁPIDO)

### No Kasm Admin → Docker Run Config Override:

Adicionar:
```json
{
  "shm_size": "2gb"
}
```

Mesclar com sua config existente de GPU.

---

## 🎮 Sua Configuração Atual + Performance

```json
{
  "hostname": "kasm",
  "environment": {
    "GDK_SCALE": "2",
    "GDK_DPI_SCALE": "0.75",
    "QT_SCALE_FACTOR": "0.75",
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

## ⚠️ Importante

- **Testar UMA mudança por vez**
- **Aguardar tempo suficiente** antes de próxima mudança
- **Fazer backup** antes de cada mudança
- **Documentar** o que funcionou/não funcionou

---

## 📝 Checklist de Teste

Para cada nível:
- [ ] Stream fluido?
- [ ] Latência aceitável?
- [ ] Sem core dumps?
- [ ] CPU/RAM OK?
- [ ] Antigravity funciona?

---

## 🆘 Se Algo Der Errado

1. **Reverter última mudança**
2. **Rebuild com versão anterior**
3. **Reportar o problema**

Consulte `KASMVNC-PERFORMANCE-PLAN.md` para detalhes completos.
