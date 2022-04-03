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
    host = mongodbatlas_cluster.cluster-test.connection_strings[0].standard
  }
}