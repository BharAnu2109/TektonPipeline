# Tekton CI/CD Pipeline Demo

A complete CI/CD pipeline implementation using Tekton Pipelines for a Node.js application. This project demonstrates how to build, test, containerize, and deploy applications using Tekton on Kubernetes.

## 🚀 Features

- **Complete CI/CD Pipeline**: Automated build, test, and deployment workflow
- **Node.js Application**: Sample REST API with health checks and tests
- **Container Security**: Multi-stage Docker builds with non-root user
- **Kubernetes Deployment**: Production-ready deployment manifests
- **Webhook Triggers**: Automated pipeline execution on Git events
- **RBAC Configuration**: Secure service account and role-based access
- **Monitoring**: Health checks and logging integration

## 📁 Project Structure

```
TektonPipeline/
├── app.js                      # Node.js application
├── package.json                # Dependencies and scripts
├── Dockerfile                  # Container build instructions
├── .eslintrc.json             # ESLint configuration
├── test/                      # Test files
│   └── app.test.js
├── tekton/                    # Tekton CI/CD resources
│   ├── tasks/                 # Reusable pipeline tasks
│   │   ├── git-clone-task.yaml
│   │   ├── npm-test-task.yaml
│   │   ├── buildah-build-push-task.yaml
│   │   └── kubernetes-deploy-task.yaml
│   ├── pipelines/             # Pipeline definitions
│   │   ├── tekton-demo-pipeline.yaml
│   │   └── tekton-demo-pipeline-run.yaml
│   ├── triggers/              # Webhook and event triggers
│   │   └── github-webhook-trigger.yaml
│   ├── rbac/                  # Security and permissions
│   │   └── rbac.yaml
│   └── secrets/               # Credential templates
│       ├── docker-credentials.yaml
│       └── github-secrets.yaml
├── k8s/                       # Kubernetes manifests
│   └── deployment.yaml
└── scripts/                   # Utility scripts
    ├── setup-tekton.sh
    ├── run-pipeline.sh
    └── cleanup.sh
```

## 🛠️ Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured to access your cluster
- Docker Hub account (or other container registry)
- GitHub repository (for webhook triggers)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/BharAnu2109/TektonPipeline.git
cd TektonPipeline
```

### 2. Install Tekton

Run the setup script to install Tekton Pipelines and Triggers:

```bash
./scripts/setup-tekton.sh
```

### 3. Configure Secrets

Update the credential files with your actual values:

**Docker Registry Credentials:**
```bash
# Edit tekton/secrets/docker-credentials.yaml
# Replace YOUR_USERNAME and YOUR_PASSWORD with actual Docker Hub credentials

# Create the secret
kubectl apply -f tekton/secrets/docker-credentials.yaml
```

**GitHub Credentials (for private repos and webhooks):**
```bash
# Edit tekton/secrets/github-secrets.yaml
# Replace with your GitHub username and personal access token

# Create the secret
kubectl apply -f tekton/secrets/github-secrets.yaml
```

### 4. Update Pipeline Parameters

Edit `tekton/pipelines/tekton-demo-pipeline-run.yaml` and update:
- `image-namespace`: Your Docker Hub username
- `git-url`: Your repository URL (if different)

### 5. Run the Pipeline

```bash
./scripts/run-pipeline.sh
```

## 📋 Pipeline Workflow

The CI/CD pipeline consists of four main stages:

### 1. Source Code Checkout
- **Task**: `git-clone`
- **Description**: Clones source code from GitHub repository
- **Output**: Source code in shared workspace

### 2. Test and Lint
- **Task**: `npm-test`
- **Description**: Installs dependencies, runs linting, and executes tests
- **Steps**:
  - `npm ci` - Install dependencies
  - `npm run lint` - Code linting with ESLint
  - `npm run test` - Unit tests with Mocha

### 3. Build and Push Container
- **Task**: `buildah-build-push`
- **Description**: Builds Docker image and pushes to registry
- **Features**:
  - Rootless container builds with Buildah
  - Multi-stage builds for optimized images
  - Automatic image tagging and pushing

### 4. Deploy to Kubernetes
- **Task**: `kubernetes-deploy`
- **Description**: Deploys application to Kubernetes cluster
- **Resources Created**:
  - Deployment with 2 replicas
  - Service for internal communication
  - Health checks and resource limits

## 🎯 Monitoring and Observability

### View Pipeline Status
```bash
# List all pipeline runs
kubectl get pipelineruns -n tekton-pipelines

