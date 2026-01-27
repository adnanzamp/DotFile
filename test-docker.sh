#!/bin/bash

# Test script for dotfiles in Docker
# Usage: ./test-docker.sh [build|run|shell|clean]

set -e

IMAGE_NAME="dotfiles-test"
CONTAINER_NAME="dotfiles-test-container"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

case "${1:-run}" in
    build)
        print_status "Building Docker image..."
        docker build -f Dockerfile.test -t "$IMAGE_NAME" .
        print_success "Image built successfully!"
        ;;
    
    run)
        print_status "Building and running Docker container..."
        docker build -f Dockerfile.test -t "$IMAGE_NAME" .
        print_status "Starting container (will run bootstrap and drop into zsh)..."
        docker run -it --rm --name "$CONTAINER_NAME" "$IMAGE_NAME"
        ;;
    
    shell)
        print_status "Starting container with bash (no bootstrap)..."
        docker build -f Dockerfile.test -t "$IMAGE_NAME" .
        docker run -it --rm --name "$CONTAINER_NAME" "$IMAGE_NAME" /bin/bash
        ;;
    
    clean)
        print_status "Cleaning up Docker resources..."
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
        docker rmi "$IMAGE_NAME" 2>/dev/null || true
        print_success "Cleanup complete!"
        ;;
    
    *)
        echo "Usage: $0 [build|run|shell|clean]"
        echo ""
        echo "Commands:"
        echo "  build  - Build the Docker image only"
        echo "  run    - Build and run (default) - runs bootstrap and drops into zsh"
        echo "  shell  - Build and run with bash (skip bootstrap for debugging)"
        echo "  clean  - Remove Docker image and container"
        ;;
esac
