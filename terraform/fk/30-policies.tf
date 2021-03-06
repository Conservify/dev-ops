resource "aws_s3_bucket" "fk-streams" {
  bucket = local.buckets.create.streams
  acl = "private"
}

resource "aws_s3_bucket" "fk-media" {
  bucket = local.buckets.create.media
  acl = "private"
}

resource "aws_s3_bucket_policy" "fk-streams" {
  bucket = aws_s3_bucket.fk-streams.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Id": "Policy1234567890123",
	"Statement": [{
		"Sid": "Stmt1234567890123",
		"Effect": "Allow",
		"Principal": "*",
		"Action": "s3:*",
		"Resource": "arn:aws:s3:::${local.buckets.create.streams}/*",
		"Condition": {
			"StringEquals": {
				"aws:sourceVpc": "${aws_vpc.fk.id}"
			}
		}
	}]
}
POLICY
}

resource "aws_iam_role" "fk-server" {
  name = "${local.env}-server"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
	{
	  "Action": "sts:AssumeRole",
	  "Principal": {
		"Service": "ec2.amazonaws.com"
	  },
	  "Effect": "Allow"
	}
  ]
}
EOF
}

resource "aws_iam_instance_profile" "fk-server" {
  name = "${local.env}-server"
  role = aws_iam_role.fk-server.name
}

resource "aws_iam_role_policy" "fk-server" {
  name   = "${local.env}-server"
  role   = aws_iam_role.fk-server.id
  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": "ses:SendEmail",
			"Resource": "*",
			"Condition": {
				"StringEquals": {
					"ses:FromAddress": [
						"admin@fkdev.org",
						"admin@fkstg.org",
						"admin@fieldkit.org"
					]
				}
			}
		},
		{
			"Sid": "VisualEditor2",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject"
			],
			"Resource": [
				"arn:aws:s3:::conservify-firmware/*"
			]
		},
		{
			"Sid": "VisualEditor3",
			"Effect": "Allow",
			"Action": [
				"s3:ListBucket"
			],
			"Resource": [
				${join(", ", formatlist("\"arn:aws:s3:::%s\"", split(",", local.buckets.config.streams)))}
			]
		},
		{
			"Sid": "VisualEditor4",
			"Effect": "Allow",
			"Action": [
				"s3:ListBucket"
			],
			"Resource": [
				${join(", ", formatlist("\"arn:aws:s3:::%s\"", split(",", local.buckets.config.media)))}
			]
		},
		{
			"Sid": "VisualEditor5",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject"
			],
			"Resource": [
				${join(", ", formatlist("\"arn:aws:s3:::%s/*\"", split(",", local.buckets.config.streams)))}
			]
		},
		{
			"Sid": "VisualEditor6",
			"Effect": "Allow",
			"Action": [
				"s3:GetObject"
			],
			"Resource": [
				${join(", ", formatlist("\"arn:aws:s3:::%s/*\"", split(",", local.buckets.config.media)))}
			]
		},
		{
			"Sid": "VisualEditor7",
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:PutObjectAcl"
			],
			"Resource": [
				"arn:aws:s3:::${local.buckets.create.streams}/*",
				"arn:aws:s3:::${local.buckets.create.media}/*"
			]
		}
	]
}
POLICY
}
