# POST /api/artifact HTTP/1.1
resource "aws_api_gateway_method" "req_add_artifact" {
  rest_api_id      = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  resource_id      = "${aws_api_gateway_resource.artifact_root.id}"
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

# HTTP/1.1 200 OK
resource "aws_api_gateway_method_response" "200_resp_add_artifact" {
  rest_api_id = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  resource_id = "${aws_api_gateway_resource.artifact_root.id}"
  http_method = "${aws_api_gateway_method.req_add_artifact.http_method}"
  status_code = "200"
}

# BE_REQ to DynamoDB for /api/artifact
resource "aws_api_gateway_integration" "add_artifact" {
  rest_api_id             = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  resource_id             = "${aws_api_gateway_resource.artifact_root.id}"
  http_method             = "${aws_api_gateway_method.req_add_artifact.http_method}"
  type                    = "AWS"
  integration_http_method = "POST"
  credentials             = "${aws_iam_role.apigw_access_dynamodb_role.arn}"
  uri                     = "arn:aws:apigateway:eu-west-1:dynamodb:action/PutItem"

  request_templates = {
    "application/json" = <<EOF
{
  "TableName": "${aws_dynamodb_table.artifact_metadata_table.id}",
  "Item": {
    "artifact_name": {
      "S": "$input.path('$.name')"
    },
    "artifact_version": {
      "S": "$input.path('$.version')"
    },
    "artifact_release": {
      "S": "$input.path('$.release')"
    },
    "created_timestamp": {
      "N": "$input.path('$.timestamp')"
    }
  }
}
EOF
  }
}

# BE_RESP to API Gateway with JSON from DynamoDB
resource "aws_api_gateway_integration_response" "200_resp_add_artifact" {
  depends_on  = ["aws_api_gateway_integration.add_artifact"]
  rest_api_id = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  resource_id = "${aws_api_gateway_resource.artifact_root.id}"
  http_method = "${aws_api_gateway_method.req_add_artifact.http_method}"
  status_code = "${aws_api_gateway_method_response.200_resp_add_artifact.status_code}"
}
