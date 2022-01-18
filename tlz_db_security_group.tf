resource "aws_security_group" "tlz_security_group_db" {
  count                  = var.create_db_instance && var.create_db_sg ? 1 : 0
  name                   = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-db-sg-${var.location}"
  description            = "A security group for ${var.rds_name} RDS."
  vpc_id                 = var.db_vpc_id
  revoke_rules_on_delete = true
  dynamic "ingress" {
    for_each = var.ingress
    content {
      from_port       = lookup(ingress.value, "from_port", null)
      to_port         = lookup(ingress.value, "to_port", null)
      protocol        = lookup(ingress.value, "protocol", null)
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      description     = lookup(ingress.value, "description", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      self            = lookup(ingress.value, "self", null)
    }
  }
  dynamic "egress" {
    for_each = var.egress
    content {
      from_port       = lookup(egress.value, "from_port", null)
      to_port         = lookup(egress.value, "to_port", null)
      protocol        = lookup(egress.value, "protocol", null)
      cidr_blocks     = lookup(egress.value, "cidr_blocks", null)
      description     = lookup(egress.value, "description", null)
      security_groups = lookup(egress.value, "security_groups", null)
      self            = lookup(egress.value, "self", null)
    }
  }
  tags = merge(
    {
      "Name" = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-db-sg-${var.location}"
    },
    var.tags,
  )
}
