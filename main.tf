module "db_instances" {
  for_each       = var.db_instances
  source         = "./modules/ec2"
  env            = var.env
  app_port       = each.value["app_port"]
  component_name = each.key
  instance_type  = each.value["instance_type"]
  domain_name    = var.domain_name
  zone_id        = var.zone_id
}

module "app_instances" {
  depends_on     = [module.db_instances]
  for_each       = var.app_instances
  source         = "./modules/ec2"
  env            = var.env
  app_port       = each.value["app_port"]
  component_name = each.key
  instance_type  = each.value["instance_type"]
  domain_name    = var.domain_name
  zone_id        = var.zone_id
}

module "web_instances" {
  depends_on     = [module.app_instances]
  for_each       = var.web_instances
  source         = "./modules/ec2"
  env            = var.env
  app_port       = each.value["app_port"]
  component_name = each.key
  instance_type  = each.value["instance_type"]
  domain_name    = var.domain_name
  zone_id        = var.zone_id
}