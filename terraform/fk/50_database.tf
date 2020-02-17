locals {
  database_url = "postgres://${local.database.username}:${local.database.password}@${aws_db_instance.fk-database.address}/${local.database.name}?sslmode=disable"
}

resource "aws_db_subnet_group" "fk" {
  name        = "${local.env}-db"
  description = "${local.env}-db"
  subnet_ids  = [ for key, value in local.network.azs: aws_subnet.private[key].id ]

  tags = {
	Name = local.env
  }
}

resource "aws_db_instance" "fk-database" {
  identifier             = local.database.id
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "9.6.11"
  instance_class         = local.database.instance
  name                   = local.database.name
  username               = local.database.username
  password               = local.database.password
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.fk.name
  vpc_security_group_ids = [ aws_security_group.db-server.id ]

  tags = {
    Name = local.env
  }

  lifecycle {
	prevent_destroy = true
  }
}
