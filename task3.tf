provider "aws" {
  region     = "ap-south-1"
}
//key-pair
resource "tls_private_key" "taskkey" {
 algorithm = "RSA"
 rsa_bits = 4096
}
resource "aws_key_pair" "key" {
 key_name = "task3key"
 public_key = "${tls_private_key.taskkey.public_key_openssh}"
 depends_on = [
    tls_private_key.taskkey
]
}
resource "local_file" "key1" {
 content = "${tls_private_key.taskkey.private_key_pem}"
 filename = "task3key.pem"
  depends_on = [
    aws_key_pair.key
   ]
}
//network.tf
resource "aws_vpc" "test-env" {
   cidr_block = "192.168.0.0/16"
   enable_dns_hostnames = true
   enable_dns_support = true
   tags ={
     Name = "test-env"
   }
 }
resource "aws_subnet" "subnet-efs-sql" {
   vpc_id = "${aws_vpc.test-env.id}"
   map_public_ip_on_launch = "true"
   cidr_block = "192.168.1.0/24"
   availability_zone = "ap-south-1b"
 }
resource "null_resource" "nulllocal1"  {
depends_on = [
    aws_vpc.test-env,
	aws_subnet.subnet-efs-sql,
  ]
 }
resource "aws_subnet" "subnet-efs-wp" {
   vpc_id = "${aws_vpc.test-env.id}"
   map_public_ip_on_launch = "true"
   cidr_block = "192.168.0.0/24"
   availability_zone = "ap-south-1a"
 }
resource "null_resource" "nulllocal1478"  {
depends_on = [
    aws_vpc.test-env,
  ]
 }
//security-group
resource "aws_security_group" "wp" {
  vpc_id = "${aws_vpc.test-env.id}"
  name        = "task3wp"
  ingress {
    description = "TCP"
    from_port   = 80	
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
     description = "SSH"
     from_port   = 22	
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}
  egress {
     from_port   = 0	
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
}  
  tags = {
    Name = "task3wp"
  }
}
resource "null_resource" "nulllocal2"  {
depends_on = [
    aws_vpc.test-env,
        aws_subnet.subnet-efs-wp,
	aws_subnet.subnet-efs-sql,
  ]
}
resource "aws_security_group" "sql" {
  vpc_id = "${aws_vpc.test-env.id}"
  name        = "task3sql"
 ingress {
    description = "TCP"
    from_port   = 3306	
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.wp.id}"]
}
  egress {
     from_port   = 0	
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
}  
  tags = {
    Name = "task3sql"
  }
}
resource "null_resource" "nulllocal271"  {
depends_on = [
    aws_vpc.test-env,
    aws_subnet.subnet-efs-wp,
	aws_subnet.subnet-efs-sql,
  ]
}
resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.test-env.id}"
tags ={
    Name = "test-env-gw"
  }
}
resource "null_resource" "nulllocal1301"  {
depends_on = [
    aws_vpc.test-env,
	aws_subnet.subnet-efs-wp,
	aws_subnet.subnet-efs-sql,
	aws_security_group.sql,
	aws_security_group.wp,
  ]
}
resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.test-env.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }
tags ={
    Name = "test-env-route-table"
  }
}
resource "null_resource" "nulllocal91302"  {
depends_on = [
    aws_internet_gateway.test-env-gw,
	aws_vpc.test-env,
	aws_subnet.subnet-efs-sql,
	aws_security_group.wp,
	aws_subnet.subnet-efs-wp,
	aws_security_group.sql
  ]
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-efs-wp.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}
resource "null_resource" "nulllocal139011"  {
depends_on = [
    aws_route_table.route-table-test-env,
    aws_internet_gateway.test-env-gw,
	aws_vpc.test-env,
	aws_subnet.subnet-efs-sql,
	aws_subnet.subnet-efs-wp,
	aws_security_group.sql,
	aws_security_group.wp,
  ]
}
resource "aws_instance" "word" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet-efs-wp.id}"
  vpc_security_group_ids = ["${aws_security_group.wp.id}"]
  key_name = "task3key"
tags ={
    Name = "wordpress"
  }
}
resource "null_resource" "nulllocal130711"  {
depends_on = [
    aws_route_table.route-table-test-env,
    aws_internet_gateway.test-env-gw,
	aws_vpc.test-env,
	aws_subnet.subnet-efs-sql,
	aws_subnet.subnet-efs-wp,
	aws_security_group.sql,
	aws_security_group.wp,
	aws_instance.mysql,
  ]
}
resource "aws_instance" "mysql" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.subnet-efs-sql.id}"
  vpc_security_group_ids = ["${aws_security_group.sql.id}"]
  key_name = "task3key"
tags ={
    Name = "mysql"
  }
}

resource "null_resource" "nulllocal130151"  {
depends_on = [
    aws_route_table.route-table-test-env,
    aws_internet_gateway.test-env-gw,
	aws_vpc.test-env,
	aws_subnet.subnet-efs-sql,
	aws_subnet.subnet-efs-wp,
	aws_security_group.sql,
	aws_security_group.wp,
  ]
}
resource "null_resource" "nulllocal1005"  {
	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.word.public_ip}"
  	}
}
resource "null_resource" "nulllocal13011"  {
depends_on = [
    aws_route_table.route-table-test-env,
    aws_internet_gateway.test-env-gw,
	aws_vpc.test-env,
	aws_subnet.subnet-efs-sql,
	aws_subnet.subnet-efs-wp,
	aws_security_group.sql,
	aws_security_group.wp,
	aws_instance.mysql,
  ]
}