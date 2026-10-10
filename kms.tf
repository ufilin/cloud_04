resource "yandex_kms_symmetric_key" "ufilin_kms_key" {
  name              = "ufilin-kms-key"
  description       = "KMS key for encrypting data in k8s"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # 1 year
}
