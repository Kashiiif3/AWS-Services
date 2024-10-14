###################################################################################################################
#                                          CloudWatch Event Rule                                                   #
####################################################################################################################


# Creating Metric Alarm with custom metric query 

resource "aws_cloudwatch_metric_alarm" "error-4XX" {
  alarm_name          = "${var.tags.project}-apigw-4XXerrorRate-${var.tags.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 10
  alarm_description   = "${var.tags.project}-apigw-4XXerrorRate-${var.tags.environment} - Higher than expected"
  datapoints_to_alarm = 2
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]

  metric_query {
    id          = "e1"
    expression  = "100*(m1/m2)"
    label       = "4XX Error Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period      = 60
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = aws_api_gateway_rest_api.this.name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = 60
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = aws_api_gateway_rest_api.this.name
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "error-5XX" {
  alarm_name          = "${var.tags.project}-apigw-5XXerrorRate-${var.tags.environment}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = 10
  alarm_description   = "${var.tags.project}-apigw-5XXerrorRate-${var.tags.environment} - Higher than expected"
  datapoints_to_alarm = 2
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]
  metric_query {
    id          = "e1"
    expression  = "100*(m1/m2)"
    label       = "5XX Rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      metric_name = "5XXError"
      namespace   = "AWS/ApiGateway"
      period      = 60
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = aws_api_gateway_rest_api.this.name
      }
    }
  }

  metric_query {
    id = "m2"

    metric {
      metric_name = "Count"
      namespace   = "AWS/ApiGateway"
      period      = 60
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        ApiName = aws_api_gateway_rest_api.this.name
      }
    }
  }
}

# SQS Queue Failures 

resource "aws_cloudwatch_metric_alarm" "sqs-notification" {
  alarm_name          = "${var.tags.project}-sqs-failures-${var.tags.environment}" #Approximate Age Of Oldest Message
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  alarm_description   = "${var.tags.project}-sqs-queue-${var.tags.environment} - Higher than expected"
  datapoints_to_alarm = 2
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.user_updates.arn]
  # ok_actions        = [aws_sns_topic.user_updates.arn]
  metric_name        = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = "60"
  statistic          = "Average"
  threshold          = "5000"
  treat_missing_data = "notBreaching"
}


####################################################################################################################
#                                    SNS Topic for Email Notification                                              #
####################################################################################################################

