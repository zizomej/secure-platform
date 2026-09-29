
---

## 7. Déploiement

**Prérequis :** un cluster Kubernetes 3 nœuds (kubeadm v1.31), Calico, Multus, Helm.

```bash
# 1. Cloner le depot
git clone https://github.com/<votre-compte>/voip-project.git
cd voip-project

# 2. Appliquer les NetworkPolicies Zero-Trust et les manifestes
kubectl apply -f k8s/

# 3. Deployer la plateforme VoIP (Helm)
helm install voip-platform ./voip-platform -n voip --create-namespace

# 4. Deployer l'observabilite
helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace -f monitoring-values.yaml

# 5. Deployer Jitsi Meet
helm install jitsi jitsi/jitsi-meet -n jitsi --create-namespace -f jitsi-values.yaml
```

> Grâce à l'approche **Infrastructure as Code**, toute la plateforme est reproductible : à partir de ce dépôt, elle peut être redéployée à l'identique sur n'importe quel cluster.

### Interfaces (NodePort)

| Service | URL | Port |
|---------|-----|------|
| Homer (analyse SIP) | http://<node-ip>:30090 | 30090 |
| Grafana (supervision) | http://<node-ip>:30080 | 30080 |
| Prometheus | http://<node-ip>:30099 | 30099 |
| Jitsi Meet | http://<node-ip>:30000 | 30000 |

---

## 8. Tests de charge (SIPp)

```bash
# Genere 100 requetes SIP/seconde vers Kamailio pendant 60 s
sipp -sf sipp-load.xml <worker2-ip>:5070 -r 100 -trace_screen -screen_file /tmp/demo.log
```

Résultat obtenu : **Peak 214 appels simultanés**, **0/0/0 UDP errors**, ~6000 requêtes relayées par Kamailio.

---

## 9. Perspectives

- Certificat TLS pour Jitsi via Cert-Manager (accès WebRTC complet)
- Mesure du **MOS** (qualité audio perçue)
- Load-balancer SIP en frontal
- Chiffrement média **SRTP**
- Cluster **multi-zones** (haute disponibilité géographique)

---

**Registre Docker Hub :** azizdocker2026/ · **Auteur :** Aziz Mejri (@zizomej) · **ESPRIT 2025/2026**
READMEEOF
echo "README remplace (sans semaines)"
