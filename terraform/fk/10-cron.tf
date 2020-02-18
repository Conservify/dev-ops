resource "aws_cloudwatch_event_rule" "fk-cron-every-five-rule" {
  name                = "fk-cron-every-five-rule"
  description         = "fk-cron-every-five-rule"
  schedule_expression = "cron(0/5 * * * ? *)"
  count               = local.prod_instances
}

resource "aws_cloudwatch_event_target" "fk-cron-every-five-target" {
  count               = local.prod_instances
  target_id           = "fk-cron-every-five-target"
  rule                = aws_cloudwatch_event_rule.fk-cron-every-five-rule[0].name
  arn                 = aws_lambda_function.fk-cron-every-five[0].arn
  input               = <<EOF
{
}
EOF
}

resource "aws_iam_role" "fk-cron-every-five-role" {
  count               = local.prod_instances
  name                = "fk-cron-every-five-role"
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": "sts:AssumeRole",
	  "Principal": {
		"Service": "lambda.amazonaws.com"
	  },
	  "Effect": "Allow",
	  "Sid": ""
	}
  ]
}
EOF
}

resource "aws_iam_policy" "fk-cron-logging-policy" {
  count       = local.prod_instances
  name        = "fk-cron-logging-policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": [
		"logs:CreateLogGroup",
		"logs:CreateLogStream",
		"logs:PutLogEvents"
	  ],
	  "Resource": "arn:aws:logs:*:*:*",
	  "Effect": "Allow"
	}
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "fk-cron-every-five-logging" {
  role             = aws_iam_role.fk-cron-every-five-role[0].name
  policy_arn       = aws_iam_policy.fk-cron-logging-policy[0].arn
  count            = local.prod_instances
}

resource "aws_lambda_function" "fk-cron-every-five" {
  count            = local.prod_instances
  filename         = "build/fk_cron_every_five.zip"
  function_name    = "fk-cron-every-five"
  role             = aws_iam_role.fk-cron-every-five-role[0].arn
  handler          = "fk_cron_every_five.handler"
  runtime          = "python2.7"
  timeout          = 10
  source_code_hash = filesha256("build/fk_cron_every_five.zip")

  lifecycle {
	ignore_changes = [ source_code_hash ]
  }
}

resource "aws_lambda_permission" "fk-allow-cloudwatch-call-every-five" {
  statement_id     = "AllowExecutionFromCloudWatch"
  action           = "lambda:InvokeFunction"
  function_name    = aws_lambda_function.fk-cron-every-five[0].function_name
  principal        = "events.amazonaws.com"
  source_arn       = aws_cloudwatch_event_rule.fk-cron-every-five-rule[0].arn
  count            = local.prod_instances
}
