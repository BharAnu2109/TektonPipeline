#!/bin/bash

set -e

echo "🚀 Running Tekton Pipeline..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if the pipeline exists
if ! kubectl get pipeline tekton-demo-pipeline -n tekton-pipelines &> /dev/null; then
    echo "❌ Pipeline 'tekton-demo-pipeline' not found. Run setup-tekton.sh first."
    exit 1
fi

# Generate a unique name for the pipeline run
PIPELINE_RUN_NAME="tekton-demo-pipeline-run-$(date +%s)"

echo "📋 Creating PipelineRun: $PIPELINE_RUN_NAME"

# Create the pipeline run
cat <<EOF | kubectl apply -f -
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: $PIPELINE_RUN_NAME
  namespace: tekton-pipelines
  labels:
    app: tekton-demo
    pipeline: tekton-demo-pipeline
spec:
  serviceAccountName: tekton-pipeline-sa
  pipelineRef:
    name: tekton-demo-pipeline
  params:
    - name: git-url
      value: "https://github.com/BharAnu2109/TektonPipeline.git"
    - name: git-revision
      value: "main"
    - name: image-registry
      value: "docker.io"
    - name: image-namespace
      value: "your-dockerhub-username"  # Replace with actual username
    - name: image-name
      value: "tekton-demo-app"
    - name: image-tag
      value: "v1.0.0"
    - name: deploy-namespace
      value: "default"
    - name: app-name
      value: "tekton-demo-app"
  workspaces:
    - name: shared-data
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
    - name: docker-credentials
      secret:
        secretName: docker-credentials
        optional: true
  timeouts:
    pipeline: "1h0m0s"
    tasks: "0h30m0s"
    finally: "0h5m0s"
EOF

echo "✅ PipelineRun created: $PIPELINE_RUN_NAME"
echo ""
echo "Monitor the pipeline run:"
echo "  kubectl get pipelineruns -n tekton-pipelines"
echo "  kubectl describe pipelinerun $PIPELINE_RUN_NAME -n tekton-pipelines"
echo "  kubectl logs -f pipelinerun/$PIPELINE_RUN_NAME -n tekton-pipelines"
echo ""
echo "View tasks:"
echo "  kubectl get taskruns -n tekton-pipelines -l tekton.dev/pipelineRun=$PIPELINE_RUN_NAME"
echo ""
echo "Cancel the pipeline run (if needed):"
echo "  kubectl patch pipelinerun $PIPELINE_RUN_NAME -n tekton-pipelines --type merge -p '{\"spec\":{\"status\":\"Cancelled\"}}'"