output bare_ami_id {
  value = data.aws_ami.bare.id
}

output database_url {
  value = local.database_url
}

output servers {
  value = [
	for key, i in aws_instance.app-servers: {
	  id = i.id
	  key = key
	  user = "ubuntu"
	  ip = i.private_ip
	  sshAt = "ubuntu@${i.private_ip}"
	}
  ]
}