####################################################################################################################
#                                     DynamoDB Module and Data Stream                                              #
####################################################################################################################

module "dynamodb" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "4.0.1"

  for_each = var.dynamodb_config

  create_table = each.value.create_table
  name         = "Dynamod-${each.key}-${var.tags.environment}"
  hash_key     = each.value.hash_key  # partition key
  range_key    = each.value.range_key # sort key

  billing_mode   = each.value.billing_mode
  read_capacity  = each.value.read_capacity
  write_capacity = each.value.write_capacity

  autoscaling_enabled = each.value.autoscaling_enabled
  autoscaling_read    = each.value.autoscaling_enabled ? each.value.autoscaling_read : {}
  autoscaling_write   = each.value.autoscaling_enabled ? each.value.autoscaling_write : {}

  # autoscaling_read    = each.value.autoscaling_enabled ? tomap({ scale_in_cooldown = 50, scale_out_cooldown = 70, target_value = 70, max_capacity = 5 }) : {}
  # autoscaling_write   = each.value.autoscaling_enabled ? tomap({ scale_in_cooldown = 50, scale_out_cooldown = 70, target_value = 70, max_capacity = 5 }) : {}

  deletion_protection_enabled    = each.value.deletion_protection_enabled
  point_in_time_recovery_enabled = each.value.point_in_time_recovery_enabled


  table_class = each.value.table_class
  ttl_enabled = false

  attributes = var.dynamodb_data_attributes
  # attributes = each.value.autoscaling_enabled ? var.dynamodb_data_attributes : var.dynamodb_document_attributes

  stream_enabled   = each.value.stream_enabled
  stream_view_type = each.value.stream_enabled ? each.value.stream_view_type : null

  tags = {
    name = "dynamodb_${each.key}"
  }
}