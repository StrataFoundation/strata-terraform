resource "aws_s3_bucket" "blocks_bucket" {
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
  name = "${var.env}-strata-solana-blocks-ro"
  path = "/etl/"
}

resource "aws_iam_access_key" "block_ro" {
  user = aws_iam_user.block_ro.name
}

module "slot_identifier" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/kafka-s3-slot-identifier.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-slot-identifier"
  cpu = 100
  memory = 300
  desired_count = 1  
  environment = [
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
      value = "json.solana.slots"
    }, {
      name = "NUM_PARTITIONS",
      value = var.slots_num_partitions
    }
  ]
}

locals {
  accounts = join(",", [
        "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
        "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL",
        "namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX",
        var.token_bonding_program_id,
        var.token_collective_program_id
      ])
}

module "block_uploader" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/kafka-s3-block-uploader.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-block-uploader"
  cpu = var.block_uploader_cpu
  memory = var.block_uploader_memory
  desired_count = var.block_uploader_count
  environment = [
    {
      name = "S3_ACCESS_KEY_ID"
      value = aws_iam_access_key.block_rw.id
    },
    {
      name = "KAFKA_GROUP_ID",
      value = "kafka-s3-block-uploader"
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
      name = "KAFKA_INPUT_TOPIC",
      value = "json.solana.slots"
    }, {
      name = "KAFKA_TOPIC"
      value = "json.solana.blocks"
    }, {
      name = "ACCOUNTS"
      value = local.accounts
    }
  ]
}

module "missed_block_uploader" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/kafka-s3-block-uploader.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-missed-block-uploader"
  cpu = var.block_uploader_cpu
  memory = var.block_uploader_memory
  desired_count = 1
  environment = [
    {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    },
    {
      name = "S3_ACCESS_KEY_ID"
      value = aws_iam_access_key.block_rw.id
    },
    {
      name = "KAFKA_GROUP_ID",
      value = "kafka-s3-missed-block-uploader-1"
    },
    {
      name = "S3_SECRET_ACCESS_KEY"
      value = aws_iam_access_key.block_rw.secret
    }, {
      name = "SOLANA_URL"
      value = var.missed_block_solana_url
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
      name = "KAFKA_INPUT_TOPIC",
      value = "json.solana.missed_slots"
    }, {
      name = "KAFKA_TOPIC"
      value = "json.solana.blocks"
    }, {
      name = "ACCOUNTS"
      value = local.accounts
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
  desired_count = 1  
  environment = [
    {
      name = "SOLANA_URL",
      value = var.solana_url
    },
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
      value = "json.solana.strata_users_wum_net_worth_by_account_table"
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

module "wum_net_worth_leaderboard" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/leaderboard/index.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-wum-net-worth-leaderboard"
  cpu = 200
  memory = 512
  desired_count = 1  
  environment = [
    {
      name = "PLUGIN"
      value = "WUM_NET_WORTH"
    },
    {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.strata_users_total_wum_net_worth"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "total-wum-net-worth-leaderboard"
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
      value = "json.solana.strata_token_bonding_supply"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "top-token-leaderboard"
    }, {
      name = "REDIS_HOST"
      value = "${aws_elasticache_cluster.redis.cache_nodes[0].address}"
    }, {
      name = "REDIS_PORT"
      value = "6379"
    }
  ]
}

module "total_wum_net_worth" {
  source = "./modules/data_pipeline"
  image = var.data_pipeline_image
  region = var.aws_region
  command = "dist/lib/leaderboard/index.js"
  cluster = aws_ecs_cluster.strata.id
  log_group = aws_cloudwatch_log_group.strata_logs.name
  name = "${var.env}-total-wum-net-worth"
  cpu = 100
  memory = 256
  desired_count = 1  
  environment = [
    {
      name = "PLUGIN"
      value = "TOTAL_WUM_NET_WORTH"
    },
    {
      name = "KAFKA_BOOTSTRAP_SERVERS"
      value = aws_msk_cluster.kafka.bootstrap_brokers_tls
    }, {
      name = "KAFKA_SSL_ENABLED"
      value = "true"
    }, {
      name = "KAFKA_INPUT_TOPIC"
      value = "json.solana.global_total_wum_net_worth"
    }, {
      name = "KAFKA_OFFSET_RESET"
      value = "earliest"
    }, {
      name = "KAFKA_GROUP_ID"
      value = "total-wum-net-worth"
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
