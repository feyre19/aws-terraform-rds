resource "aws_db_subnet_group" "tlz_db_subnet_group" {
  count      = var.create_db_instance ? 1 : 0
  name       = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-db-subnet-group-${var.location}"
  subnet_ids = var.subnet_ids
  tags = merge(
    {
      "Name" = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-db-subnet-group-${var.location}"
    },
    var.tags
  )
}
