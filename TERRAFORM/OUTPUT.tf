output "resource_group_name" {
  description = "Name of the resource group that contains the GH-200 backup environment."
  value       = azurerm_resource_group.rg.name
}

output "vm_name" {
  description = "Name of the Windows VM used for the self-hosted runner demo."
  value       = azurerm_windows_virtual_machine.lab.name
}

output "vm_public_ip_address" {
  description = "Public IP address assigned to the Windows VM."
  value       = azurerm_public_ip.lab.ip_address
}

output "web_app_name" {
  description = "Name of the Windows Web App used as the GitHub Actions deployment target."
  value       = azurerm_windows_web_app.lab.name
}

output "web_app_url" {
  description = "HTTPS URL of the Windows Web App."
  value       = "https://${azurerm_windows_web_app.lab.default_hostname}"
}

output "app_service_plan_name" {
  description = "Name of the App Service plan that hosts the Windows Web App."
  value       = azurerm_service_plan.lab.name
}

output "linux_vm_name" {
  description = "Name of the Ubuntu VM used for the Java deployment demo."
  value       = azurerm_linux_virtual_machine.lab.name
}

output "linux_vm_public_ip" {
  description = "Public IP address assigned to the Ubuntu VM."
  value       = azurerm_public_ip.linux.ip_address
}

output "linux_ssh_command" {
  description = "Ready-to-paste SSH command for the Ubuntu VM."
  value       = "ssh -i ~/.ssh/gh200-linux ${local.linux_admin}@${azurerm_public_ip.linux.ip_address}"
}

output "app_test_url" {
  description = "HTTP URL of the Java application in the test environment."
  value       = "http://${azurerm_public_ip.linux.ip_address}:8080"
}

output "app_prod_url" {
  description = "HTTP URL of the Java application in the production environment."
  value       = "http://${azurerm_public_ip.linux.ip_address}:8081"
}

output "linux_ssh_private_key" {
  description = "Private SSH key for the Ubuntu VM. Retrieve it with terraform output -raw."
  value       = tls_private_key.linux.private_key_pem
  sensitive   = true
}
