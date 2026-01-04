#!/bin/bash
# Script para limpar o repositório e manter apenas arquivos necessários para devbox

set -e

echo "🧹 Limpando repositório..."
echo ""

# Remover todos os Dockerfiles exceto o devbox
echo "Removendo Dockerfiles desnecessários..."
find . -maxdepth 1 -name "dockerfile-kasm-*" ! -name "dockerfile-kasm-ubuntu-noble-devbox" -type f -delete

# Remover diretório docs (documentação de outras imagens)
if [ -d "docs" ]; then
    echo "Removendo diretório docs..."
    rm -rf docs
fi

# Remover diretório ci-scripts (não necessário para build manual)
if [ -d "ci-scripts" ]; then
    echo "Removendo ci-scripts..."
    rm -rf ci-scripts
fi

# Remover .gitlab-ci.yml
if [ -f ".gitlab-ci.yml" ]; then
    echo "Removendo .gitlab-ci.yml..."
    rm -f .gitlab-ci.yml
fi

# Remover logs
echo "Removendo arquivos de log..."
rm -f build.log push.log "log executado.log" log 2>/dev/null || true

# Limpar diretórios src que não são usados pela devbox
echo "Limpando diretórios src não utilizados..."

# Lista de diretórios que DEVEM ser mantidos
KEEP_DIRS=(
    "antigravity"
    "dbeaver"
    "devbox"
    "flutter"
    "fvm"
    "redroid"
    "dind"
    "tools"
    "misc"
    "chrome"
    "chromium"
    "sublime_text"
    "vs_code"
    "postman"
    "gimp"
    "zoom"
    "cleanup"
)

# Remover outros diretórios em src/ubuntu/install/
if [ -d "src/ubuntu/install" ]; then
    for dir in src/ubuntu/install/*/; do
        dirname=$(basename "$dir")
        keep=false
        for keep_dir in "${KEEP_DIRS[@]}"; do
            if [ "$dirname" == "$keep_dir" ]; then
                keep=true
                break
            fi
        done
        
        if [ "$keep" = false ]; then
            echo "  Removendo src/ubuntu/install/$dirname/"
            rm -rf "$dir"
        fi
    done
fi

# Remover outros diretórios src não necessários
echo "Removendo outros diretórios src..."
rm -rf src/alpine src/debian src/fedora src/kali src/kasmos src/opensuse src/oracle src/parrot src/rhel src/rockylinux 2>/dev/null || true

echo ""
echo "✅ Limpeza concluída!"
echo ""
echo "📁 Estrutura mantida:"
echo "  - dockerfile-kasm-ubuntu-noble-devbox"
echo "  - README.md"
echo "  - README-devbox.md"
echo "  - LICENSE.md"
echo "  - build-and-push.sh"
echo "  - CLEANUP.md"
echo "  - src/ubuntu/install/ (apenas diretórios necessários)"
echo ""
echo "Para ver o que foi mantido, consulte CLEANUP.md"
