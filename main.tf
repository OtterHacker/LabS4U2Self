provider "aws" {
  region     = var.aws_region
}

data "aws_ami" "windows" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["801119661308"]
}

resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
}


# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "default" {
  count                   = "${length(var.subnets)}"
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${element(values(var.subnets), count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(keys(var.subnets), count.index)}"
  depends_on              = [aws_internet_gateway.default]
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_security_group" "default" {
  name        = "allow_whitelist"
  description = "Allow all inbound traffic from whilisted IPs in vars file of terraform attack range"
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.ip_whitelist
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# standup windows 2016 domain controller

resource "aws_instance" "windows_dc" {
  ami           = data.aws_ami.windows.id
  instance_type = "t2.medium"
  key_name = var.key_name
  subnet_id = "${aws_subnet.default.0.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  tags = {
    Name = "attack-range_windows_dc"
  }
  user_data = <<EOF
<powershell>
$admin = [adsi]("WinNT://./${var.win_username}, user")
$admin.PSBase.Invoke("SetPassword", "${var.win_password}")
Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))

</powershell>
EOF

 provisioner "local-exec" {
    working_dir = "ansible"

    command = "sleep 120;cp hosts.default hosts; sed -i 's/PUBLICIP/${aws_instance.windows_dc.public_ip}/g' hosts;ansible-playbook -vvv -i hosts playbooks/windows_dc.yml"
  }
}

# sql server

resource "aws_instance" "windows_sql" {
  ami           = data.aws_ami.windows.id
  instance_type = "t2.medium"
  key_name = var.key_name
  subnet_id = "${aws_subnet.default.0.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  depends_on = [aws_instance.windows_dc]
  tags = {
    Name = "attack-range_windows_dc"
  }
  user_data = <<EOF
<powershell>
$admin = [adsi]("WinNT://./${var.win_username}, user")
$admin.PSBase.Invoke("SetPassword", "${var.win_password}")
Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))

</powershell>
EOF

  provisioner "local-exec" {
    working_dir = "ansible"
    command = "sleep 120;cp playbooks/roles/mssql/tasks/main.yml.tpl playbooks/roles/mssql/tasks/main.yml; sed -i 's/DNSIP/${aws_instance.windows_dc.private_ip}/g' playbooks/roles/mssql/tasks/main.yml; cp hosts.default hosts; sed -i 's/PUBLICIP/${aws_instance.windows_sql.public_ip}/g' hosts;ansible-playbook -vvv -i hosts playbooks/windows_sql.yml"
  }
}
