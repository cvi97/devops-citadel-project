provider "azurerm" {
  features {}
}

resource "null_resource" "copy_charts" {
  count = length(var.charts)

  provisioner "local-exec" {
    command = <<EOT
      az acr import \
        --name ${var.acr_server} \
        --source ${var.source_acr_server}/${var.charts[count.index].chart_name}:${var.charts[count.index].chart_version} \
        --subscription ${var.acr_server_subscription} \
        --force
    EOT

    environment = {
      AZURE_CLIENT_ID       = var.source_acr_client_id
      AZURE_CLIENT_SECRET   = var.source_acr_client_secret
      AZURE_SUBSCRIPTION_ID = var.acr_server_subscription
    }
  }

  triggers = {
    chart = jsonencode(var.charts[count.index])
  }
}

resource "helm_release" "chart" {
  for_each = { for chart in var.charts : chart.chart_name => chart }

  name      = each.value.chart_name
  namespace = each.value.chart_namespace
  chart     = "${var.acr_server}/${each.value.chart_name}"
  version   = each.value.chart_version

  dynamic "set" {
    for_each = each.value.values

    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set_sensitive" {
    for_each = each.value.sensitive_values

    content {
      name  = set_sensitive.key
      value = set_sensitive.value
    }
  }

  depends_on = [null_resource.copy_charts]
}
