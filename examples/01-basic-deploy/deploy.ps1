### This script deploys the Azure DevOps agent to the Kubernetes cluster
# under the `devops` namespace and
# values from the `values.yaml` file in the same directory
# with helm release name `azdo-agent`

### PLEASE UPDATE THE VALUES.YAML FILE WITH YOUR OWN VALUES ###

# Add the Helm repository and update it
helm repo add btungut https://btungut.github.io
helm repo update btungut


# Get the directory of the script
$DEPLOY_DIR = Split-Path -Parent $MyInvocation.MyCommand.Definition


# Deploy the agent by using the Helm chart
helm upgrade -i azdo-agent btungut/azure-devops-agent `
    --namespace devops `
    --create-namespace `
    --values "$DEPLOY_DIR/values.yaml"
