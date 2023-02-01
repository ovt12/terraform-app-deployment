provider "aws" {
  region="us-east-1"
}

# create our vpc
resource "aws_vpc" "olivertaylor-application-deployment" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "olivertaylor-application-deployment-vpc"
  }
}

resource "aws_internet_gateway" "olivertaylor-ig" {
  vpc_id = "${aws_vpc.olivertaylor-application-deployment.id}"

  tags = {
    Name = "olivertaylor-ig"
  }
}

resource "aws_route_table" "olivertaylor-rt" {
    vpc_id = "${aws_vpc.olivertaylor-application-deployment.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.olivertaylor-ig.id}"
    }
}





module "application-tier" {
  name="olivertaylor-app"
  source = "./modules/application-teir"
  vpc_id = "${aws_vpc.olivertaylor-application-deployment.id}"
  route_table_id = "${aws_route_table.olivertaylor-rt.id}"
  cidr_block = "10.1.0.0/24"
  user_data=templatefile("./scripts/app_user_data.sh", {})
  ami_id = "ami-097ed995a6ede1d1b"
  map_public_ip_on_launch = true

  ingress = [{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = "0.0.0.0/0"
  }, {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "149.36.18.119/32"
  },{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = "3.145.42.69"
}]
}


