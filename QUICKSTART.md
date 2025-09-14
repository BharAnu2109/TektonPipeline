# Tekton CI/CD Pipeline - Quick Reference

## Setup Commands

```bash
# 1. Setup Tekton Pipeline
./scripts/setup-tekton.sh

# 2. Update credentials (replace with actual values)
# Edit tekton/secrets/docker-credentials.yaml
# Edit tekton/secrets/github-secrets.yaml

# 3. Apply secrets
kubectl apply -f tekton/secrets/

# 4. Run pipeline
./scripts/run-pipeline.sh
```

## Monitor Pipeline

```bash
# List pipeline runs
kubectl get pipelineruns -n tekton-pipelines

# Watch pipeline execution
kubectl get pipelineruns -n tekton-pipelines -w

# View detailed logs
kubectl logs -f pipelinerun/PIPELINE_RUN_NAME -n tekton-pipelines

# Check individual tasks
kubectl get taskruns -n tekton-pipelines -l tekton.dev/pipelineRun=PIPELINE_RUN_NAME
```

## Test Application Locally

```bash
# Install dependencies
npm install

# Run linting
npm run lint

# Run tests
npm test

# Start application
npm start

# Test endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/api/info
```

## Docker Build Test

```bash
# Build image locally
docker build -t tekton-demo-app:test .

# Run container
docker run -p 3000:3000 tekton-demo-app:test

# Test health check
docker exec CONTAINER_ID wget -qO- http://localhost:3000/health
```

## Cleanup

```bash
# Remove pipeline resources
./scripts/cleanup.sh

# Or manual cleanup
kubectl delete pipelineruns --all -n tekton-pipelines
kubectl delete taskruns --all -n tekton-pipelines
```

## Important Files to Customize

1. **tekton/secrets/docker-credentials.yaml** - Docker Hub credentials
2. **tekton/secrets/github-secrets.yaml** - GitHub credentials and webhook secret
3. **tekton/pipelines/tekton-demo-pipeline-run.yaml** - Pipeline parameters
4. **k8s/deployment.yaml** - Application deployment configuration

## Troubleshooting

- Check Tekton installation: `kubectl get pods -n tekton-pipelines`
- View events: `kubectl get events -n tekton-pipelines --sort-by='.lastTimestamp'`
- Check secrets: `kubectl get secrets -n tekton-pipelines`
- Debug tasks: `kubectl describe taskrun TASK_RUN_NAME -n tekton-pipelines`