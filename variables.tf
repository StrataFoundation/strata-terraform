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
  default = ["wumbo"] 
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
  default = "TBondz6ZwSM5fs4v2GpnVBMuwoncPkFLFR9S422ghhN"
}

variable "wumbo_program_id" {
  default = "WumbodN8t7wcDPCY2nGszs4x6HRtL5mJcTR519Qr6m7"
}

variable "block_uploader_count" {
  type = number
  default = 1
}

variable "slots_num_partitions" {
  default = 8
}

variable "solana_url" {
  default = "https://wumbo.devnet.rpcpool.com/"
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

variable "wumbo_api_image" {
  type = string
}

variable "wumbo_api_count" {
  type = number
  default = 1
}

variable "nft_verifier_tld" {
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
  default = "wumbo.us.auth0.com"
}

variable "zone_id" {
  description = "The rotue53 zone id of the domain we're using in this tf"
  default = "Z06616691LGG8SVBGW7XC"
}

variable "ksqldb_count" {
  type = number
  default = 2
}

variable "cluster_max_size" { 
  type = number
  default = 3
}