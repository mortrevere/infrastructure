output "managed_dns_record_count" {
  description = "Number of OVH DNS records managed by this stack."
  value       = length(local.dns_records)
}
