output "installed_charts" {
  value       = helm_release.chart.*.metadata.name
  description = "Names of the installed Helm charts"
}
