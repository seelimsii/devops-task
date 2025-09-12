# Find the default VPC
data "aws_vpc" "default" {
  default = true
}

# Find all the subnets within that default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}