resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.env}-wumbo-redis"
  apply_immediately    = true
  engine               = "redis"
  node_type            = var.redis_instance_type
  num_cache_nodes      = var.num_redis_nodes
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  security_group_ids = [data.aws_security_group.default.id]
  subnet_group_name = aws_elasticache_subnet_group.subnet_group.name
}

resource "aws_elasticache_subnet_group" "subnet_group" {
  name       = "${var.env}-wumbo-redis-subnet-group"
  subnet_ids = module.vpc.public_subnets
}