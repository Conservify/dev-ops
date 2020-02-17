variable region {
  type = string
  default = "us-east-1"
}

variable access_key {
  type = string
}

variable secret_key {
  type = string
}

variable workspace_tags {
  type = map(string)
}

variable workspace_zones {
  type = map(object({
	id = string
	name = string
  }))
}

variable workspace_buckets {
  type = map(object({
	streams = string
	media = string
  }))
}

variable workspace_databases {
  type = map(object({
	id = string
	name = string
	username = string
	password = string
	instance = string
  }))
}

variable bastions {
  // This crashes?
  /*
  type = map(object({
	name = string
	cidr = tuple([string])
  }))
  */
}

variable gelf_url {
  type = string
}

variable influx_database {
  type = object({
	url = string,
	name = string,
	user = string,
	password = string
  })
}

variable application_start {
  type = string
  default = ""
}

variable application_stack {
  default = ""
}

variable certificate_arn {
  type = string
}

variable workspace_servers {
  type = map(map(object({
	name = string
	number = number
	instance = string
  })))
}

variable workspace_networks {
  type = map(object({
	cidr = string
	peering = string
	azs = map(object({
	  public = string
	  private = string
	  gateway = bool
	}))
  }))
}

locals {
  network = var.workspace_networks[terraform.workspace]
  zones = keys(local.network.azs)

  all = flatten([
	for k, v in var.workspace_servers[terraform.workspace] : [
	  for r in range(v.number) : {
		name = "${local.env}-${v.name}-${r}"
		number = r
		config = v
		zone = local.zones[r % length(local.zones)]
	  }
	]
  ])
  servers = {
	for r in local.all : r.name => r
  }

  zone = var.workspace_zones[terraform.workspace]
  env = var.workspace_tags[terraform.workspace]
  buckets = var.workspace_buckets[terraform.workspace]
  database = var.workspace_databases[terraform.workspace]
}
