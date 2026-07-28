# Secure Cloud-Native UC & VoIP Platform

Infrastructure de téléphonie IP et de collaboration unifiée (UC/VoIP) cloud-native, hautement disponible et sécurisée, déployée sous forme de micro-services sur Kubernetes. Projet DevSecOps 100% open-source, on-premises / cloud privé.

## Architecture

| Module | Composant | Rôle |
|---|---|---|
| Orchestration & Réseau | Kubernetes + Multus + Calico | Cluster, réseau, isolation Zero-Trust |
| Control Plane | Asterisk 20 + PostgreSQL 16 répliqué | Appels, état des sessions |
| Edge & SBC | Kamailio (SIP Ingress) | Masquage topologie, filtrage, TLS |
| UC & Collaboration | Jitsi Meet | Visioconférence WebRTC |
| Sécurité | Cert-Manager, NetworkPolicies, Trivy | TLS auto, isolation, scan continu |

Flux : Softphones -> Kamailio (SBC, TLS) -> Asterisk (PBX) -> PostgreSQL

## Stack technique

- Orchestration : Kubernetes (kubeadm v1.31), Multus CNI, Calico
- Conteneurs : Docker, images sur Docker Hub (azizdocker2026/)
- Packaging : Helm (chart voip-platform)
- Services : Asterisk 20, PostgreSQL 16 (réplication), Kamailio 5.8 (SBC)
- Collaboration : Jitsi Meet (WebRTC)
- Sécurité : Cert-Manager (TLS), NetworkPolicies (Zero-Trust), HPA
- CI/CD : GitHub Actions, Trivy, kube-linter, Checkov

## Avancement (6 semaines)

- [x] Semaine 1 - Cluster K8s, Multus CNI, NetworkPolicies Zero-Trust
- [x] Semaine 2 - Dockerfiles, Trivy CI/CD, packaging Helm
- [x] Semaine 3 - SBC Kamailio, Cert-Manager (TLS), durcissement YAML
- [x] Semaine 4 - Stack Jitsi/WebRTC + auto-scaling HPA
- [ ] Semaine 5 - Monitoring (Homer/Prometheus), Trivy Operator
- [ ] Semaine 6 - Tests de charge (SIPp), rapport de conformité, Runbooks

## Sécurité

- Zero-Trust : default-deny-all + règles explicites par composant
- Chiffrement : SIP over TLS (5061), certificats auto via Cert-Manager
- CI/CD : blocage déploiement si CVE critique (Trivy)
- Durcissement : seccomp, allowPrivilegeEscalation false, probes

## Documentation

La documentation détaillée (journaux, matrices de tests, analyses) est dans le dossier docs/.

---
Registre Docker Hub : azizdocker2026/ · Auteur : Aziz Mejri (@zizomej)
