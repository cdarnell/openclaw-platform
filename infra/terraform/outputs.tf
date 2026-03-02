output "oci_public_ip" {
  description = "Public IP of the OpenClaw VM"
  value       = module.compute.public_ip
}
