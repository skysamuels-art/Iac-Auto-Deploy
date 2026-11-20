# ================= Security Group (stateful, instance level) =================
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "SSH, HTTP and HTTPS"
  vpc_id      = aws_vpc.main.id

  tags = { Name = "${local.name_prefix}-web-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH"
  cidr_ipv4         = var.allowed_ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "web" {
  for_each = toset([for p in var.web_ports : tostring(p)])

  security_group_id = aws_security_group.web.id
  description       = "Web port ${each.value}"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ================= Network ACL (stateless, subnet level) =================
# NACLs are stateless, so return traffic (ephemeral ports) must be allowed explicitly.
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  # SSH
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = var.allowed_ssh_cidr
    from_port  = 22
    to_port    = 22
  }

  # HTTP / HTTPS (rules 110, 120, ...)
  dynamic "ingress" {
    for_each = var.web_ports
    content {
      rule_no    = 110 + ingress.key * 10
      protocol   = "tcp"
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = ingress.value
      to_port    = ingress.value
    }
  }

  # Ephemeral ports: replies to traffic the instances start (dnf updates, etc.)
  ingress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # All outbound
  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "${local.name_prefix}-public-nacl" }
}