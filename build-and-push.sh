#!/bin/bash
# Script para buildar e fazer upload da imagem Kasm DevBox para Docker Hub

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}Kasm DevBox - Build & Push Script${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""

# Verificar se está usando Docker ou Podman
if command -v docker &> /dev/null; then
    CONTAINER_CMD="docker"
elif command -v podman &> /dev/null; then
    CONTAINER_CMD="podman"
else
    echo -e "${RED}Erro: Docker ou Podman não encontrado!${NC}"
    exit 1
fi

echo -e "${YELLOW}Usando: $CONTAINER_CMD${NC}"
echo ""

# Solicitar usuário do Docker Hub
read -p "Digite seu usuário do Docker Hub: " DOCKER_USER

if [ -z "$DOCKER_USER" ]; then
    echo -e "${RED}Erro: Usuário não pode ser vazio!${NC}"
    exit 1
fi

# Solicitar tag da imagem
echo ""
echo "Sugestões de tag:"
echo "  1) latest"
echo "  2) 1.0.0"
echo "  3) noble"
echo "  4) Personalizada"
read -p "Escolha uma opção (1-4): " TAG_OPTION

case $TAG_OPTION in
    1) IMAGE_TAG="latest" ;;
    2) IMAGE_TAG="1.0.0" ;;
    3) IMAGE_TAG="noble" ;;
    4) 
        read -p "Digite a tag personalizada: " IMAGE_TAG
        if [ -z "$IMAGE_TAG" ]; then
            echo -e "${RED}Erro: Tag não pode ser vazia!${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}Opção inválida! Usando 'latest'${NC}"
        IMAGE_TAG="latest"
        ;;
esac

# Nome completo da imagem
IMAGE_NAME="${DOCKER_USER}/kasm-ubuntu-noble-devbox:${IMAGE_TAG}"

echo ""
echo -e "${GREEN}Imagem será criada como: ${IMAGE_NAME}${NC}"
echo ""

# Verificar se está logado no Docker Hub
echo -e "${YELLOW}Verificando login no Docker Hub...${NC}"
if ! $CONTAINER_CMD login docker.io --get-login &> /dev/null; then
    echo -e "${YELLOW}Você não está logado. Fazendo login...${NC}"
    $CONTAINER_CMD login docker.io
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro ao fazer login!${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ Login verificado${NC}"
echo ""

# Confirmar antes de buildar
read -p "Iniciar build? Isso pode levar 30-60 minutos. (s/N): " CONFIRM

if [[ ! $CONFIRM =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Build cancelado.${NC}"
    exit 0
fi

# Iniciar build
echo ""
echo -e "${GREEN}==================================${NC}"
echo -e "${GREEN}Iniciando build da imagem...${NC}"
echo -e "${GREEN}==================================${NC}"
echo ""

START_TIME=$(date +%s)

$CONTAINER_CMD build \
    -f dockerfile-kasm-ubuntu-noble-devbox \
    -t $IMAGE_NAME \
    --progress=plain \
    .

if [ $? -ne 0 ]; then
    echo -e "${RED}Erro durante o build!${NC}"
    exit 1
fi

END_TIME=$(date +%s)
BUILD_DURATION=$((END_TIME - START_TIME))
BUILD_MINUTES=$((BUILD_DURATION / 60))
BUILD_SECONDS=$((BUILD_DURATION % 60))

echo ""
echo -e "${GREEN}✓ Build concluído em ${BUILD_MINUTES}m ${BUILD_SECONDS}s${NC}"
echo ""

# Verificar tamanho da imagem
IMAGE_SIZE=$($CONTAINER_CMD images $IMAGE_NAME --format "{{.Size}}")
echo -e "${YELLOW}Tamanho da imagem: ${IMAGE_SIZE}${NC}"
echo ""

# Fazer push para Docker Hub
read -p "Fazer upload para Docker Hub? (s/N): " PUSH_CONFIRM

if [[ $PUSH_CONFIRM =~ ^[Ss]$ ]]; then
    echo ""
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}Fazendo upload para Docker Hub...${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo ""
    
    PUSH_START=$(date +%s)
    
    $CONTAINER_CMD push $IMAGE_NAME
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Erro durante o push!${NC}"
        exit 1
    fi
    
    PUSH_END=$(date +%s)
    PUSH_DURATION=$((PUSH_END - PUSH_START))
    PUSH_MINUTES=$((PUSH_DURATION / 60))
    PUSH_SECONDS=$((PUSH_DURATION % 60))
    
    echo ""
    echo -e "${GREEN}✓ Upload concluído em ${PUSH_MINUTES}m ${PUSH_SECONDS}s${NC}"
    echo ""
    echo -e "${GREEN}==================================${NC}"
    echo -e "${GREEN}Sucesso!${NC}"
    echo -e "${GREEN}==================================${NC}"
    echo ""
    echo -e "Imagem disponível em: ${YELLOW}https://hub.docker.com/r/${DOCKER_USER}/kasm-ubuntu-noble-devbox${NC}"
    echo ""
    echo "Para usar no Kasm Workspaces:"
    echo -e "  ${YELLOW}${IMAGE_NAME}${NC}"
    echo ""
else
    echo -e "${YELLOW}Upload cancelado. Imagem disponível localmente como: ${IMAGE_NAME}${NC}"
fi

echo ""
echo -e "${GREEN}Processo finalizado!${NC}"
