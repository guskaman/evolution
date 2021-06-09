# Test VPC

resource "aws vpc" "aws vpc" {
    cird_block = 10.51.0.0/16

    tags = {
        Name = "EVO VPC"
    }
}