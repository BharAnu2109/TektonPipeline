#!/bin/bash

set -e

echo "🧹 Cleaning up Tekton Pipeline resources..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Delete pipeline runs
echo "🗑️  Deleting PipelineRuns..."
kubectl delete pipelineruns --all -n tekton-pipelines

# Delete task runs
echo "🗑️  Deleting TaskRuns..."
kubectl delete taskruns --all -n tekton-pipelines

# Delete triggers
echo "🗑️  Deleting Triggers..."
kubectl delete -f tekton/triggers/ --ignore-not-found=true

# Delete pipeline
echo "🗑️  Deleting Pipeline..."
kubectl delete -f tekton/pipelines/tekton-demo-pipeline.yaml --ignore-not-found=true

# Delete tasks
echo "🗑️  Deleting Tasks..."
kubectl delete -f tekton/tasks/ --ignore-not-found=true

# Delete secrets (optional)
read -p "Do you want to delete secrets? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting Secrets..."
    kubectl delete -f tekton/secrets/ --ignore-not-found=true
fi

# Delete RBAC
echo "🗑️  Deleting RBAC..."
kubectl delete -f tekton/rbac/rbac.yaml --ignore-not-found=true

# Delete application deployment
read -p "Do you want to delete application deployment? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️  Deleting Application..."
    kubectl delete -f k8s/deployment.yaml --ignore-not-found=true
fi

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "Note: Tekton Pipelines and Triggers are still installed in the cluster."
echo "To completely remove Tekton:"
echo "  kubectl delete --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml"
echo "  kubectl delete --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml"