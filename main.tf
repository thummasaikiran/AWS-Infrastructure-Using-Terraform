resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "mysubnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
   map_public_ip_on_launch = true
}
resource "aws_subnet" "mysubnet2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
}
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.mysubnet2.id
  route_table_id = aws_route_table.myrt.id
}
resource "aws_security_group" "mysg" {
  name        = "web"
  vpc_id      = aws_vpc.myvpc.id

    ingress {
        description      = "HTTP from VPC"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"     
        cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
        description      = "SSH"
        from_port        = 22
        to_port          = 22           
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    tags = {
        Name = "web-sg"
    }
}
resource "aws_s3_bucket" "mybucket" {
    bucket = "saikiran-bucket-terraform-12345"

}
resource "aws_instance" "websever1" {
  ami           = "ami-0ecb62995f68bb549"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.mysubnet.id
    vpc_security_group_ids = [aws_security_group.mysg.id]
    user_data_base64 = base64encode(file("userdata1.sh"))
}
resource "aws_instance" "websever2" {
  ami           = "ami-0ecb62995f68bb549"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.mysubnet2.id
    vpc_security_group_ids = [aws_security_group.mysg.id]
    user_data_base64 = base64encode(file("userdata2.sh"))
}
