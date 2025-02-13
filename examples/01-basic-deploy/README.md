# 01-basic-deploy

It is the most basic example to deploy **Azure DevOps Agent on Kubernetes** on your Kubernetes clusters. It uses the default values for the configuration. Please visit and edit the `values.yaml` file to customize the configuration. Then you can deploy the agent by calling; 

- `deploy.ps1` if you are using Windows or,
- `deploy.sh` if you are using Linux or macOS.

Example `values.yaml` content:
```yaml
fullnameOverride: azdo-agent

agent:
  # Required! e.g.: https://dev.azure.com/myorg
  organizationUrl: "https://dev.azure.com/btungut-demos"

  # Required! e.g.: your-pool-name
  pool: "kube-pool"

  # Required! e.g.: your-pat (which is a Personal Access Token with Agent Pools (read, manage) scope)
  pat: "ANOqc7..............................SAZDO4PRh"
```

For windows:
```powershell
.\01-basic-deploy\deploy.ps1
```

For Linux or macOS:
```bash
bash ./01-basic-deploy/deploy.sh
```
