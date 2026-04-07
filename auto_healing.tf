locals {
  instance_id = "i-07956e4228ca0d6ba"
  sns_arn     = "arn:aws:sns:us-east-1:243768737939:monitoring_alerts"
}

# --- IAM Role for Lambda ---
resource "aws_iam_role" "lambda_role" {
  name = "auto_heal_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:RebootInstances"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

# --- Lambda Function ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/auto_remediation.py"
  output_path = "${path.module}/auto_remediation.zip"
}

resource "aws_lambda_function" "auto_heal" {
  function_name    = "auto_heal_ec2"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "auto_remediation.lambda_handler"
  runtime          = "python3.11"
}

# --- Allow SNS to invoke Lambda ---
resource "aws_lambda_permission" "sns_invoke" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_heal.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = local.sns_arn
}

# --- Subscribe Lambda to SNS ---
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = local.sns_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.auto_heal.arn
}

# --- Critical CPU Alarm (triggers reboot) ---
resource "aws_cloudwatch_metric_alarm" "critical_cpu" {
  alarm_name          = "CriticalCPU-AutoHeal"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 90
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [local.sns_arn]
  dimensions = {
    InstanceId = local.instance_id
  }
}

# --- Critical Memory Alarm (triggers reboot) ---
resource "aws_cloudwatch_metric_alarm" "critical_memory" {
  alarm_name          = "CriticalMemory-AutoHeal"
  metric_name         = "MemoryUsedPercent"
  namespace           = "CWAgent"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 90
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [local.sns_arn]
  dimensions = {
    InstanceId = local.instance_id
  }
}
