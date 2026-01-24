#!/usr/bin/env bash
# Organizar repositório antes do commit
# Remove arquivos temporários e organiza documentação

set -e

echo "🧹 Organizando repositório..."

# Criar diretório docs se não existir
mkdir -p docs

# Mover documentação importante para docs/
echo "📁 Movendo documentação..."
mv FINAL-CONFIG.md docs/ 2>/dev/null || true
mv CORE-DUMP-FIX-V2.md docs/ 2>/dev/null || true
mv KASMVNC-PERFORMANCE-PLAN.md docs/ 2>/dev/null || true
mv HIDPI-RESOLUTION-ADJUSTMENT.md docs/ 2>/dev/null || true
mv PERFORMANCE-QUICKSTART.md docs/ 2>/dev/null || true

# Remover arquivos temporários/obsoletos
echo "🗑️  Removendo arquivos temporários..."
rm -f CORE-DUMP-FIX-SUMMARY.md
rm -f BUILD-STABLE.md
rm -f ROLLBACK-COMPLETE.md
rm -f FIXES-SUMMARY.md
rm -f CLEANUP.md

# Remover scripts temporários de teste
rm -f apply-level2-performance.sh
rm -f apply-level2a-performance.sh
rm -f apply-level2b-performance.sh
rm -f cleanup-core-dumps.sh
rm -f fix-antigravity-desktop.sh
rm -f emergency-cleanup.sh

# Manter apenas scripts úteis
echo "✅ Mantendo scripts úteis:"
echo "  - build-and-push.sh"
echo "  - cleanup-repo.sh (este script)"

# Remover backups do Dockerfile se existirem
rm -f dockerfile-kasm-ubuntu-noble-devbox.backup

echo ""
echo "✅ Repositório organizado!"
echo ""
echo "📂 Estrutura:"
echo "  /"
echo "  ├── docs/"
echo "  │   ├── FINAL-CONFIG.md"
echo "  │   ├── CORE-DUMP-FIX-V2.md"
echo "  │   ├── KASMVNC-PERFORMANCE-PLAN.md"
echo "  │   ├── HIDPI-RESOLUTION-ADJUSTMENT.md"
echo "  │   └── PERFORMANCE-QUICKSTART.md"
echo "  ├── src/"
echo "  ├── dockerfile-kasm-ubuntu-noble-devbox"
echo "  ├── build-and-push.sh"
echo "  └── README.md"
echo ""
echo "📝 Próximos passos:"
echo "1. git add ."
echo "2. git commit -m 'fix: resolve core dumps and optimize KasmVNC performance'"
echo "3. git push origin develop"
