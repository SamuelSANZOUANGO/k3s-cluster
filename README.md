## 👥 Maintainer

* **Samuel Israel SANZOUANGO NOAH** - *Initial Work / DevSecOps/Cloud & PLatform Engineer* - [GitHub Profile](https://github.com/SamuelSANZOUANGO)

## 🛠️ Contribution
Les contributions, retours d'expérience ou suggestions d'amélioration sont les bienvenues ! N'hésitez pas à ouvrir une Issue ou une Pull Request.

---
*Dernière mise à jour : Avril 2026*


# Cluster K3s avec Helm & ArgoCD

Ce projet propose un script d'automatisation pour déployer un cluster Kubernetes léger (K3s) composé d'un **Master** et de **deux Workers**. Il inclut également l'installation des outils de gestion **Helm** et **ArgoCD**.

## 🚀 Fonctionnalités incluses

* **K3s** : Distribution Kubernetes légère, idéale pour le développement et le edge.
* **Helm** : Gestionnaire de paquets pour Kubernetes (installé sur le Master).
* **ArgoCD** : Outil de Continuous Delivery (GitOps) installé dans le namespace `argocd`.
* **Optimisation Réseau** : Détection automatique de l'IP privée pour assurer la communication Master/Workers en environnement virtualisé.

## 🛠️ Détails de la configuration

### ArgoCD
Installé uniquement sur le nœud **Master**. Par défaut, le service n'est pas exposé à l'extérieur du cluster pour des raisons de sécurité.
* **Accès à l'interface :** Utilisez le port-forwarding :
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```
    Accédez ensuite à `https://localhost:8080`.

### Helm
Le binaire Helm est installé sur le **Master** pour vous permettre de déployer vos applications via des Charts Kubernetes.

### Ingress Controller (Traefik)
Traefik a été **désactivé** (`--disable traefik`). Cela vous permet d'installer manuellement l'Ingress Controller de votre choix (ex: NGINX Ingress) dans le cadre de votre apprentissage ou de vos besoins spécifiques.

### Gestion de l'IP
Le script est conçu pour fonctionner en environnement virtualisé (Vagrant/VirtualBox). Il tente de récupérer l'IP privée de l'interface réseau afin que les Workers puissent rejoindre le cluster sans conflit avec l'interface NAT par défaut.

## 📖 Manuel d'utilisation

### 1. Préparation du script
Copiez le code d'installation dans un fichier nommé `install_k8s.sh` sur chaque nœud du cluster.

### 2. Attribution des permissions
Rendez le script exécutable avec la commande suivante :
```bash
chmod +x install_k8s.sh

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo