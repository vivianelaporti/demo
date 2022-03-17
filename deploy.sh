#!/bin/bash

cd iac

# Define the SSH key used authenticate in the provisioned servers.
echo "$DIGITALOCEAN_PRIVATE_KEY" > /tmp/.id_rsa

# Define the SSH key permissions.
chmod og-rwx /tmp/.id_rsa

# Define the kubernetes client used to deploy the packages.
export KUBECTL_CMD=`which kubectl`

if [ -z "$KUBECTL_CMD" ]; then
  KUBECTL_CMD=./kubectl
fi

# Define the terraform client used to provision the infrastructure.
export TERRAFORM_CMD=`which terraform`

if [ -z "$TERRAFORM_CMD" ]; then
  TERRAFORM_CMD=./terraform
fi

# Check if the terraform settings environment is created.
if [ ! -d "~/.terraform.d" ]; then
  mkdir -p ~/.terraform.d
fi

# Check if the terraform authentication settings is created.
if [ ! -f "~/.terraform.d/credentials.tfrc.json" ]; then
  # Create the credentials files.
  cp credentials.tfrc.json /tmp

  sed -i -e 's|${TERRAFORM_TOKEN}|'"$TERRAFORM_TOKEN"'|g' /tmp/credentials.tfrc.json

  mv /tmp/credentials.tfrc.json ~/.terraform.d
fi

# Execute the provisioning based on the IaC definition file (terraform.tf).
$TERRAFORM_CMD init
$TERRAFORM_CMD apply -auto-approve \
                     -var "digitalocean_token=$DIGITALOCEAN_TOKEN" \
                     -var "digitalocean_public_key=$DIGITALOCEAN_PUBLIC_KEY" \
                     -var "digitalocean_private_key=$DIGITALOCEAN_PRIVATE_KEY" \
                     -var "datadog_agent_key=$DATADOG_AGENT_KEY"

# Get the IP of the cluster manager used to deploy the application.
export CLUSTER_MANAGER_IP=$($TERRAFORM_CMD output -raw cluster-manager-ip)

# Get and set the kubernetes settings used to orchestrate the deploy the application.
scp -i /tmp/.id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$CLUSTER_MANAGER_IP:/etc/rancher/k3s/k3s.yaml /tmp/.kubeconfig

sed -i -e 's|127.0.0.1|'"$CLUSTER_MANAGER_IP"'|g' /tmp/.kubeconfig

cp ./kubernetes.yml /tmp/kubernetes.yml

# Define the version to be deployed.
BUILD_VERSION=`sed 's/BUILD_VERSION=//g' .env`

sed -i -e 's|${BUILD_VERSION}|'"$BUILD_VERSION"'|g' /tmp/kubernetes.yml

# Deploy the application.
$KUBECTL_CMD --kubeconfig=/tmp/.kubeconfig apply -f /tmp/kubernetes.yml

# Clear temporary files.
rm -f /tmp/kubernetes.yml*
rm -f /tmp/.kubeconfig*
rm -f /tmp/.id_rsa*

cd ..
