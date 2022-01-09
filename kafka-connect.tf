module "kafka_connect" {
  source = "./modules/service_with_lb"
  image = var.nft_verifier_image
  internal = false
  name = "${var.env}-kafka-connect"
  path = "${var.env}-kafka-connect.teamwumbo.com"
  cluster = aws_ecs_cluster.strata.id
  zone_id = var.zone_id
  lb_security_groups = [data.aws_security_group.default.id, aws_security_group.allow_http_https_inbound.id]
  service_security_groups =  [data.aws_security_group.default.id, module.web_server_sg.security_group_id, module.elasticsearch.security_group_id]
  lb_subnets = module.vpc.public_subnets
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  certificate_arn = aws_acm_certificate.main_domain.arn
  cpu = 1000
  memory = 8192
  region = var.aws_region
  log_group = aws_cloudwatch_log_group.strata_logs.name
  desired_count = 1
  environment = [
      {
        name = "CONNECT_BOOTSTRAP_SERVERS"
        value =  aws_msk_cluster.kafka.bootstrap_brokers_tls
      },
      {
         name = "CONNECT_REST_PORT"
         value = "8080"
      },
      {
        name = "CONNECT_GROUP_ID"
        value = "kafka-connect"
      },
      {
        name = "CONNECT_CONFIG_STORAGE_TOPIC"
        value = "_kafka-connect-configs"
      },
      {
        name = "CONNECT_OFFSET_STORAGE_TOPIC"
        value = "_kafka-connect-offsets"
      },
      {
        name = "CONNECT_STATUS_STORAGE_TOPIC"
        value = "_kafka-connect-status"
      },
      {
        name = "CONNECT_KEY_CONVERTER"
        value = "org.apache.kafka.connect.json.JsonConverter"
      },
      {
        name = "CONNECT_VALUE_CONVERTER"
        value = "org.apache.kafka.connect.json.JsonConverter"
      },
      {
        name = "CONNECT_KEY_CONVERTER_SCHEMAS_ENABLE"
        value = "false"
      },
      {
        name = "CONNECT_VALUE_CONVERTER_SCHEMAS_ENABLE"
        value = "false"
      },
      {
        name = "CONNECT_INTERNAL_KEY_CONVERTER"
        value = "org.apache.kafka.connect.json.JsonConverter"
      },
      {
        name = "CONNECT_INTERNAL_VALUE_CONVERTER"
        value = "org.apache.kafka.connect.json.JsonConverter"
      },
      {
        name = "CONNECT_REST_ADVERTISED_HOST_NAME"
        value = "kafka-connect-01"
      },
      {
        name = "CONNECT_LOG4J_ROOT_LOGLEVEL"
        value = "INFO"
      },
      {
        name = "CONNECT_LOG4J_LOGGERS"
        value = "org.apache.kafka.connect.runtime.rest=WARN,org.reflections=ERROR"
      },
      {
        name = "CONNECT_LOG4J_APPENDER_STDOUT_LAYOUT_CONVERSIONPATTERN"
        value = "[%d] %p %X{connector.context}%m (%c:%L)%n"
      },
      {
        name = "CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR"
        value = "1"
      },
      {
        name = "CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR"
        value = "1"
      },
      {
        name = "CONNECT_STATUS_STORAGE_REPLICATION_FACTOR"
        value = "1"
      },
      {
        name = "CONNECT_PLUGIN_PATH"
        value = "/usr/share/java,/usr/share/confluent-hub-components"
      }
  ]
}
