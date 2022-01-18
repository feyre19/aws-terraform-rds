resource "aws_db_parameter_group" "tlz_db_parameter_group" {
  count  = var.create_db_instance && var.deploy_parameter_group ? 1 : 0
  name   = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-db-parameter-group-${var.location}"
  family = var.db_parameter_group_family
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }
  tags = merge(
    {
      "Name" = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-db-parameter-group-${var.location}"
    },
    var.tags
  )
  lifecycle {
    create_before_destroy = true
  }
}
