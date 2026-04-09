#!/bin/bash
# =================================================================
# Installation K3s Cluster + Helm + ArgoCD
# OS: Ubuntu 24.04 LTS
# Architecture: 1 Master / 2 Workers
# =================================================================

set -e

# ===================== VARIABLES =====================
USER_HOME="/home/vagrant"
USER_NAME="vagrant"
K3S_VERSION="latest"
ARGOCD_VERSION="stable"

# ===================== FONCTIONS =====================

install_dependencies() {
    echo ">>> Installation des dépendances système..."
    apt-get update -qq
    apt-get install -y curl wget git jq bash-completion net-tools
}

setup_k3s_master() {
    echo ">>> Installation du Master K3s..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -s - server \
        --write-kubeconfig-mode 644 \
        --disable traefik \
        --node-name k3s-master

    # Configuration du Kubeconfig pour l'utilisateur
    mkdir -p ${USER_HOME}/.kube
    cp /etc/rancher/k3s/k3s.yaml ${USER_HOME}/.kube/config
    chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME}/.kube
    chmod 600 ${USER_HOME}/.kube/config

    # Sauvegarde du Token et de l'IP pour les Workers
    cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token 2>/dev/null || true
    hostname -I | awk '{print $2}' > /vagrant/master_ip 2>/dev/null || hostname -I | awk '{print $1}' > /vagrant/master_ip
}

setup_k3s_worker() {
    local node_name=$1
    echo ">>> Installation du Worker ${node_name}..."

    if [ ! -f /vagrant/node-token ]; then
        echo "ERREUR : node-token non trouvé dans /vagrant/. Lancez le master d'abord."
        exit 1
    fi

    MASTER_IP=$(cat /vagrant/master_ip)
    TOKEN=$(cat /vagrant/node-token)

    curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="${TOKEN}" sh -s - \
        --node-name "${node_name}"
}

install_helm() {
    echo ">>> Installation de Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

install_argocd() {
    echo ">>> Installation de ArgoCD..."
    kubectl create namespace argocd || true
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml
    
    echo ">>> Attente du déploiement d'ArgoCD (cela peut prendre 1-2 min)..."
}

setup_profile() {
    echo ">>> Configuration du profil (.bashrc)..."
    cat << EOF >> ${USER_HOME}/.bashrc

# Kubernetes Aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgs='kubectl get svc'

# Autocompletion
source <(kubectl completion bash)
complete -F __start_kubectl k
source <(helm completion bash)
EOF
}

# ===================== MAIN EXECUTION =====================

install_dependencies
HOSTNAME=$(hostname)

case "$HOSTNAME" in
    "k3s-master")
        setup_k3s_master
        install_helm
        install_argocd
        setup_profile
        ;;
    "k3s-worker1" | "k3s-worker2")
        setup_k3s_worker "$HOSTNAME"
        setup_profile
        ;;
    *)
        echo "Hostname inconnu. Utilisez k3s-master, k3s-worker1 ou k3s-worker2."
        exit 1
        ;;
esac

echo "✅ Installation terminée sur $HOSTNAME"

if [ "$HOSTNAME" = "k3s-master" ]; then
    echo "---------------------------------------------------"
    echo "Pour récupérer le mot de passe admin ArgoCD :"
    echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
    echo "---------------------------------------------------"
fi