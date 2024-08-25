# get the latest ubuntu image ami
data "aws_ami" "latest_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "my_labtop" {
  key_name   = "my_labtop"
  public_key = file(".ssh/id_rsa.pub")
}

module "vpc" {
  source = "../modules/vpc"

  ENVIRONMENT = var.ENVIRONMENT
  AWS_REGION  = var.AWS_REGION
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [module.vpc.default_sg_id]
  subnet_id              = module.vpc.public-1_subnets

  key_name = aws_key_pair.my_labtop.key_name
  tags = {
    Name = "MasterServer"
    ENV  = var.ENVIRONMENT
    OS   = "Ubuntu"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.39"
  instance_class       = "db.t4g.micro"
  db_name             = "SOONGSIL_STUDENT_CAFETERIA_SCM"
  username             = "admin"
  password             = "Rkrenrl12#"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
  backup_retention_period = 7
  backup_window           = "07:00-09:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"
  vpc_security_group_ids = [module.vpc.rds_sg_id]
  db_subnet_group_name = module.vpc.rds_sg_name

  tags = {
    Name = "soongsil_cafeteria"
    ENV  = var.ENVIRONMENT
    OS   = "Ubuntu"
  }
}
