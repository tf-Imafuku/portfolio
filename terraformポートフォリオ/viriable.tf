variable "project" {
  default = "test"
}

variable "environment" {
  default = "dev"
}

variable "domain" {
  default = "koji-satumaimo.net"
}

#アクセスキー
variable "aws_access_key_id" {
  default = "AKIAVVONYY3VXYSIKDLF"
}
variable "aws_secret_access_key" {
  default = "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"
}

#ssh接続を許可するIPアドレス
variable "MyIP" {
  default = "131.129.220.207/32"
}

