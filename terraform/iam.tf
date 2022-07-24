# data "aws_iam_policy_document" "aurora_monitoring_assume" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "sts:AssumeRole",
#     ]

#     principals {
#       type = "Service"
#       identifiers = [
#         "monitoring.rds.amazonaws.com",
#       ]
#     }
#   }
# }

# resource "aws_iam_role" "aurora_monitoring" {
#   name               = "terraform-aurora-sample-aurora-monitoring-iam-${terraform.workspace}"
#   assume_role_policy = data.aws_iam_policy_document.aurora_monitoring_assume.json
# }

# resource "aws_iam_role_policy_attachment" "aurora_monitoring" {
#   role       = aws_iam_role.aurora_monitoring.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
# }

resource "aws_iam_role" "lambda-edge" {
  name = "lambda-edge"

  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "cloudwatch-log-group-lambda-edge" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda-edge.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda-edge-cloudwatch-log-group" {
  name   = "lambda-edge-cloudwatch-log-group-${terraform.workspace}"
  role   = aws_iam_role.lambda-edge.name
  policy = data.aws_iam_policy_document.cloudwatch-log-group-lambda-edge.json
}
