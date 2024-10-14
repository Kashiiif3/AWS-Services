# No need to change the vpc_id value - it is a static value for each environment
vpc_id = "vpc-"

# true/false - if we want to create api-gateway resource policy
create_resource_policy = true

# true/false - if we want to restrict VPC networks from which you cant connect you API Gateway - should be set for test/prod environment
apigw_restrict_vpc_endpoints = false

# if you set apigw_restrict_vpc_endpoints as true, you need to provide a map of allowed VPC endpoints from which you can access API Gateway
apigw_user_vpc_endpoint_ids = []

# allowed IAM users/roles which can use your API Gateway, "*" means that everyone are allowed to access API Gateway
api_user_role_arns = ["*"]

# Optional custom OpenApi spec file location
#api_spec_location = "../<<SERVICE_NAME>>/openapi.tftpl"

# Logs retention configuration (in days) - default: 90
#logs_retention_in_days = 120

# Certificate ARN for custom domain (it should be created manually for each aws account)
domain_certificate_arn = ""

vpce_ips = [""] # used to set ALB for the custom DNS


##########################################################
#             Dynamo DB Configuration                    #
##########################################################

dynamodb_config = {
  moj-data = {
    hash_key            = "Reference"           # partition key
    range_key           = "Reference#timestamp" # sort key
    autoscaling_enabled = true
    stream_enabled      = true

    autoscaling_read = {
      scale_in_cooldown  = 50
      scale_out_cooldown = 70
      target_value       = 70
      max_capacity       = 5
    }
    autoscaling_write = {
      scale_in_cooldown  = 50
      scale_out_cooldown = 70
      target_value       = 70
      max_capacity       = 5
    }
  }
}

############################################# TAGS ###########################################################
# Service, project, environment tags are important because they are used to set the names of your resources
##############################################################################################################
tags = {
  project                = "MyProject" ## Shoud not be changed for this project
  environment            = "dev"
  code_repo              = "https://github.com/*******"
  business_owner         = "*******"
  technical_owner        = ""
  cost_centre            = ""
  application            = ""
  product_area           = ""
  support_group          = "DevOps"
  department             = "IT"
  aws_account = "dev"
}
