output "ip_address" {
  description = "ドメインに対応して確保されたIPアドレス"
  value       = google_compute_global_address.this[*].address
}

output "address_name" {
  description = "ドメインに対応して確保されたIPアドレスのGCP内での名称"
  value       = google_compute_global_address.this[*].name
}
