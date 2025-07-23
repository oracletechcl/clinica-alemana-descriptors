#!/bin/bash

set -euo pipefail

# NGINX Ingress Controller Undeploy Script
# Self-contained and idempotent undeployment for OCI/OKE

# Configuration (can be overridden via environment variables)
CHART_NAME="${CHART_NAME:-nginx-ingress}"
NAMESPACE="${NAMESPACE:-nginx-ingress}"
FORCE="${FORCE:-false}"

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
    
    log_success "Prerequisites check passed"
}

# Confirm undeployment
confirm_undeploy() {
    if [[ "$FORCE" == "true" ]]; then
        log_warning "Force mode enabled - skipping confirmation"
        return 0
    fi
    
    log_warning "This will remove the NGINX Ingress Controller and all associated resources."
    log_warning "This will affect ALL ingress resources using the nginx IngressClass."
    echo ""
    
    log_info "Current ingress resources that may be affected:"
    kubectl get ingress --all-namespaces --no-headers 2>/dev/null | head -10 || echo "   No ingress resources found"
    echo ""
    
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Undeploy cancelled."
        exit 0
    fi
}

# Undeploy NGINX Ingress Controller
undeploy_nginx_ingress() {
    log_info "Starting NGINX Ingress Controller undeployment..."
    
    # Show configuration
    log_info "Undeploy Configuration:"
    echo "  Namespace: $NAMESPACE"
    echo "  Release Name: $CHART_NAME"
    
    # Check if the release exists and uninstall it
    if helm list -n "$NAMESPACE" --short | grep -q "^$CHART_NAME$"; then
        log_info "Uninstalling Helm release: $CHART_NAME"
        helm uninstall "$CHART_NAME" -n "$NAMESPACE"
        log_success "Helm release uninstalled successfully"
    else
        log_info "Helm release '$CHART_NAME' not found in namespace '$NAMESPACE'"
    fi
    
    # Wait for pods to terminate
    log_info "Waiting for NGINX Ingress Controller pods to terminate..."
    kubectl wait --for=delete pods --all -n "$NAMESPACE" --timeout=120s 2>/dev/null || true
}

# Clean up remaining resources
cleanup_resources() {
    log_info "Cleaning up remaining resources..."
    
    # Clean up webhook configurations
    log_info "Cleaning up webhook configurations..."
    kubectl delete validatingwebhookconfiguration nginx-ingress-admission --ignore-not-found=true
    kubectl delete mutatingwebhookconfiguration nginx-ingress-admission --ignore-not-found=true
    
    # Clean up IngressClass
    log_info "Cleaning up IngressClass..."
    kubectl delete ingressclass nginx --ignore-not-found=true
    
    # Clean up any remaining services in the namespace
    log_info "Cleaning up remaining services..."
    kubectl delete services --all -n "$NAMESPACE" --ignore-not-found=true
    
    # Check if namespace is empty and remove it
    if kubectl get all -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l | grep -q "^0$"; then
        log_info "Removing empty namespace: $NAMESPACE"
        kubectl delete namespace "$NAMESPACE" --ignore-not-found=true
        log_success "Namespace removed"
    else
        log_info "Namespace '$NAMESPACE' contains other resources, keeping it"
    fi
}

# Display cleanup information
show_cleanup_info() {
    log_info "Cleanup Information:"
    
    echo ""
    echo "📋 Remaining IngressClasses:"
    if kubectl get ingressclasses --no-headers 2>/dev/null | wc -l | grep -q "^0$"; then
        echo "   No IngressClasses found"
    else
        kubectl get ingressclasses --no-headers 2>/dev/null | awk '{print "   - " $1 " (" $2 ")"}'
    fi
    
    echo ""
    echo "📋 Remaining Ingress Resources:"
    INGRESS_COUNT=$(kubectl get ingress --all-namespaces --no-headers 2>/dev/null | wc -l)
    if [ "$INGRESS_COUNT" -eq 0 ]; then
        echo "   No ingress resources found"
    else
        echo "   Found $INGRESS_COUNT ingress resource(s) - may need manual attention:"
        kubectl get ingress --all-namespaces --no-headers 2>/dev/null | head -5 | awk '{print "   - " $2 " (namespace: " $1 ")"}'
        if [ "$INGRESS_COUNT" -gt 5 ]; then
            echo "   ... and $(($INGRESS_COUNT - 5)) more"
        fi
    fi
    
    echo ""
    echo "📋 Remaining LoadBalancer Services:"
    LB_COUNT=$(kubectl get services --all-namespaces --field-selector spec.type=LoadBalancer --no-headers 2>/dev/null | wc -l)
    if [ "$LB_COUNT" -eq 0 ]; then
        echo "   No LoadBalancer services found"
    else
        echo "   Found $LB_COUNT LoadBalancer service(s):"
        kubectl get services --all-namespaces --field-selector spec.type=LoadBalancer --no-headers 2>/dev/null | head -3 | awk '{print "   - " $2 " (namespace: " $1 ")"}'
    fi
    
    echo ""
    echo "� Verification commands:"
    echo "  Check pods: kubectl get pods -n $NAMESPACE"
    echo "  Check services: kubectl get services --all-namespaces --field-selector spec.type=LoadBalancer"
    echo "  Check ingress: kubectl get ingress --all-namespaces"
    echo "  Check ingress classes: kubectl get ingressclasses"
    
    if [ "$INGRESS_COUNT" -gt 0 ]; then
        echo ""
        log_warning "Applications using ingress resources may now be unreachable"
        echo "  Consider deploying another ingress controller or updating ingress resources"
    fi
}

# Main execution
main() {
    echo "🗑️  NGINX Ingress Controller Undeployment"
    echo "========================================="
    
    check_prerequisites
    confirm_undeploy
    undeploy_nginx_ingress
    cleanup_resources
    show_cleanup_info
    
    log_success "Undeployment completed successfully!"
}

# Execute main function
main "$@"
