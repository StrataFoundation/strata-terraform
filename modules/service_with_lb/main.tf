variable "lb_security_groups" {
  type = list(string)
}

variable "service_security_groups" {
  type = list(string)
}

variable "command" {
  type = list(string)
}

variable "lb_subnets" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "health_path" {
  type = string
  default = "/"
}

variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "name" {
  type = string
}

variable "path" {
  type = string
}

variable "environment" {
  type = list(object({ name = string, value = string }))
}

variable "image" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "log_group" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "internal" {
  type = bool
}

resource "aws_lb" "api" {
  internal           = var.internal #tfsec:ignore:AWS005
  load_balancer_type = "application"
  name               = "${var.name}-alb"
  security_groups    = var.lb_security_groups
  subnets            = var.lb_subnets
}

resource "aws_lb_target_group" "api" {
  name = "${var.name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 30
    path                = var.health_path
    port                = 8080
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port = "443"
  protocol = "HTTPS"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
  certificate_arn = var.certificate_arn
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_lb.api.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_certificate" "api" {
  listener_arn    = aws_lb_listener.api.arn
  certificate_arn = var.certificate_arn
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = var.path
  type    = "A"

  alias {
    name = aws_lb.api.dns_name
    zone_id = aws_lb.api.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.api.arn
  priority     = 100
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  family = var.name
  network_mode = "awsvpc"
  container_definitions = jsonencode([
    {
      name = var.name
      portMappings = [
        {
          containerPort = 8080
          hostPort = 8080
          protocol = "tcp"
        }
      ]
      image = var.image
      cpu = var.cpu
      memory = var.memory
      essential = true
      command = var.command
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = var.log_group
          "awslogs-region": var.region
          "awslogs-stream-prefix": "complete-ecs"
        }
      }
      environment = var.environment
    }
  ])
}

resource "aws_ecs_service" "service" {
  name = var.name
  cluster = var.cluster
  task_definition = aws_ecs_task_definition.task.arn
  desired_count = var.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name = var.name
    container_port = 8080
  }

  ordered_placement_strategy {
    type = "binpack"
    field = "cpu"
  }

  network_configuration {
    security_groups = var.service_security_groups
    subnets = var.subnets
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      health_check_grace_period_seconds,
      capacity_provider_strategy,
      deployment_circuit_breaker,
      deployment_controller,
      propagate_tags
    ]
  }
}
