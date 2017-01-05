# Artifact Metadata DynamoDB Table
resource "aws_dynamodb_table" "artifact_metadata_table" {
  name           = "${var.name}"
  read_capacity  = "${var.global_read_capacity}"
  write_capacity = "${var.global_write_capacity}"

  hash_key  = "artifact_name"
  range_key = "created_timestamp"

  attribute {
    name = "artifact_name"
    type = "S"
  }

  attribute {
    name = "artifact_version"
    type = "S"
  }

  attribute {
    name = "artifact_release"
    type = "S"
  }

  attribute {
    name = "created_timestamp"
    type = "N"
  }

  global_secondary_index {
    name               = "artifact_version_index"
    hash_key           = "artifact_version"
    range_key          = "artifact_release"
    write_capacity     = 5
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["artifact_name"]
  }
}
