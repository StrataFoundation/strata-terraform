# --- Environment variables ------------------------------------------------
variable "aws_region" {
  description = "AWS region you're deploying to e.g., us-east-1"
  type        = string
  default     = ""
}

# --- Environment variables ------------------------------------------------
variable "account_ids" {
  description = "Account IDs to grant Prometheus write access"
  type        = list(string)
  default     = []
}

# --- Slack ------------------------------------------------
variable "slack_webhook_url" {
  description = "Slack Webhook URL for alerting."
  type        = string
  default     = ""
}
