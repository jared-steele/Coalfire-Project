terraform {
  backend "s3" {
    # Where to store the state file
    bucket = "coalfire-project"
    key = "coalfire-project/terraform.tfstate"
    region = "us-east-2"

    #DynamoDB table
    dynamodb_table = "coalfire-project"
    encrypt = true
    
  }
}