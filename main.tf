terraform {
    required_providers {
        aws = {
            source  = "registry.terraform.io/hashicorp/aws"
            version = "~> 4.48.0"
        }
    }
}
provider aws {
    region = "us-west-1"
}
data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}
resource "aws_instance" "example_a" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
}
resource "aws_instance" "example_b" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
}
resource "aws_eip" "ip" {
    vpc = true
    instance = aws_instance.example_a.id
}

resource "aws_s3_bucket" "example" {
    bucket = "test-bucket-56748935"
}

resource "aws_s3_bucket_acl" "example" {
    bucket = aws_s3_bucket.example.id
    acl = "private"
}

resource "aws_instance" "example_c" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"

    depends_on = [aws_s3_bucket.example]
}

module "example_sqs_queue"{
    source = "terraform-aws-modules/sqs/aws"
    version = "2.1.0"

    depends_on = [aws_s3_bucket.example, aws_instance.example_c]
}