# Get detailed status
kubectl describe pipelinerun PIPELINE_RUN_NAME -n tekton-pipelines

# View logs
kubectl logs -f pipelinerun/PIPELINE_RUN_NAME -n tekton-pipelines
```

### View Application Status
```bash
# Check deployment
kubectl get deployments -n default
kubectl get pods -l app=tekton-demo-app

# Check application logs
kubectl logs -l app=tekton-demo-app -f

# Test application endpoints
kubectl port-forward svc/tekton-demo-app-service 8080:80
curl http://localhost:8080/health
```

## 🎣 Webhook Configuration

### GitHub Webhook Setup

1. Go to your GitHub repository settings
2. Navigate to Webhooks
3. Add a new webhook with:
   - **Payload URL**: `http://YOUR_CLUSTER_IP:8080` (EventListener service)
   - **Content type**: `application/json`
   - **Secret**: The token from `tekton/secrets/github-secrets.yaml`
   - **Events**: Push events

### Expose EventListener (for external access)
```bash
# Option 1: NodePort service
kubectl patch svc el-github-webhook-listener -n tekton-pipelines -p '{"spec":{"type":"NodePort"}}'

# Option 2: LoadBalancer (cloud providers)
kubectl patch svc el-github-webhook-listener -n tekton-pipelines -p '{"spec":{"type":"LoadBalancer"}}'

# Option 3: Port forwarding (testing)
kubectl port-forward svc/el-github-webhook-listener 8080:8080 -n tekton-pipelines
```

## 🔧 Customization

### Adding New Tasks

1. Create a new task YAML file in `tekton/tasks/`
2. Define the task specification with required parameters and workspaces
3. Add the task to your pipeline in `tekton/pipelines/tekton-demo-pipeline.yaml`

### Modifying the Application

The sample Node.js application includes:
- REST API endpoints (`/`, `/health`, `/api/info`)
- Unit tests with Mocha and Chai
- ESLint configuration for code quality
- Docker health checks

Modify `app.js` and corresponding tests to fit your application needs.

### Environment-Specific Deployments

Create separate pipeline runs for different environments:

```yaml
# staging-pipeline-run.yaml
spec:
  params:
    - name: deploy-namespace
      value: "staging"
    - name: image-tag
      value: "staging-$(git-revision)"
```

## 🧹 Cleanup

To remove all Tekton resources:

```bash
./scripts/cleanup.sh
```

To completely uninstall Tekton from your cluster:

```bash
kubectl delete --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl delete --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

## 🐛 Troubleshooting

### Common Issues

**Pipeline Fails at Build Step:**
- Check Docker registry credentials
- Verify image namespace/username is correct
- Ensure sufficient cluster resources

**Deployment Fails:**
- Check RBAC permissions
- Verify namespace exists
- Check image pull secrets

**Webhook Not Triggering:**
- Verify EventListener service is accessible
- Check webhook secret configuration
- Review EventListener logs

### Debug Commands

```bash
# Check Tekton installation
kubectl get pods -n tekton-pipelines

# View task logs
kubectl logs -l tekton.dev/task=TASK_NAME -n tekton-pipelines

# Check events
kubectl get events -n tekton-pipelines --sort-by='.lastTimestamp'

# Describe resources for detailed info
kubectl describe pipelinerun PIPELINE_RUN_NAME -n tekton-pipelines
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📚 Additional Resources

- [Tekton Documentation](https://tekton.dev/docs/)
- [Tekton Catalog](https://hub.tekton.dev/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Building! 🚀**