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

# --- Budget & Cost Anomaly ------------------------------------------------
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

variable "raise_amount_percent" {
  description = "The precentage increase in montly spend to trigger the billing anomaly detector"
  type        = string
  default     = "15"
}

variable "raise_amount_absolute" {
  description = "The absolute increase in USD to trigger the billing anomaly detector"
  type        = string
  default     = "500"
}