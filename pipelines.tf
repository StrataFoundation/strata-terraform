resource "aws_s3_bucket" "blocks_bucket" {
  bucket = "${var.env}-wumbo-solana-blocks"
}

resource "aws_iam_user_policy" "block_rw" {
  name = "${var.env}-wumbo-solana-blocks-rw"
  user = aws_iam_user.block_rw.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.blocks_bucket.arn]
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:HeadObject", "s3:GetObject"],
        Resource = ["${aws_s3_bucket.blocks_bucket.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_user" "block_rw" {
  name = "${var.env}-wumbo-solana-blocks-rw"
  path = "/etl/"
}

resource "aws_iam_access_key" "block_rw" {
  user = aws_iam_user.block_rw.name
}

resource "aws_iam_user_policy" "block_ro" {
  name = "${var.env}-wumbo-solana-blocks-rw"
  user = aws_iam_user.block_ro.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.blocks_bucket.arn]
      }, {
        Effect = "Allow"
        Action = ["s3:GetObject","s3:GetObjectVersion"],
        Resource = ["${aws_s3_bucket.blocks_bucket.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_user" "block_ro" {
  name = "${var.env}-wumbo-solana-blocks-ro"
  path = "/etl/"
}

resource "aws_iam_access_key" "block_ro" {
  user = aws_iam_user.block_ro.name
}

module "block_uploader" {
  source = "./modules/data_pipeline"
  region = var.aws_region
  command = "dist/lib/kafka-s3-block-uploader.js"
  cluster = aws_ecs_cluster.wumbo.id
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  name = "${var.env}-block-retriever"
  cpu = 350
  memory = 512
  desired_count = 1  
  environment = [
    {
      name = "S3_ACCESS_KEY_ID"
      value = aws_iam_access_key.block_rw.id
    },
    { 
      name = "S3_SECRET_ACCESS_KEY"
      value = aws_iam_access_key.block_rw.secret
    }, {
      name = "SOLANA_URL"
      value = var.solana_url
    }, {
      name = "S3_BUCKET"
      value = aws_s3_bucket.blocks_bucket.id
    }, {
      name = "S3_PREFIX"
      value = var.s3_block_prefix
    }, {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_TOPIC"
      value = "json.solana.blocks"
    }, {
      name = "ACCOUNTS"
      value = join(",", [
        "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
        var.token_bonding_program_id,
        var.wumbo_program_id
      ])
    }
  ]
}

module "event_transformer" {
  source = "./modules/data_pipeline"
  region = var.aws_region
  command = "dist/lib/event-transformer/index.js"
  cluster = aws_ecs_cluster.wumbo.id
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  name = "${var.env}-event-transformer"
  cpu = 350
  memory = 512
  desired_count = 1  
  environment = [
    {
      name = "S3_ACCESS_KEY_ID"
      value = aws_iam_access_key.block_ro.id
    },
    { 
      name = "S3_SECRET_ACCESS_KEY"
      value = aws_iam_access_key.block_ro.secret
    }, {
      name = "S3_BUCKET"
      value = aws_s3_bucket.blocks_bucket.id
    }, {
      name = "S3_PREFIX"
      value = var.s3_block_prefix
    }, {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.blocks"
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
      name = "TOKEN_BONDING_PROGRAM_ID"
      value = var.token_bonding_program_id
    }, {
      name = "WUMBO_PROGRAM_ID"
      value = var.wumbo_program_id
    }
  ]
}

module "account_leaderboard" {
  source = "./modules/data_pipeline"
  region = var.aws_region
  command = "dist/lib/leaderboard/index.js"
  cluster = aws_ecs_cluster.wumbo.id
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
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
      value = "json.solana.bonding_token_account_balance_changes"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "account-leaderboard"
    }, {
      name = "REDIS_HOST"
      value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}"
    }, {
      name = "REDIS_PORT"
      value = "6379"
    }
  ]
}

module "wum_locked_leaderboard" {
  source = "./modules/data_pipeline"
  region = var.aws_region
  command = "dist/lib/leaderboard/index.js"
  cluster = aws_ecs_cluster.wumbo.id
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  name = "${var.env}-wum-locked-leaderboard"
  cpu = 200
  memory = 512
  desired_count = 1  
  environment = [
    {
      name = "PLUGIN"
      value = "WUM_LOCKED"
    },
    {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.total_wum_locked"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "wum-locked-leaderboard"
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
  region = var.aws_region
  command = "dist/lib/leaderboard/index.js"
  cluster = aws_ecs_cluster.wumbo.id
  log_group = aws_cloudwatch_log_group.wumbo_logs.name
  name = "${var.env}-top-tokens-leaderboard"
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
      value = "json.solana.token_bonding_supply"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "top-tokens-leaderboard"
    }, {
      name = "REDIS_HOST"
      value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}"
    }, {
      name = "REDIS_PORT"
      value = "6379"
    }
  ]
}
