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
