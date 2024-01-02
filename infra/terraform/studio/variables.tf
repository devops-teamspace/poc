variable "aws_region" {
  type = string
}

variable "service" {
  type = string
}

variable "state_backend_bucket_name" {
  type = string
}

variable "network_state_backend_key" {
  type = string
}

variable "eks_state_backend_key" {
  type = string
}

variable "storage_state_backend_key" {
  type = string
}

variable "edge_server_image_tag" {
  type = string
}

variable "edge_server_model_data_s3_url" {
  type = string
}

variable "edge_server_endpoint_name" {
  type = string
}

variable "edge_server_variant_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "sns_backend_subscribe_path" {
  type = string
}

variable "kms_state_backend_bucket_name" {
  type = string
}

variable "kms_state_backend_key" {
  type = string
}

variable "env" {
  type = string
}

variable "edge_server_initial_instance_count" {
  type = number
}

variable "edge_server_initial_variant_weight" {
  type = number
}

variable "edge_server_min_instance_count" {
  type = number
}

variable "edge_server_max_instance_count" {
  type = number
}

variable "edge_server_autoscale_target_value" {
  type = number
}

variable "edge_server_autoscale_scale_in_cooldown" {
  type = number
}

variable "edge_server_autoscale_scale_out_cooldown" {
  type = number
}
