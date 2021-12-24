variable "aws_region" {
  type = string
  default = "us-east-2"
}

variable "env" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "ovpn_users" { 
  type = list(string)
  default = ["strata"] 
}

variable "aws_azs" {
  type = list(string)
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "private_subnets" {
  type = list(string)
  default = [ "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24" ]
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "num_kafka_nodes" {
  type = number
  default = 3
}

variable "kafka_ebs_size" {
  default = 100
}

variable "kafka_instance_type" {
  default = "kafka.t3.small"
}

variable "instance_type" {
  default = "m5.large"
}
variable "redis_instance_type" {
  default = "cache.t2.small"
}

variable "num_redis_nodes" {
  default = 1
}

variable "cluster_instance_iam_policy_contents" {
  description = "The contents of the cluster instance IAM policy."
  type        = string
  default     = ""
}
variable "cluster_service_iam_policy_contents" {
  description = "The contents of the cluster service IAM policy."
  type        = string
  default     = ""
}

variable "s3_block_prefix" {
  default = "blocks"
}

variable "block_uploader_memory" {
  default = 1028
}

variable "block_uploader_cpu" {
  default = 350
}

variable "token_bonding_program_id" {
  default = "TBondmkCYxaPCKG4CHYfVTcwQ8on31xnJrPzk8F8WsS"
}

variable "token_collective_program_id" {
  default = "TCo1sfSr2nCudbeJPykbif64rG9K1JNMGzrtzvPmp3y"
}

variable "block_uploader_count" {
  type = number
  default = 1
}

variable "slots_num_partitions" {
  default = 8
}

variable "solana_url" {
  default = "https://strata.devnet.rpcpool.com/"
}

variable "missed_block_solana_url" {
  default = "https://explorer-api.mainnet-beta.solana.com/"
}

variable "data_pipeline_image" {
  type = string
}

variable "nft_verifier_image" {
  type = string
}

variable "nft_verifier_count" {
  type = number
  default = 1
}

variable "nft_verifier_mismatch_threshold" {
  type = string
  default = "20"
}

variable "strata_api_image" {
  type = string
}

variable "wumbo_identity_service_image" {
  type = string
}

variable "wumbo_identity_service_count" {
  type = number
  default = 1
}

variable "strata_api_count" {
  type = number
  default = 1
}

variable "nft_verifier_tld" {
  type = string
}

variable "trophy_service_account" {
  type = string
}

variable "nft_verifier_service_account" {
  type = string
}

variable "twitter_tld" {
  type = string
}

variable "twitter_service_account" {
  type = string
}

variable "payer_service_account" {
  type = string
}

variable "twitter_api_key" {
  type = string
}

variable "twitter_secret" {
  type = string
}

variable "twitter_access_token_key" {
  type = string
}

variable "twitter_access_token_secret" {
  type = string
}

variable "auth0_client_id" {
  type = string
}

variable "auth0_client_secret" {
  type = string
}

variable "auth0_domain" {
  type = string
  default = "strata.us.auth0.com"
}

variable "zone_id" {
  description = "The rotue53 zone id of the domain we're using in this tf"
  default = "Z06616691LGG8SVBGW7XC"
}

variable "ksqldb_count" {
  type = number
  default = 2
}

variable "ksqldb_memory" {
  default = 1028
}

variable "ksqldb_cpu" {
  default = 512
}

variable "cluster_max_size" { 
  type = number
  default = 3
}