resource "random_password" "tlz_db_master_password" {
  count            = var.create_db_instance ? 1 : 0
  length           = var.random_password_length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "tlz_ssm_parameter_db_password" {
  name        = "/${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-${local.resource_type}-${var.location}/database/password/master"
  description = "The master password for database."
  type        = "SecureString"
  value       = random_password.tlz_db_master_password[0].result
  tags = merge(
    {
      "Name" = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-password-${var.location}"
    },
    var.tags
  )
  depends_on = [random_password.tlz_db_master_password]
}

resource "aws_db_instance" "tlz_db_instance" {
  count                                 = var.create_db_instance ? 1 : 0
  identifier                            = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-${local.resource_type}-${var.location}"
  engine                                = var.db_engine
  engine_version                        = var.db_engine_version
  instance_class                        = var.db_instance_class
  allocated_storage                     = var.allocated_storage
  storage_type                          = var.storage_type
  storage_encrypted                     = true
  kms_key_id                            = var.kms_key_id
  license_model                         = var.license_model
  name                                  = var.db_name
  username                              = var.db_username
  password                              = aws_ssm_parameter.tlz_ssm_parameter_db_password.value
  port                                  = var.port
  domain                                = var.domain
  domain_iam_role_name                  = var.domain != null ? var.domain_iam_role_name : null
  iam_database_authentication_enabled   = var.iam_database_authentication_enabled
  vpc_security_group_ids                = var.create_db_sg ? aws_security_group.tlz_security_group_db.*.id : var.db_security_group_ids
  db_subnet_group_name                  = aws_db_subnet_group.tlz_db_subnet_group[0].name
  parameter_group_name                  = var.deploy_parameter_group ? aws_db_parameter_group.tlz_db_parameter_group[0].name : null
  option_group_name                     = var.deploy_option_group ? aws_db_option_group.tlz_db_option_group[0].name : null
  availability_zone                     = var.availability_zone
  multi_az                              = var.environment == "prod" ? true : false
  iops                                  = var.iops
  publicly_accessible                   = false
  ca_cert_identifier                    = var.ca_cert_identifier
  allow_major_version_upgrade           = var.allow_major_version_upgrade
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade
  apply_immediately                     = var.apply_immediately
  maintenance_window                    = var.maintenance_window
  snapshot_identifier                   = var.snapshot_identifier
  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  skip_final_snapshot                   = var.skip_final_snapshot
  final_snapshot_identifier             = var.skip_final_snapshot ? null : "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-${local.resource_type}-${var.location}-FINAL-SNAPSHOT"
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  replicate_source_db                   = var.replicate_source_db
  backup_retention_period               = var.backup_retention_period
  backup_window                         = var.backup_window
  max_allocated_storage                 = var.max_allocated_storage
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? aws_iam_role.tlz_iam_role_enhanced_monitoring[0].arn : null
  character_set_name                    = var.character_set_name
  timezone                              = var.timezone # MSSQL only
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  #deletion_protection                   = true
  deletion_protection      = false
  delete_automated_backups = var.delete_automated_backups
  tags = merge(
    {
      "Name" = "${var.prefix}-${var.environment}-${var.project_name}-${var.rds_name}-${local.resource_type}-${var.location}"
    },
    var.tags
  )
  timeouts {
    create = lookup(var.db_timeouts, "create", null)
    delete = lookup(var.db_timeouts, "delete", null)
    update = lookup(var.db_timeouts, "update", null)
  }
  depends_on = [aws_security_group.tlz_security_group_db, aws_ssm_parameter.tlz_ssm_parameter_db_password,aws_db_subnet_group.tlz_db_subnet_group, aws_db_parameter_group.tlz_db_parameter_group, aws_db_option_group.tlz_db_option_group]
}

################################################################################
# Enhanced monitoring
################################################################################
data "aws_iam_policy_document" "tlz_iam_policy_document_enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "tlz_iam_role_enhanced_monitoring" {
  count              = var.create_monitoring_role ? 1 : 0
  name               = "${var.prefix}-${var.environment}-${var.project_name}-rds-enhanced-monitoring-role-${var.location}"
  assume_role_policy = data.aws_iam_policy_document.tlz_iam_policy_document_enhanced_monitoring.json
  description        = "A role for enhanced monitoring of RDS."
  tags = merge(
    {
      "Name" = "${var.prefix}-${var.environment}-${var.project_name}-rds-monitoring-role-${var.location}"
    },
    var.tags,
  )
}

resource "aws_iam_role_policy_attachment" "tlz_iam_role_policy_attachment_enhanced_monitoring" {
  count      = var.create_monitoring_role ? 1 : 0
  role       = aws_iam_role.tlz_iam_role_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
