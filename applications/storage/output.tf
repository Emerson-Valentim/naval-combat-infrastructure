output "main-ecr" {
  value = aws_ecr_repository.main_ecr_storage
}

output "redis" {
  value = {
    socket = aws_elasticache_replication_group.socket-redis
  }
}

output "mongodb" {
  value = {
    host     = mongodbatlas_cluster.main.connection_strings[0].standard_srv
    username = var.username
    password = var.password
  }
}

output "s3" {
  value = {
    skin  = local.s3_skin
    react = module.s3_react
  }
}