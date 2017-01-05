# API Gateway Logging
resource "aws_api_gateway_account" "artifact_metadata" {
  cloudwatch_role_arn = "${aws_iam_role.apigw_access_cw_logs_role.arn}"
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "artifact_metadata" {
  name        = "${var.name}-rest-endpoint"
  description = "Artifact Metadata REST API"
}

# Deploy: /api
resource "aws_api_gateway_deployment" "api" {
  depends_on  = ["aws_api_gateway_integration.retrieve_all_artifacts"]
  rest_api_id = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  stage_name  = "${var.rest_api_root_uri}"
}
