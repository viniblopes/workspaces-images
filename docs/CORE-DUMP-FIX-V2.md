# Fix v2 - Core Dumps do Antigravity

## Problema Raiz
O wrapper não estava sendo usado - Antigravity lançado diretamente.

## Solução
1. **Substituição do binário**: Original renomeado para `antigravity.bin`, wrapper criado no lugar
2. **Ulimit forçado**: Adicionado em bashrc e profile
3. **Impossível ignorar**: Qualquer forma de lançar usa o wrapper

## Build e Teste

```bash
# Build
docker build -f dockerfile-kasm-ubuntu-noble-devbox -t devbox:fix-v2 .

# Verificar dentro do container
ulimit -c  # Deve ser 0
env | grep ELECTRON  # Deve mostrar variáveis
ps aux | grep antigravity  # Deve mostrar antigravity.bin
```

## Arquivos Modificados
- `src/ubuntu/install/antigravity/install_antigravity.sh`
- `dockerfile-kasm-ubuntu-noble-devbox`
