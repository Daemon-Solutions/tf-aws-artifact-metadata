# URI: /api/artifact
resource "aws_api_gateway_resource" "artifact_root" {
  parent_id   = "${aws_api_gateway_rest_api.artifact_metadata.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  path_part   = "artifact"
}

# URI: /api/artifact/{name}
resource "aws_api_gateway_resource" "artifact_by_name" {
  parent_id   = "${aws_api_gateway_resource.artifact_root.id}"
  rest_api_id = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  path_part   = "{artifact_name}"
}

# GET /api/artifact/{name} HTTP/1.1
resource "aws_api_gateway_method" "get_artifact_by_name" {
  rest_api_id      = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  resource_id      = "${aws_api_gateway_resource.artifact_by_name.id}"
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

# HTTP/1.1 200 OK
resource "aws_api_gateway_method_response" "200_resp_get_artifact_by_name" {
  rest_api_id = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  resource_id = "${aws_api_gateway_resource.artifact_by_name.id}"
  http_method = "${aws_api_gateway_method.get_artifact_by_name.http_method}"
  status_code = "200"
}

# BE_REQ to DynamoDB for /api/artifact/{name}
resource "aws_api_gateway_integration" "retrieve_artifact_by_name" {
  rest_api_id             = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  resource_id             = "${aws_api_gateway_resource.artifact_by_name.id}"
  http_method             = "${aws_api_gateway_method.get_artifact_by_name.http_method}"
  type                    = "AWS"
  integration_http_method = "POST"
  credentials             = "${aws_iam_role.apigw_access_dynamodb_role.arn}"
  uri                     = "arn:aws:apigateway:eu-west-1:dynamodb:action/Query"

  request_templates = {
    "application/json" = <<EOF
{
    "TableName": "${aws_dynamodb_table.artifact_metadata_table.id}",
    "KeyConditionExpression": "artifact_name = :v1",
    "ExpressionAttributeValues": {
        ":v1": {
            "S": "$input.params('artifact_name')"
        }
    }
}
EOF
  }
}

# BE_RESP to API Gateway with JSON from DynamoDB
resource "aws_api_gateway_integration_response" "200_resp_artifact_by_name_retrieval" {
  depends_on  = ["aws_api_gateway_integration.retrieve_artifact_by_name"]
  rest_api_id = "${aws_api_gateway_rest_api.artifact_metadata.id}"
  resource_id = "${aws_api_gateway_resource.artifact_by_name.id}"
  http_method = "${aws_api_gateway_method.get_artifact_by_name.http_method}"
  status_code = "${aws_api_gateway_method_response.200_resp_get_artifact_by_name.status_code}"

  response_templates = {
    "application/x-amz-json-1.0" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "Count": "$inputRoot.Count",
  "Artifacts": [
#foreach($elem in $inputRoot.Items)
    {
      "Name": "$elem.artifact_name.S",
      "Version": "$elem.artifact_version.S",
      "Release": "$elem.artifact_release.S",
      "Timestamp": "$elem.created_timestamp.N"
    }#if($foreach.hasNext),#end
#end
  ]
}
EOF
  }
}
