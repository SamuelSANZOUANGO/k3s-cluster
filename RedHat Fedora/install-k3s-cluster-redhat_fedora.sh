#!/bin/bash
# =================================================================
# Installation K3s Cluster + Helm + ArgoCD
# OS: RHEL / Fedora / CentOS Stream / AlmaLinux
# Architecture: 1 Master / 2 Workers
# =================================================================

set -e

# ===================== VARIABLES =====================
USER_NAME="vagrant"  # Modifier si vous utilisez un autre utilisateur
USER_HOME="/home/${USER_NAME}"
K3S_VERSION="latest"
ARGOCD_VERSION="stable"

# ===================== FONCTIONS =====================

install_dependencies() {
    echo ">>> Installation des dépendances système via DNF..."
    dnf install -y curl wget git jq bash-completion net-tools
    
    # Gestion du Firewall (Actif par défaut sur Red Hat/Fedora)
    if systemctl is-active --quiet firewalld; then
        echo ">>> Ouverture des ports dans Firewalld..."
        firewall-cmd --permanent --add-port=6443/tcp   # API Server
        firewall-cmd --permanent --add-port=10250/tcp  # Kubelet
        firewall-cmd --permanent --add-port=8472/udp   # Flannel VXLAN
        firewall-cmd --permanent --add-port=2379-2380/tcp # etcd (si besoin)
        firewall-cmd --permanent --add-port=80/tcp     # HTTP
        firewall-cmd --permanent --add-port=443/tcp    # HTTPS
        firewall-cmd --reload
    fi

    # SELinux : K3s nécessite des politiques spécifiques sur Red Hat
    echo ">>> Installation des politiques SELinux pour K3s..."
    dnf install -y container-selinux selinux-policy-base
    # K3s installera son propre module k3s-selinux lors du curl
}

setup_k3s_master() {
    echo ">>> Installation du Master K3s..."
    # --write-kubeconfig-mode 644 permet l'accès sans sudo
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${K3S_VERSION} sh -s - server \
        --write-kubeconfig-mode 644 \
        --disable traefik \
        --node-name k3s-master

    # Configuration du Kubeconfig pour l'utilisateur
    mkdir -p ${USER_HOME}/.kube
    cp /etc/rancher/k3s/k3s.yaml ${USER_HOME}/.kube/config
    chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME}/.kube
    chmod 600 ${USER_HOME}/.kube/config

    # Sauvegarde du Token et de l'IP (via /vagrant pour le lab)
    cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token 2>/dev/null || true
    # On évite l'IP 10.0.2.15 (NAT Vagrant) pour prendre l'IP du Host-Only
    MASTER_IP=$(hostname -I | awk '{for(i=1;i<=NF;i++) if($i != "10.0.2.15") print $i; exit}')
    echo "$MASTER_IP" > /vagrant/master_ip
}

setup_k3s_worker() {
    local node_name=$1
    echo ">>> Installation du Worker ${node_name}..."

    if [ ! -f /vagrant/node-token ] || [ ! -f /vagrant/master_ip ]; then
        echo "ERREUR : node-token ou master_ip absent dans /vagrant/. Lancez le master d'abord."
        exit 1
    fi

    MASTER_IP=$(cat /vagrant/master_ip)
    TOKEN=$(cat /vagrant/node-token)

    curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="${TOKEN}" sh -s - \
        --node-name "${node_name}"
}

install_tools_master() {
    echo ">>> Installation de Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    echo ">>> Déploiement d'ArgoCD..."
    kubectl create namespace argocd || true
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml
}

setup_profile() {
    echo ">>> Configuration des alias système..."
    cat << EOF > /etc/profile.d/k3s_aliases.sh
alias k='kubectl'
alias kgp='kubectl get pods -o wide'
alias kgn='kubectl get nodes'
alias kgs='kubectl get svc'
source <(kubectl completion bash)
complete -F __start_kubectl k
EOF
    chmod +x /etc/profile.d/k3s_aliases.sh
}

# ===================== MAIN =====================

install_dependencies
HOSTNAME=$(hostname)

case "$HOSTNAME" in
    "k3s-master")
        setup_k3s_master
        install_tools_master
        setup_profile
        ;;
    "k3s-worker1" | "k3s-worker2")
        setup_k3s_worker "$HOSTNAME"
        setup_profile
        ;;
    *)
        echo "Hostname inconnu : $HOSTNAME. Utilisez k3s-master, k3s-worker1 ou k3s-worker2."
        exit 1
        ;;
esac

echo "✅ Installation K3s/Helm/ArgoCD terminée sur $HOSTNAME !"