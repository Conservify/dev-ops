locals {
  database_id ="${lookup(var.workspace_to_database_id_map, terraform.workspace, "")}"
  database_name = var.database_name
  database_username = var.database_username
  database_password = "${lookup(var.workspace_to_database_password_map, terraform.workspace, "")}"
}

resource "aws_db_instance" "fk-database" {
  identifier             = local.database_id

  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "9.6.11"
  instance_class         = "db.t2.micro"
  name                   = local.database_name
  username               = local.database_username
  password               = local.database_password
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.fk.name
  vpc_security_group_ids = ["${aws_security_group.db-server.id}"]

  tags = {
    Name = local.env
  }
}
