resource "aws_lambda_function" "test_lambda" {
  filename      = "function.zip"
  function_name = "lambda_trigger"
  role          = "${aws_iam_role.test_role.arn}"
  handler       = "main.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${filebase64sha256("function.zip")}"

  runtime = "python3.7"
}

resource "aws_cloudwatch_event_rule" "CWRule" {
  name = "CWRule"

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.autoscaling"
    ],
    "detail-type": [
      "EC2 Instance Launch Successful",
      "EC2 Instance Terminate Successful",
      "EC2 Instance Launch Unsuccessful",
      "EC2 Instance Terminate Unsuccessful",
      "EC2 Instance-launch Lifecycle Action",
      "EC2 Instance-terminate Lifecycle Action"
    ]
  }
PATTERN
}

resource "aws_cloudwatch_event_target" "ansible" {
  rule      = "${aws_cloudwatch_event_rule.CWRule.name}"
  target_id = "Ansible"
  arn       = "arn:aws:lambda:eu-central-1:998069768433:function:lambda_trigger"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.CWRule.arn}"
}
