#!/bin/bash
set -e

# 1. Install K3s (lightweight Kubernetes)
if ! command -v k3s >/dev/null 2>&1; then
  curl -sfL https://get.k3s.io | sh -
fi

# 2. Make sure kubeconfig is ready so kubectl can connect
if [ ! -f "$HOME/.kube/config" ]; then
  mkdir -p ~/.kube
  sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
  sudo chown $USER:$USER ~/.kube/config
fi

# 3. Install Helm (package manager for Kubernetes)
if ! command -v helm >/dev/null 2>&1; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# 4. Install kubectl (used to talk to Kubernetes)
if ! command -v kubectl >/dev/null 2>&1; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi

# 5. Add Helm repositories for GitLab and Jetstack
if ! helm repo list | grep -q "gitlab"; then
  helm repo add gitlab https://charts.gitlab.io
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
fi

# 6. Create namespaces for GitLab and GitLab Runner
for ns in gitlab gitlab-runner; do
  if ! kubectl get namespace "$ns" >/dev/null 2>&1; then
    kubectl create namespace "$ns"
  fi
done

# 7. Display next steps
echo ""
echo "✅ Setup complete."
echo "Next steps:"
echo "1. Install GitLab:"
echo "   helm upgrade --install gitlab gitlab/gitlab -n gitlab -f infrastructure/helm-values/gitlab-values-traefik.yaml"
echo ""
echo "2. Install GitLab Runner:"
echo "   helm upgrade --install gitlab-runner gitlab/gitlab-runner -n gitlab-runner -f infrastructure/helm-values/gitlab-runner-values-traefik.yaml"
echo ""
echo "3. Check pods:"
echo "   kubectl get pods -A"
echo ""
