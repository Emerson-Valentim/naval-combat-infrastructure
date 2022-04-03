locals {
  default_env_vars = {
    NODE_ENV        = var.env
    MONGODB_ADDRESS = var.mongodb.host
  }

  notification_env_vars = {
    REDIS_HOST = var.redis.socket.primary_endpoint_address
    REDIS_PORT = 6379
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.service}-${var.env}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Environment = "${var.env}"
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE",
  "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

module "api" {
  source = "../../modules/api"

  env        = var.env
  region     = var.region
  service    = var.service
  subnet_ids = var.network.main-vpc.private_subnets
  gateway    = var.gateway

  security_groups = [var.network.main-api-sg.id]

  env_vars = merge(local.default_env_vars)
}

module "notification" {
  source = "../../modules/notification"

  env               = var.env
  region            = var.region
  service           = var.service
  subnet_ids        = var.network.main-vpc.private_subnets
  public_subnet_ids = var.network.main-vpc.public_subnets
  vpc_id            = var.network.main-vpc.vpc_id
  dns               = var.dns

  security_groups = [var.network.main-notification-sg.id]

  cluster = aws_ecs_cluster.cluster

  env_vars = merge(local.default_env_vars, local.notification_env_vars)

  ecr_url = var.ecr.repository_url
}