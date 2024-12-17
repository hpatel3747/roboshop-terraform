## create kube-bootstrap will first make sure eks-dev clsuter and node group are created,
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

## install nginx-ingress chart from the open container initiative  repository oci://ghcr.io/nginxinc/charts/nginx-ingress
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
## install helm chart External-DNS form the repo at https://kubernetes-sigs.githun.io/external-dns
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
