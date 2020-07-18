# 指定されたドメイン名にGlobalなIPアドレスを確保し結びつける
# その後、出来上がったアドレスを返すモジュール

resource "google_dns_managed_zone" "this" {
  name     = var.name
  # 最後に "." が必要になるので補完している
  dns_name = "${var.root}."
}

resource "google_compute_global_address" "this" {
  count = length(var.domains)
  name  = "global-ip-${var.domains[count.index].name}"
}

resource "google_dns_record_set" "this" {
  count        = length(var.domains)
  name         = "${var.domains[count.index].domain}."
  managed_zone = google_dns_managed_zone.this.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.this[count.index].address]
}
