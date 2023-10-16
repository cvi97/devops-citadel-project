variable "acr_server" {
  description = "ACR server URL where the charts will be copied to and installed from"
  type        = string
}

variable "acr_server_subscription" {
  description = "Subscription ID for the ACR server"
  type        = string
}

variable "source_acr_client_id" {
  description = "Client ID for source ACR"
  type        = string
}

variable "source_acr_client_secret" {
  description = "Client Secret for source ACR"
  type        = string
  sensitive   = true
}

variable "source_acr_server" {
  description = "Source ACR server URL from where the charts will be copied"
  type        = string
}

variable "charts" {
  description = "List of charts to be copied and installed"
  type = list(object({
    chart_name       = string
    chart_namespace  = string
    chart_version    = string
    values           = list(map(string))
    sensitive_values = list(map(string))
  }))
}
