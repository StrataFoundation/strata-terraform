
variable "log_group" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = list(object({ name = string, value = string }))
}

variable "command" {
  type = string
}

variable "cluster" {
  type = string
}

variable "name" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "desired_count" {
  type = number
}

resource "aws_ecs_task_definition" "task" {
  family = var.name
  container_definitions = jsonencode([
    {
      name = var.name
      image = "554418307194.dkr.ecr.us-east-2.amazonaws.com/wumbo-data-pipelines:1.0.9"
      cpu = var.cpu
      memory = var.memory
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = var.log_group
          "awslogs-region": var.region
          "awslogs-stream-prefix": "complete-ecs"
        }
      }
      command = ["node", var.command]
      environment = var.environment
    }
  ])
}

resource "aws_ecs_service" "service" {
  name = var.name
  cluster = var.cluster
  task_definition = aws_ecs_task_definition.task.arn
  desired_count = var.desired_count
}
