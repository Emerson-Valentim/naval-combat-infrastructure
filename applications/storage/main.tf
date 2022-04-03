terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "1.2.0"
    }
  }
}

provider "mongodbatlas" {
  public_key  = ""
  private_key = ""
}

resource "aws_ecr_repository" "main_ecr_storage" {
  name                 = "main-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "expire_policy" {
  repository = aws_ecr_repository.main_ecr_storage.name

  policy = file("${path.module}/ecr-expire-policy.json")
}

resource "aws_elasticache_replication_group" "socket-redis" {
  description                = "redis for socket"
  replication_group_id       = "socket-${var.env}"
  automatic_failover_enabled = false
  engine                     = "redis"
  node_type                  = "cache.t2.micro"
  num_cache_clusters         = 1
  port                       = 6379
  subnet_group_name          = var.subnets
  security_group_ids         = var.redis-sg.socket
  apply_immediately          = true
}

resource "mongodbatlas_project" "test" {
  name             = "main-${var.env}"
  org_id           = "6071c090caec8b594be61bc4"
}

resource "mongodbatlas_cluster" "cluster-test" {
  project_id = "1"
  name       = "main-${var.env}"

  # Provider Settings "block"
  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_region_name        = "US_EAST_1"
  provider_instance_size_name = "M0"
}
