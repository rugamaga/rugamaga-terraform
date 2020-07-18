variable "name" {
  description = "マネージドゾーンに与える名称"
  type        = string
}

variable "root" {
  description = "マネージドゾーンで利用するルートドメイン名"
  type        = string
}

variable "domains" {
  description = "利用するサブドメイン名。(ここではサブドメインにルートドメインも含む)"
  type = list(object({
    name   = string
    domain = string
  }))
}
