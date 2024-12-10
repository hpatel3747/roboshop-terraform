env         = "dev"
domain_name = "hptldevops.online"
zone_id     = "Z034492616CL1VL5T8KC8"

db_instances = {
  mongodb = {
    app_port      = 27017
    instance_type = "t3.small"
    volume_size   = "20"
  }

  redis = {
    app_port      = 6379
    instance_type = "t3.small"
    volume_size   = "20"
  }

  rabbitmq = {
    app_port      = 5672
    instance_type = "t3.small"
    volume_size   = "20"
  }

  mysql = {
    app_port      = 3306
    instance_type = "t3.small"
    volume_size   = "20"
  }
}

app_instances = {

  catalogue = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = "30"
  }

  cart = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = "30"
  }

  user = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = "30"
  }

  shipping = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = "30"
  }

  payment = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = "30"
  }

}

web_instances = {
  frontend = {
    app_port      = 80
    instance_type = "t3.small"
    volume_size   = "20"
  }
}

eks = {
  subnet_ids = ["subnet-03267e70b0f121080", "subnet-0aee3b0522317971a"]
  addons = {
    vpc-cni = {}
    kube-proxy = {}
  }
#verify your subnet ids (this id are from Raghu's code)

  access_entries = {
  workstation = {
    principal_arn     = "arn:aws:iam::585768147521:role/WorkstationRole"
    kubernetes_groups = []
    policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
    access_scope_type = "cluster"
    access_scope_namespaces = []
  }
    # UI Access
    ui-access = {
      principal_arn = "arn:aws:iam::585768147521:root"
      kubernetes_groups = []
      policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      access_scope_type = "cluster"
      access_scope_namespaces = []
    }
  }

  node_groups = {
    g1 = {
      desired_size = 1
      max_size     = 2
      min_size     = 1
      capacity_type = "SPOT"
      instance_types = ["t3.large"]
    }
  }
}
