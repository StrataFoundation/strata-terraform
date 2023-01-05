locals {
  hf_bucket_names = [
    "foundation-entropy",
    "foundation-iot-ingest",
    "foundation-iot-packet-ingest",
    "foundation-iot-packet-verifier",
    "foundation-iot-verifier",
    "foundation-mobile-ingest",
    "foundation-mobile-packet-ingest",
    "foundation-mobile-packet-verifier",
    "foundation-mobile-verifier"
  ]
  nova_bucket_names = [
    "mainnet-iot-entropy",
    "mainnet-iot-ingest",
    "mainnet-iot-packet-reports",
    "mainnet-iot-reports",
    "mainnet-iot-rewards",
    "mainnet-iot-verified-rewards"
  ]
  nova_account_ids = [
    "${var.nova_iot_aws_account_id}",
    "${var.nova_mobile_aws_account_id}"
  ]
}