## bootstrapping is the process of creating a new kubernetes cluster from scratch and getting it up and running.
## create kube-bootstrap will first make sure eks-dev cluster and node group are created,
## then update-kubeconfig to eks-dev cluster to be able to connect to the cluster, then create a NameSpace devops

resource "null_resource" "kube-bootstrap" {
  depends_on = [aws_eks_cluster.main, aws_eks_node_group.main]
  provisioner "local-exec" {
    command =<<EOF
aws eks update-kubeconfig  --name ${var.env}-eks
kubectl create ns devops
EOF
  }
}
## install nginx-ingress chart from the open container initiative  repository (OCI) oci://ghcr.io/nginxinc/charts/nginx-ingress
## in the devops namespace, use the value file from path /helm-config/nginx-ingress.yml
##
##
resource "helm_release" "nginx-ingress" {
  depends_on = [null_resource.kube-bootstrap]
  chart = "oci://ghcr.io/nginxinc/charts/nginx-ingress"
  name  = "nginx-ingress"
  namespace = "devops"
  wait       = true

  values = [
    file("${path.module}/helm-config/nginx-ingress.yml")
  ]
}

## External DNS
## install helm chart External-DNS form the repo at https://kubernetes-sigs.github.io/external-dns
## in the namespace devops
resource "helm_release" "external-dns" {
  depends_on = [null_resource.kube-bootstrap, helm_release.nginx-ingress]

  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  chart            = "external-dns"
  namespace        = "devops"
  create_namespace = true
  wait             = false
}

## ArgoCD Setup
## install argocd chart from repo https://argoproj.github.io/argo-helm
## in the namespace argocd (create namespace), provide some values in set command option,
## use the value file at the path /helm-config/argocd.yml

resource "helm_release" "argocd" {
  depends_on = [null_resource.kube-bootstrap, helm_release.external-dns ]

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  wait             = false

  set {
    name  = "global.domain"
    value = "argocd-${var.env}.hptldevops.online"
  }

  values = [
    file("${path.module}/helm-config/argocd.yml")
  ]
}

##Prometheus Stack Setup

##

## External Secrets
## Install helm chart "external-secrets" from repo https://charts.external-secrets.io
## in the namespace devops
## connect to connect to external secret using provisioner using token provided,
## create ClusterSecretStore named: vault-backend
resource "helm_release" "external-secrets" {
  depends_on = [null_resource.kube-bootstrap]

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "devops"
  create_namespace = true
  wait             = true
}

resource "null_resource" "external-secret" {
  depends_on = [helm_release.external-secrets]

  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f - <<EOK
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
data:
  token: aHZzLm85R1NRbnpXNFNMTmhZSWE4aVllWlNuVQ==
---
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault-internal.hptldevops.online:8200"
      path: "roboshop-${var.env}"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
EOK
EOF
  }
}