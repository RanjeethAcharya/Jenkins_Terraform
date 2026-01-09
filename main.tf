resource "aws_vpc" "ranjeeth-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ranjeeth-terraform-vpc"
  }
}

resource "aws_internet_gateway" "ranjeeth-igw" {
  vpc_id = aws_vpc.ranjeeth-vpc.id
}

resource "aws_subnet" "ranjeeth-public-subnet" {
  vpc_id            = aws_vpc.ranjeeth-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_route_table" "ranjeeth-rt" {
  vpc_id = aws_vpc.ranjeeth-vpc.id
}

resource "aws_route" "ranjeeth-rt" {
  route_table_id         = aws_route_table.ranjeeth-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ranjeeth-igw.id
}

resource "aws_route_table_association" "ranjeeth-rt-association" {
  subnet_id      = aws_subnet.ranjeeth-public-subnet.id
  route_table_id = aws_route_table.ranjeeth-rt.id
}

resource "aws_security_group" "ranjeeth-sg" {
  name        = "ranjeeth-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.ranjeeth-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ubuntu" {
  ami                         = "ami-0ecb62995f68bb549"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.ranjeeth-public-subnet.id
  vpc_security_group_ids      = [aws_security_group.ranjeeth-sg.id]
  associate_public_ip_address = true
  key_name                    = "ranjeeth"
  user_data                   = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "<h1>Hello from Terraform Nginx Server</h1>" | sudo tee /var/www/html/index.html
  EOF

  tags = {
    Name = "terraform-ubuntu"
  }

}

