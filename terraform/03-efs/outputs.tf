output "efs_id" {
  value = resource.aws_efs_file_system.wordpress.id
}

output "efs_ap_id" {
  value = resource.aws_efs_access_point.wordpress_ap.id
}