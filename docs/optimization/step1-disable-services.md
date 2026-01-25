# Etapa 1: Desabilitar Serviços Desnecessários

## Data
2026-01-25

## Objetivo
Desabilitar `whoopsie` (crash reporter) e `cups` (serviço de impressão) para reduzir consumo de CPU em 5-10%.

## Baseline Medido
```
Date: 2026-01-25 18:56
Load average: 0.98, 1.00, 0.95
CPU: ~25% us, ~11% sy, ~63% id

Top CPU consumers:
- Xvnc: 24.8% CPU
- Antigravity (zygote): 13.4% CPU
- ffmpeg: 3.8% CPU
- xfwm4: 1.0% CPU

Running services:
- cups ✓
- saslauthd ✓
- supervisor ✓
- whoopsie ✓
```

## Implementação

### Arquivos Criados/Modificados

1. **[NOVO]** `src/ubuntu/install/misc/disable_services.sh`
   - Script para desabilitar whoopsie e cups
   - Usa systemctl e update-rc.d para garantir que não iniciem

2. **[MODIFICADO]** `dockerfile-kasm-ubuntu-noble-devbox`
   - Adicionada linha para executar `disable_services.sh` após instalação de ferramentas base
   - Linha 79: `RUN bash $INST_DIR/ubuntu/install/misc/disable_services.sh`

### Como Testar

Para testar em um container existente:
```bash
# Executar o script manualmente
sudo bash src/ubuntu/install/misc/disable_services.sh

# Verificar serviços
service --status-all | grep -E 'whoopsie|cups'

# Medir CPU novamente
./docs/optimization/measure-cpu.sh step1-after
```

Para testar na nova build:
```bash
# Rebuild a imagem
./build-and-push.sh

# Iniciar container e verificar
service --status-all | grep -E 'whoopsie|cups'
```

## Próximos Passos

Após rebuild e teste:
1. Medir CPU usage com `measure-cpu.sh step1-after`
2. Comparar com baseline
3. Documentar resultados em `progress.md`
4. Se bem-sucedido, prosseguir para Etapa 2 (Otimizar Áudio)

## Rollback

Se necessário reverter:
```bash
# Reabilitar serviços
sudo systemctl enable whoopsie.service
sudo systemctl enable cups.service
sudo service whoopsie start
sudo service cups start
```

Ou simplesmente fazer rebuild sem a linha adicionada no Dockerfile.
