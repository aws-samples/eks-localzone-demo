output "efs_id" {
  value = resource.aws_efs_file_system.wordpress.id
}

output "efs_ap_id" {
  value = resource.aws_efs_access_point.wordpress_ap.id
}

output "volumeHandle" {
  value = "${resource.aws_efs_file_system.wordpress.id}::${resource.aws_efs_access_point.wordpress_ap.id}"
}

output "efs_mount_target" {
  value = "${resource.aws_efs_mount_target.default[*].ip_address}"
}