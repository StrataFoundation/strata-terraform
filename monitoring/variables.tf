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

# --- Budget ------------------------------------------------
variable "budget_amount" {
  description = "Montly budget amount"
  type        = string
  default     = ""
}

variable "budget_email_list" {
  description = "Montly budget amount"
  type        = list(string)
  default     = []
}
