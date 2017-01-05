# Allow API Gateway to access Metadata DynamoDB table
resource "aws_iam_role" "apigw_access_dynamodb_role" {
  name = "${var.name}-apigateway-access-dynamodb-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "access_dynamodb_policy" {
  name = "${var.name}-access-dynamodb-policy"
  role = "${aws_iam_role.apigw_access_dynamodb_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*"
      ],
      "Resource": [
        "${aws_dynamodb_table.artifact_metadata_table.arn}",
        "${aws_dynamodb_table.artifact_metadata_table.arn}/*"
      ]
    }
  ]
}
EOF
}

# Allow API Gateway to access CloudWatch logs
resource "aws_iam_role" "apigw_access_cw_logs_role" {
  name = "${var.name}-apigateway-access-cw-logs-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "access_cw_logs_policy" {
  name = "${var.name}-access-cw-logs-policy"
  role = "${aws_iam_role.apigw_access_cw_logs_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}
