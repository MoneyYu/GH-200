## LAB-VM
resource "azurerm_virtual_network" "lab" {
  name                = "${local.lab_name}-vnet-${local.resource_suffix}"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.default_tags
}

resource "azurerm_subnet" "lab" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_public_ip" "lab" {
  name                = "${local.lab_name}-pip-${local.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.default_tags
}

resource "azurerm_network_interface" "lab" {
  name                = "${local.lab_name}-nic-${local.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.lab_name}-nic-ipconfig-${local.resource_suffix}"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab.id
  }

  tags = local.default_tags
}

resource "azurerm_windows_virtual_machine" "lab" {
  name                  = "${local.lab_name}-vm-${local.resource_suffix}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.lab.id]
  size                  = local.vm_size

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${local.lab_name}-osdisk-${local.resource_suffix}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  computer_name  = "labvm-${substr(var.group_postfix, 0, 4)}-${local.random_str}"
  admin_username = var.user_name
  admin_password = var.user_password

  tags = local.default_tags
}

resource "azurerm_virtual_machine_extension" "labaad" {
  name                       = "${local.lab_name}-aad-${local.resource_suffix}"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.lab.id

  tags = local.default_tags
}

resource "azurerm_virtual_machine_extension" "labscript" {
  name                       = "${local.lab_name}-script-${local.resource_suffix}"
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.lab.id

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item 'C:\\inetpub\\wwwroot\\iisstart.htm' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)"
    }
  SETTINGS

  tags = local.default_tags
}

## LAB-WEB-APP
resource "azurerm_service_plan" "lab" {
  name                = "${local.lab_name}-app-plan-${local.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "S1"

  tags = local.default_tags
}

resource "azurerm_windows_web_app" "lab" {
  name                = "gh200-web-${local.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.lab.id

  site_config {
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
  }

  tags = local.default_tags
}