#!/bin/bash

set -e

echo "🚀 Setting up Tekton CI/CD Pipeline..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Install Tekton Pipelines (if not already installed)
echo "📦 Installing Tekton Pipelines..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Wait for Tekton to be ready
echo "⏳ Waiting for Tekton Pipelines to be ready..."
kubectl wait --for=condition=ready pod --all -n tekton-pipelines --timeout=300s

# Install Tekton Triggers (if not already installed)
echo "📦 Installing Tekton Triggers..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Wait for Tekton Triggers to be ready
echo "⏳ Waiting for Tekton Triggers to be ready..."
kubectl wait --for=condition=ready pod --all -n tekton-pipelines --timeout=300s

# Create namespace for our pipeline
echo "🏗️  Creating tekton-pipelines namespace..."
kubectl apply -f tekton/rbac/rbac.yaml

# Apply RBAC
echo "🔐 Setting up RBAC..."
kubectl apply -f tekton/rbac/rbac.yaml

# Apply secrets (you'll need to update these with real credentials)
echo "🔑 Creating secrets..."
echo "⚠️  WARNING: Update the secrets with your actual credentials before running this script!"
echo "   - Update tekton/secrets/docker-credentials.yaml with your Docker Hub credentials"
echo "   - Update tekton/secrets/github-secrets.yaml with your GitHub credentials"
# kubectl apply -f tekton/secrets/

# Apply tasks
echo "📋 Creating Tekton Tasks..."
kubectl apply -f tekton/tasks/

# Apply pipeline
echo "🔧 Creating Tekton Pipeline..."
kubectl apply -f tekton/pipelines/tekton-demo-pipeline.yaml

# Apply triggers
echo "🎯 Creating Tekton Triggers..."
kubectl apply -f tekton/triggers/

echo ""
echo "✅ Tekton CI/CD Pipeline setup completed!"
echo ""
echo "Next steps:"
echo "1. Update secrets with your actual credentials:"
echo "   - tekton/secrets/docker-credentials.yaml"
echo "   - tekton/secrets/github-secrets.yaml"
echo "2. Apply the secrets: kubectl apply -f tekton/secrets/"
echo "3. Update pipeline parameters in tekton/pipelines/tekton-demo-pipeline-run.yaml"
echo "4. Run the pipeline: kubectl apply -f tekton/pipelines/tekton-demo-pipeline-run.yaml"
echo ""
echo "To monitor the pipeline:"
echo "  kubectl get pipelineruns -n tekton-pipelines"
echo "  kubectl logs -f pipelinerun/PIPELINE_RUN_NAME -n tekton-pipelines"
echo ""
echo "Dashboard URL (if Tekton Dashboard is installed):"
echo "  kubectl port-forward svc/tekton-dashboard 9097:9097 -n tekton-pipelines"