# Create an SNS topic
resource "aws_sns_topic" "user_updates" {
  name              = "${var.tags.project}-${var.tags.environment}-email-notification"
  kms_master_key_id = module.kms_key.key_arn
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

####################################################################################################################
#                                          Cloud Watch Dashboard                                                   #
####################################################################################################################

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.tags.project}-dashboard-${var.tags.environment}"

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          "type" : "text",
          "x" : 0,
          "y" : 0,
          "width" : 24,
          "height" : 1,
          "properties" : {
            "markdown" : "\n# API Gateway Metrics\n"
          }
        }
      ],
      [
        {
          "type" : "metric",
          "x" : 0,
          "y" : 0,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/ApiGateway", "Count", "ApiName", "${var.tags.project}-${var.tags.environment}"],
              [".", "Count", ".", "."],
              [".", "Latency", ".", "."],
              [".", "IntegrationLatency", ".", "."]
            ],
            "period" : 3000,
            "stat" : "Sum", #Average
            "region" : "eu-west-1",
            "title" : "API Gateway Metrics"
          }
        }
      ],
      [
        {
          "type" : "metric",
          "x" : 12,
          "y" : 0,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/ApiGateway", "4XXError", "ApiName", "${var.tags.project}-${var.tags.environment}"],
            ],
            "view" : "gauge",
            "period" : 60,
            "stat" : "Sum", #Average
            "region" : "eu-west-1",
            "title" : "4XX Error",
            "yAxis" : {
              "left" : {
                "min" : 0,
                "max" : 100,
              }
            }
          }
        }
      ],
      [
        {
          "type" : "metric",
          "x" : 18,
          "y" : 0,
          "width" : 6,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/ApiGateway", "5XXError", "ApiName", "${var.tags.project}-${var.tags.environment}"],
            ],
            "view" : "gauge",
            "period" : 60,
            "stat" : "Sum", #Average
            "region" : "eu-west-1",
            "title" : "5XX Error",
            "yAxis" : {
              "left" : {
                "min" : 0,
                "max" : 100
              }
            }
          }
        }
      ],
      [
        {
          "type" : "text",
          "x" : 0,
          "y" : 8,
          "width" : 24,
          "height" : 1,
          "properties" : {
            "markdown" : "\n# Dynamo DB Table\n"
          }
        }
      ],
      [
        {
          "type" : "metric",
          "x" : 0,
          "y" : 9,
          "width" : 24,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", "dynamodb-${var.tags.environment}"],
              [".", "ConsumedWriteCapacityUnits", ".", "."],
              [".", "ProvisionedReadCapacityUnits", ".", "."],
              [".", "ProvisionedWriteCapacityUnits", ".", "."]
            ],
            "period" : 60,
            "stat" : "Sum",
            "region" : "eu-west-1",
            "title" : "DynamoDB Metrics"
          }
        }
      ],
      [
        {
          "type" : "text",
          "x" : 0,
          "y" : 13,
          "width" : 24,
          "height" : 1,
          "properties" : {
            "markdown" : "\n# Lambda Functions Metrics\n"
          }
        }
      ],
      [
        for frontend_functions, frontend_lambda in var.frontend_lambda_config : {
          "type" : "metric",
          "x" : 0,
          "y" : 14,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/Lambda", "Invocations", "FunctionName", "${var.tags.project}-${frontend_functions}-${var.tags.environment}"],
              [".", "Errors", ".", "."],
              [".", "Duration", ".", "."],
              [".", "Throttles", ".", "."],
              [".", "Invocations", ".", "."],
              [".", "ConcurrentExecutions", ".", "."],
              [".", "AsyncEventAge", ".", "."],
              [".", "AsyncEventsDropped", ".", "."],
              [".", "AsyncEventsRecieved", ".", "."]
            ],
            "period" : 60,
            "stat" : "Average",
            "region" : "eu-west-1",
            "title" : "${frontend_functions} "
          }
        }
      ],
      [
        for backend_lambda_function, backend_lambda in var.backend_lambda_config : {
          "type" : "metric",
          "x" : 12,
          "y" : 15,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/Lambda", "Invocations", "FunctionName", "${var.tags.project}-${backend_lambda_function}-${var.tags.environment}"],
              [".", "Errors", ".", "."],
              [".", "Duration", ".", "."],
              [".", "Throttles", ".", "."],
              [".", "Invocations", ".", "."],
              [".", "ConcurrentExecutions", ".", "."],
              [".", "AsyncEventAge", ".", "."],
              [".", "AsyncEventsDropped", ".", "."],
              [".", "AsyncEventsRecieved", ".", "."]
            ],
            "period" : 60,
            "stat" : "Average",
            "region" : "eu-west-1",
            "title" : "${backend_lambda_function} "
          }
        }
      ],
      # Filter Logs from lambda function for Error Failures 
      [
        {
          "type" : "log",
          "x" : 0,
          "y" : 17,
          "width" : 24,
          "height" : 6,
          "properties" : {
            "query" : "SOURCE '/aws/lambda/${var.tags.project}-stage-one-services-${var.tags.environment}' | fields @timestamp, @message, @logStream, @log | filter @message like /ERROR/ | sort @timestamp desc | limit 10000 ",
            "period" : 60,
            "region" : "eu-west-1",
            "title" : "${var.tags.project}-lambda-one-${var.tags.environment} logs"
            "view" : "table"
          }
        }
      ],
      [
        {
          "type" : "text",
          "x" : 0,
          "y" : 18,
          "width" : 24,
          "height" : 1,
          "properties" : {
            "markdown" : "\n# SQS Queues\n "
          }
        }
      ],
      [
        for queues, sqs_queue in var.sqs_config : {
          "type" : "metric",
          "x" : 0,
          "y" : 19,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/SQS", "	NumberOfMessagesSent", "QueueName", "${var.tags.project}-sqs_queue-${var.tags.environment}"], 
              [".", "NumberOfMessagesReceived", ".", "."],
              [".", "NumberOfMessagesDeleted", ".", "."]
            ],
            "period" : 60,
            "stat" : "Sum",
            "region" : "eu-west-1",
            # "title" : "SQS Metrics"
            "title" : "${queues} "
          }
        }
      ],
      [
        {
          "type" : "text",
          "x" : 0,
          "y" : 21,
          "width" : 24,
          "height" : 1,
          "properties" : {
            "markdown" : "\n# Alarms Status\n "
          }
        }
      ],
      [
        {
          "type" : "alarm",
          "x" : 0,
          "y" : 24,
          "width" : 24,
          "height" : 6,
          "properties" : {
            "alarms" : [
              "arn:aws:cloudwatch:eu-west-1:${data.aws_caller_identity.current.account_id}:alarm:${var.tags.project}-apigw-4XXerrorRate-${var.tags.environment}",
              "arn:aws:cloudwatch:eu-west-1:${data.aws_caller_identity.current.account_id}:alarm:${var.tags.project}-apigw-5XXerrorRate-${var.tags.environment}"
            ],
            "title" : "Alarms"
          }
        }
      ]
    )
  })
}


####################################################################################################################
#                                     Cloud Watch Dashboard - Lambda                                               #
####################################################################################################################

