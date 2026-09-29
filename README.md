cat > /home/azizmejri/voip-project/README.md << 'READMEEOF'
# Plateforme UC & VoIP Cloud-Native Sécurisée

> Infrastructure de téléphonie sur IP (VoIP) et de communications unifiées (UC), **cloud-native**, **hautement disponible** et **sécurisée par conception (DevSecOps)**, déployée sous forme de micro-services conteneurisés sur **Kubernetes**. Projet 100 % open-source, exécutable on-premises ou sur cloud privé.

**Auteur :** Mohamed Aziz Mejri · **Encadrant :** M. Issam Ben Lakhdhar · **ESPRIT** — 2025/2026

---

## 1. Contexte et objectifs

La téléphonie d'entreprise migre des autocommutateurs matériels (PABX), coûteux et rigides, vers la **VoIP logicielle**. En parallèle, le **cloud-native** (conteneurs, orchestration, auto-scaling) impose ses standards. Ce projet fait converger les deux : **faire fonctionner une téléphonie temps réel dans un environnement Kubernetes**, malgré les contraintes propres au SIP (latence, ports dynamiques, accès réseau direct).

### KPIs cibles (cahier des charges) — tous validés

| # | Objectif | Cible | Résultat mesuré |
|---|----------|-------|-----------------|
| 1 | **Disponibilité** (self-healing) | recréation auto | pod recréé en **~5 s** |
| 2 | **Sécurité conteneurs** | 0 CVE critique en prod | **0 CVE critique** (Trivy) |
| 3 | **Sécurité réseau** (Zero-Trust) | 0 flux non autorisé | accès illégitime **bloqué**, DNS OK |
| 4 | **Performance** (montée en charge) | 100+ appels simultanés | **214 appels simultanés**, 0 erreur UDP |

---

## 2. Architecture

Cluster Kubernetes de **3 nœuds** (1 control-plane + 2 workers), composants isolés en **namespaces** dédiés.

| Nœud | Rôle | Composants hébergés |
|------|------|---------------------|
| **master** | Control-plane | API Server, etcd, scheduler, controller-manager |
| **worker1** | Nœud de calcul | Asterisk (PBX), Jitsi Meet |
| **worker2** | Nœud de calcul | Kamailio (SBC), PostgreSQL |

| Module | Composant | Rôle |
|--------|-----------|------|
| Orchestration & Réseau | Kubernetes + Calico + Multus CNI | Cluster, réseau overlay, isolation Zero-Trust |
| Control Plane VoIP | Asterisk 20 + PostgreSQL 16 (réplication) | Établissement des appels, état des sessions |
| Edge & SBC | Kamailio 5.8 (SIP Ingress) | Masquage de topologie, filtrage, routage, TLS |
| UC & Collaboration | Jitsi Meet (web, prosody, jicofo, jvb) | Visioconférence WebRTC |
| Observabilité | Homer (HEP) + Prometheus + Grafana | Analyse SIP, supervision temps réel |
| Sécurité | Cert-Manager, NetworkPolicies, Trivy | TLS automatique, micro-segmentation, scan continu |

**Flux d'appel :** Softphone -> Kamailio (SBC, 5070) -> Asterisk (PBX, 5060) -> PostgreSQL

### Réseau : la double interface (point clé)

Le SIP exige un **accès réseau direct**, incompatible avec le réseau overlay de Kubernetes. Solution retenue : **deux interfaces réseau par pod** via Multus CNI.

- **eth0 (Calico, overlay)** — réseau interne du cluster, **soumis aux NetworkPolicies** (Zero-Trust). Trafic de contrôle.
- **net1 (Multus, macvlan physique)** — interface sur le réseau physique, dédiée au **trafic SIP direct**, hors NetworkPolicies.

> **Conséquence :** le durcissement Zero-Trust peut être appliqué au maximum **sans jamais interrompre les appels**, puisque le média SIP transite par Multus.

---

## 3. Stack technique détaillée

| Domaine | Technologies |
|---------|-------------|
| Orchestration | Kubernetes (kubeadm **v1.31**), Calico (IPIP), Multus CNI |
| Conteneurs | Docker · images publiées sur Docker Hub (azizdocker2026/) |
| Packaging | Helm (chart voip-platform) |
| Téléphonie | Asterisk 20 (PBX) · Kamailio 5.8 (SBC) · protocoles SIP / RTP / TLS |
| Base de données | PostgreSQL 16 en réplication (primary / replica) |
| Collaboration | Jitsi Meet (WebRTC) — prosody (XMPP), jicofo (focus), jvb (bridge) |
| Observabilité | Homer + heplify (capture HEP) · Prometheus · Grafana |
| Sécurité | Cert-Manager (TLS) · 8 NetworkPolicies (Zero-Trust) · HPA (auto-scaling) |
| CI/CD | GitHub Actions · Trivy · kube-linter · Checkov |
| Tests de charge | SIPp |

---

## 4. Réalisation (briques techniques)

**Fondations du cluster.** Cluster Kubernetes 3 nœuds via kubeadm (v1.31), réseau overlay Calico, double interface via Multus CNI (macvlan pour le SIP direct), premières NetworkPolicies Zero-Trust (default-deny-all).

**Conteneurisation & CI/CD.** Dockerfiles Asterisk et PostgreSQL (images légères, probes, limites, seccomp), images publiées sur Docker Hub. Pipeline GitHub Actions : build -> scan Trivy (CVE) -> lint (kube-linter, Checkov), avec blocage si CVE critique. Packaging Helm réutilisable.

**SBC Kamailio & TLS.** Déploiement de Kamailio en frontal (SIP Ingress), routage SIP vers Asterisk via le service DNS interne (asterisk.voip.svc.cluster.local), comptes SIP (1001, 1002), certificats TLS automatiques via Cert-Manager.

**Collaboration & auto-scaling.** Déploiement de Jitsi Meet (web, prosody, jicofo, jvb) dans un namespace isolé, Horizontal Pod Autoscaler (HPA) sur Asterisk (montée automatique selon la charge CPU).

**Observabilité.** Homer + sidecar heplify (capture SIP au format HEP, stockage PostgreSQL), Prometheus (métriques) et Grafana (tableaux de bord CPU/mémoire/disque par nœud), Trivy Operator (audit runtime continu).

**Tests de charge & validation.** SIPp (100 appels/seconde soutenus), mesure de la tenue serveur (relais Kamailio, 0 erreur UDP), validation des 4 KPIs, documentation et runbooks (docs/).

---

## 5. Sécurité — défense en profondeur

Quatre couches complémentaires, du code jusqu'au réseau :

1. **CI/CD (shift-left)** — Trivy scanne chaque image ; tout build avec une CVE critique est bloqué avant déploiement.
2. **Runtime** — Trivy Operator audite en continu les conteneurs en fonctionnement (VulnerabilityReports).
3. **Réseau (Zero-Trust)** — default-deny-all + 8 NetworkPolicies explicites. Micro-segmentation prouvée par un test d'intrusion (accès PostgreSQL bloqué, DNS autorisé fonctionnel).
4. **Transport (TLS)** — signalisation SIP chiffrée (SIP over TLS, port 5061), certificats auto via Cert-Manager.

Durcissement des pods : seccomp, allowPrivilegeEscalation false, health/readiness probes, limites de ressources.

---

## 6. Structure du dépôt
