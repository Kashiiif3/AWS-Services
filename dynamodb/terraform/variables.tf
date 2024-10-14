variable "vpc_id" {
  type        = string
  description = "Main VPC ID where resources should be created"
}

variable "sg_allowed_ingress_cidr_blocks" {
  type        = list(any)
  description = "Allowed CIDRs"
  default     = ["0.0.0.0/0"]
}


variable "alb_sg_allowed_ingress_cidr_blocks" {
  type        = list(any)
  default     = ["0.0.0.0/0"]
  description = "Allowed ingress cidr blocks for ALB"
}

variable "vpce_ips" {
  type        = list(any)
  description = "IPs of VPC Endpoint for execute-api service"
}

variable "dynamodb_config" {
  type = map(object({
    create_table                   = optional(bool, true)
    hash_key                       = optional(string)
    range_key                      = optional(string)
    write_capacity                 = optional(string, "1")
    read_capacity                  = optional(string, "1")
    autoscaling_enabled            = optional(bool, false)
    autoscaling_read               = map(string)
    autoscaling_write              = map(string)
    billing_mode                   = optional(string, "PROVISIONED")
    deletion_protection_enabled    = optional(bool, null)
    point_in_time_recovery_enabled = optional(bool, true)
    table_class                    = optional(string, null)
    stream_enabled                 = optional(bool, false)
    stream_view_type               = optional(string, "NEW_AND_OLD_IMAGES")
  }))
  description = "Map of dynamodb"
  default     = {}
}

variable "dynamodb_data_attributes" {
  description = "List of nested attribute definitions. Only required for hash_key and range_key attributes. Each attribute has two properties: name - (Required) The name of the attribute, type - (Required) Attribute type, which must be a scalar type: S, N, or B for (S)tring, (N)umber or (B)inary data"
  type        = list(map(string))
  default = [
    {
      name = "MyReference"
      type = "S"
    },
    {
      name = "Reference#timestamp" #Using Composite Keys
      type = "S"
    }
  ]
}

variable "tags" {
  type = object({
    project                = string
    code_repo              = string
    business_owner         = string
    technical_owner        = string
    cost_centre            = string
    environment            = string
    application            = string
    product_area           = string
    support_group          = string
    department             = string
    account = string
  })
  description = "Resource tags which will be added to all created resources"
}
################################################################################################
