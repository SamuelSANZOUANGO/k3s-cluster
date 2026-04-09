## 👥 Maintainer

* **Samuel Israel SANZOUANGO NOAH** - *Initial Work / DevSecOps/Cloud & PLatform Engineer* - [GitHub Profile](https://github.com/SamuelSANZOUANGO)

## 🛠️ Contribution
Les contributions, retours d'expérience ou suggestions d'amélioration sont les bienvenues ! N'hésitez pas à ouvrir une Issue ou une Pull Request.

---
*Dernière mise à jour : Avril 2026*

# Cluster K3s Lab (Rocky/CentOS) - Helm & ArgoCD

Ce dépôt contient l'automatisation pour déployer un cluster Kubernetes léger (1 Master, 2 Workers) sur des distributions de la famille RHEL (Rocky Linux 9, CentOS Stream, AlmaLinux).

## 🚀 Composants installés

- **K3s** : Control plane ultra-léger.
- **Helm 3** : Pour la gestion des packages Kubernetes.
- **ArgoCD** : Pour la gestion du cluster en mode GitOps (déployé dans le namespace `argocd`).

## 🛠️ Détails techniques

- **Pare-feu (Firewalld)** : Les ports nécessaires (6443, 10250, 8472) sont automatiquement ouverts par le script.
- **Ingress** : Traefik est **désactivé** par défaut pour permettre l'apprentissage de l'installation manuelle d'Ingress-Nginx.
- **ArgoCD Access** : Le service est en type `ClusterIP`. Pour y accéder depuis votre hôte :
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443