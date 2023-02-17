resource "aws_ssm_parameter" "private_subnet_id_a" {
  name        = "/vpc/private_subnet_id_a"
  description = "ID of Private Subnet for use in Serverless"
  type        = "String"
  value       = "${module.vpc.private_subnets[0]}"
}

resource "aws_ssm_parameter" "private_subnet_id_b" {
  name        = "/vpc/private_subnet_id_b"
  description = "ID of Private Subnet for use in Serverless"
  type        = "String"
  value       = "${module.vpc.private_subnets[1]}"
}

resource "aws_ssm_parameter" "dlq_arn" {
  name        = "/sqs/dlq_arn"
  description = "ARN of DLQ for use in Serverless"
  type        = "String"
  value       = "${aws_sqs_queue.poc_data_object_replicator_to_S3_rp_dlq.arn}"
}