resource "aws_cloudwatch_dashboard" "lambda-dashboard" {
  dashboard_name = "${var.tags.project}-dashboard-lambda-${var.tags.environment}"

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          "type" : "text",
          "x" : 0,
          "y" : 0,
          "width" : 24,
          "height" : 1,
          "properties" : {
            "markdown" : "\n# Lambda Metrics\n"
          }
        }
      ],
      [
        {
          "type" : "metric",
          "x" : 12,
          "y" : 1,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/Lambda", "Errors", "FunctionName", "${var.tags.project}-lambda-two-${var.tags.environment}", { "id" : "m1" }],
              ["AWS/Lambda", "Invocations", "FunctionName", "${var.tags.project}-lambda-two-${var.tags.environment}", { "id" : "m2" }],
              [{ "expression" : "100 - 100 * m1 / MAX([m1, m2])", "label" : "Success Rate", "id" : "e1" }]
            ],
            "view" : "gauge",
            "period" : 60,
            "stat" : "Sum", #Average
            "region" : "eu-west-1",
            "title" : "lambda-two Function Success Rate",
            "yAxis" : {
              "left" : {
                "min" : 0,
                "max" : 100,
              }
            }
          }
        }
      ],
      [
        # outbound lambda functions 11 functions
        for backend_lambda_function, backend_lambda in var.backend_lambda_config : {
          "type" : "metric",
          "x" : 0,
          "y" : 2,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/Lambda", "Invocations", "FunctionName", "${var.tags.project}-${backend_lambda_function}-${var.tags.environment}"],
              [".", "Errors", ".", "."],
              [".", "Duration", ".", "."],
              [".", "Throttles", ".", "."],
              [".", "Invocations", ".", "."],
              [".", "ConcurrentExecutions", ".", "."],
              [".", "AsyncEventAge", ".", "."],
              [".", "AsyncEventsDropped", ".", "."],
              [".", "AsyncEventsRecieved", ".", "."]
            ],
            "period" : 60,
            "stat" : "Average",
            "region" : "eu-west-1",
            "title" : "${backend_lambda_function} "
          }
        }
      ],
      [
        for frontend_functions, frontend_lambda in var.frontend_lambda_config : {
          "type" : "metric",
          "x" : 12,
          "y" : 12,
          "width" : 12,
          "height" : 6,
          "properties" : {
            "metrics" : [
              ["AWS/Lambda", "Invocations", "FunctionName", "${var.tags.project}-${frontend_functions}-${var.tags.environment}"],
              [".", "Errors", ".", "."],
              [".", "Duration", ".", "."],
              [".", "Throttles", ".", "."],
              [".", "Invocations", ".", "."],
              [".", "ConcurrentExecutions", ".", "."],
              [".", "AsyncEventAge", ".", "."],
              [".", "AsyncEventsDropped", ".", "."],
              [".", "AsyncEventsRecieved", ".", "."]
            ],
            "period" : 60,
            "stat" : "Average",
            "region" : "eu-west-1",
            "title" : "${frontend_functions} "
          }
        }
      ],
      [
        {
          "type" : "log",
          "x" : 0,
          "y" : 16,
          "width" : 24,
          "height" : 6,
          "properties" : {
            "query" : "SOURCE '/aws/lambda/${var.tags.project}-lamdba-one${var.tags.environment}' | fields @timestamp, @message, @logStream, @log | filter @message like /ERROR/ | sort @timestamp desc | limit 10000 "
            "period" : 60,
            "region" : "eu-west-1",
            "title" : "${var.tags.project}-lambda-one-${var.tags.environment} logs",
            "view" : "table"
          }
        }
      ],
      
      [
        {
          "type" : "metric",
          "x" : 0,
          "y" : 21,
          "width" : 24,
          "height" : 6,
          "properties" : {
            "metrics" : [
              for backend_lambda_function, backend_lambda in var.backend_lambda_config : [
                "AWS/Lambda", "Invocations", "FunctionName", "${var.tags.project}-${backend_lambda_function}-${var.tags.environment}"
              ]
            ],
            "period" : 60,
            "stat" : "Average",
            "region" : "eu-west-1",
            "title" : "Outbound Lambda Invocations"
          }
        }
      ]
    )
  })
}


####################################################################################################################
#                                  Metric Filters for SNS Integration                                              #
####################################################################################################################


resource "aws_cloudwatch_log_metric_filter" "metric_filter" {

  for_each = var.frontend_lambda_config

  name = "${var.tags.project}-${each.key}-${var.tags.environment}-ERROR"
  # log_group_name = aws_cloudwatch_log_group.Log-group.name
  log_group_name = "/aws/lambda/${var.tags.project}-${each.key}-${var.tags.environment}"
  pattern        = "Error" # Log Pattern

  metric_transformation {
    name          = "ErrorCount"
    namespace     = "${var.tags.project}-${each.key}-${var.tags.environment}-metric"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "metric_alarm" {

  for_each = var.frontend_lambda_config

  alarm_name          = "${var.tags.project}-${each.key}-Service-now-${var.tags.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.metric_filter[each.key].metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.metric_filter[each.key].metric_transformation[0].namespace
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alarm when the ErrorCount is greater than 5"
  actions_enabled     = true
  alarm_actions       = ["arn:aws:sns:eu-west-1:${data.aws_caller_identity.current.account_id}:${var.tags.project}-${var.tags.environment}-email-notification"]

}

