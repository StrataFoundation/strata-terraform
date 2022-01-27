
// Legacy... Can't delete it without the dploy failing. Want to keep that data though.
resource "aws_s3_bucket" "blocks_bucket" {
  bucket = "${var.env}-wumbo-solana-blocks"
}

resource "aws_s3_bucket" "strata_blocks_bucket" {
  bucket = "${var.env}-strata-solana-blocks"
}

resource "aws_iam_user_policy" "block_rw" {
  name = "${var.env}-strata-solana-blocks-rw"
  user = aws_iam_user.block_rw.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.strata_blocks_bucket.arn]
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:HeadObject", "s3:GetObject"],
        Resource = ["${aws_s3_bucket.strata_blocks_bucket.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_user" "block_rw" {
  name = "${var.env}-strata-solana-blocks-rw"
  path = "/etl/"
}

resource "aws_iam_access_key" "block_rw" {
  user = aws_iam_user.block_rw.name
}

resource "aws_iam_user_policy" "block_ro" {
  name = "${var.env}-strata-solana-blocks-rw"
  user = aws_iam_user.block_ro.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.strata_blocks_bucket.arn]
      }, {
        Effect = "Allow"
        Action = ["s3:GetObject","s3:GetObjectVersion"],
        Resource = ["${aws_s3_bucket.strata_blocks_bucket.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_user" "block_ro" {
  name = "${var.env}-strata-solana-blocks-ro"
  path = "/etl/"
}

resource "aws_iam_access_key" "block_ro" {
  user = aws_iam_user.block_ro.name
}

locals {
  accounts = {
        "token" = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
        "atoken" = "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL",
        "name" = "namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX",
        "token-metadata" = "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s",
        "bonding" = var.token_bonding_program_id,
        "collective" = var.token_collective_program_id
  }
}

module "signature_identifiers" {
  for_each = local.accounts
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/kafka-signature-identifier.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-${each.key}-signature-identifier"
  cpu = 100
  memory = 300
  desired_count = 0
  environment = [
    {
      name = "START_SIGNATURE",
      value = "5qmi8Y2CfvVT1MGe6xQ37KeCTZajLnYJFQdqvqHGQa7ZF6bJqUDhVf8k9CMjgHMYeBSFxNw9mWpaa6CTcNA4sT14"
    },
    {
      name = "SOLANA_URL"
      value = var.solana_url
    }, {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_TOPIC"
      value = "json.solana.signatures.${each.key}"
    }, {
      name = "NUM_PARTITIONS",
      value = "1"
    }, {
      name = "ADDRESS",
      value = each.value
    }
  ]
}

module "signature_collector" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/kafka-signature-collector.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-signature-collector"
  cpu = 100
  memory = 300
  desired_count = 1
  environment = [
    {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_TOPIC"
      value = "json.solana.signatures"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.signatures..*"
    }, {
      name = "NUM_PARTITIONS",
      value = var.signature_processor_num_partitions
    }, {
      name = "KAFKA_OFFSET_RESET",
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID",
      value = "kafka-signature-collector"
    }
  ]
}

module "signature_processor" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/kafka-signature-processor.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-signature-processor"
  cpu = var.signature_processor_cpu
  memory = var.signature_processor_memory
  desired_count = var.signature_processor_count
  environment = [
    {
      name = "MAX_BYTES",
      value = 200
    },
    {
      name = "SOLANA_URL",
      value = var.solana_url
    },
    {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_TOPIC"
      value = "json.solana.transactions"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.signatures"
    }, {
      name = "NUM_PARTITIONS",
      value = "1"
    }, {
      name = "KAFKA_OFFSET_RESET",
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID",
      value = "kafka-signature-processor"
    },  {
      name = "GROUP_SIZE",
      value = var.signature_processor_concurrent_fetch
    }, {
      name = "AUTO_COMMIT_THRESHOLD",
      value = var.signature_processor_commit_threshold
    }
  ]
}

module "event_transformer" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/event-transformer/index.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-event-transformer"
  cpu = 350
  memory = 512
  desired_count = var.num_event_transformers 
  environment = [
    {
      name = "SOLANA_URL",
      value = var.solana_url
    }, {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.transactions"
    }, {
      name = "KAFKA_OUTPUT_TOPIC"
      value = "json.solana.events"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "solana-event-transformer"
    }, {
      name = "ANCHOR_IDLS"
      value = join(",", [
        var.token_bonding_program_id,
        var.token_collective_program_id
      ])
    }
  ]
}

module "account_leaderboard" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/leaderboard/index.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-account-leaderboard"
  cpu = 350
  memory = 512
  desired_count = 1  
  environment = [
    {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.latest_bonding_token_account_balances"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "account-leaderboard-1"
    }, {
      name = "REDIS_HOST"
      value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}"
    }, {
      name = "REDIS_PORT"
      value = "6379"
    }
  ]
}

module "top_tokens_leaderboard" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/leaderboard/index.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-top-tokens-leaderboard-1"
  cpu = 200
  memory = 512
  desired_count = 1  
  environment = [
    {
      name = "PLUGIN"
      value = "TOP_TOKENS"
    },
    {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.latest_reserve_token_account_balances"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "top-token-leaderboard-1"
    }, {
      name = "REDIS_HOST"
      value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}"
    }, {
      name = "REDIS_PORT"
      value = "6379"
    }
  ]
}

module "trophies" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/trophies/index.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-trophies"
  cpu = 256
  memory = 512
  desired_count = 1  
  environment = [
    {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.trophies"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "trophies"
    }, {
      name = "SERVICE_ACCOUNT"
      value = var.trophy_service_account
    }, {
      name = "SOLANA_URL"
      value = var.solana_url
    }
  ]
}
