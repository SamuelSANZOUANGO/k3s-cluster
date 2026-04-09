## 👥 Maintainer

* **Samuel Israel SANZOUANGO NOAH** - *Initial Work / DevSecOps/Cloud & PLatform Engineer* - [GitHub Profile](https://github.com/SamuelSANZOUANGO)

## 🛠️ Contribution
Les contributions, retours d'expérience ou suggestions d'amélioration sont les bienvenues ! N'hésitez pas à ouvrir une Issue ou une Pull Request.

---
*Dernière mise à jour : Avril 2026*

# Cluster K3s Lab (Red Hat / Fedora)

Ce dépôt contient l'automatisation pour déployer un cluster Kubernetes léger (1 Master, 2 Workers) spécifiquement configuré pour les distributions de la famille **Red Hat** (RHEL, Fedora, Rocky, Alma).

## 🚀 Composants installés

- **K3s** : Le moteur Kubernetes simplifié.
- **Helm 3** : Gestionnaire de paquets (installé sur le Master).
- **ArgoCD** : Solution GitOps installée dans le namespace `argocd`.

## ⚙️ Détails Importants (RHEL/Fedora)

### Sécurité & Réseau
- **SELinux** : Le script installe les dépendances nécessaires pour que K3s fonctionne avec SELinux actif.
- **Firewalld** : Les flux réseaux entre le Master et les Workers sont autorisés automatiquement via `firewall-cmd`.
- **Ingress** : Traefik est **désactivé** (`--disable traefik`) pour vous permettre d'installer manuellement NGINX ou un autre Ingress Controller.



### Accès à ArgoCD
Le service est configuré en interne. Pour y accéder depuis votre machine :
1. **Port-forward** :
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443