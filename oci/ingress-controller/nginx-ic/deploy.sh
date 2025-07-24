#!/bin/bash

set -euo pipefail

# NGINX Ingress Controller Deployment Script
# Self-contained and idempotent deployment for OCI/OKE

# Configuration (can be overridden via environment variables)
CHART_NAME="${CHART_NAME:-nginx-ingress}"
CHART_VERSION="${CHART_VERSION:-4.11.3}"
NAMESPACE="${NAMESPACE:-nginx-ingress}"
CHART_REPO="${CHART_REPO:-https://kubernetes.github.io/ingress-nginx}"
VALUES_FILE="${VALUES_FILE:-values.yaml}"
TIMEOUT="${TIMEOUT:-600s}"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if kubectl is available and connected
    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_error "kubectl is not available or not connected to a cluster"
        exit 1
    fi
    
    # Check if helm is available
    if ! command -v helm >/dev/null 2>&1; then
        log_error "helm is not available"
        exit 1
    fi
    
    # Check if values file exists
    if [[ ! -f "$VALUES_FILE" ]]; then
        log_error "Values file '$VALUES_FILE' not found"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Deploy NGINX Ingress Controller
deploy_nginx_ingress() {
    log_info "Starting NGINX Ingress Controller deployment..."
    
    # Show configuration
    log_info "Deployment Configuration:"
    echo "  Chart Repository: $CHART_REPO"
    echo "  Chart Version: $CHART_VERSION"
    echo "  Namespace: $NAMESPACE"
    echo "  Release Name: $CHART_NAME"
    echo "  Values File: $VALUES_FILE"
    echo "  Timeout: $TIMEOUT"
    
    # Create namespace (idempotent)
    log_info "Ensuring namespace '$NAMESPACE' exists..."
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    
    # Add/update Helm repository (idempotent)
    log_info "Adding/updating Helm repository..."
    helm repo add ingress-nginx "$CHART_REPO" >/dev/null 2>&1 || true
    helm repo update >/dev/null
    
    # Deploy/upgrade NGINX Ingress Controller (idempotent)
    log_info "Deploying NGINX Ingress Controller..."
    helm upgrade --install "$CHART_NAME" ingress-nginx/ingress-nginx \
        --version "$CHART_VERSION" \
        --namespace "$NAMESPACE" \
        --values "$VALUES_FILE" \
        --wait \
        --timeout="$TIMEOUT"
    
    log_success "NGINX Ingress Controller deployed successfully!"
}

# Wait for controller to be ready
wait_for_controller() {
    log_info "Waiting for NGINX Ingress Controller to be ready..."
    
    if kubectl wait --namespace "$NAMESPACE" \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s; then
        log_success "NGINX Ingress Controller is ready!"
    else
        log_error "Timeout waiting for NGINX Ingress Controller to be ready"
        return 1
    fi
}

# Display deployment information
show_deployment_info() {
    log_info "Deployment Information:"
    
    echo ""
    echo "📋 NGINX Ingress Controller Service:"
    kubectl get svc -n "$NAMESPACE" -l app.kubernetes.io/component=controller
    
    echo ""
    echo "� NGINX Ingress Controller Pods:"
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/component=controller
    
    echo ""
    echo "📋 IngressClass:"
    kubectl get ingressclass nginx 2>/dev/null || echo "  IngressClass 'nginx' not found"
    
    echo ""
    echo "� Useful commands:"
    echo "  Check status: kubectl get pods -n $NAMESPACE"
    echo "  Check service: kubectl get svc -n $NAMESPACE"
    echo "  Check ingress class: kubectl get ingressclass"
    echo "  View logs: kubectl logs -n $NAMESPACE -l app.kubernetes.io/component=controller"
    
    echo ""
    echo "� To create an ingress resource, use: ingressClassName: nginx"
    echo "💡 LoadBalancer service includes OCI bandwidth annotations for optimal performance."
}

# Main execution
main() {
    echo "🚀 NGINX Ingress Controller Deployment"
    echo "======================================"
    
    check_prerequisites
    deploy_nginx_ingress
    wait_for_controller
    show_deployment_info
    
    log_success "Deployment completed successfully!"
}

# Execute main function
main "$@"