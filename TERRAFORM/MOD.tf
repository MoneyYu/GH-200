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

  lifecycle {
    # The shared subscription injects FirstPartyUsage and zone metadata.
    ignore_changes = [ip_tags, zones]
  }
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
    storage_account_type = "Standard_LRS"
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
  name                                           = "gh200-web-${local.resource_suffix}"
  location                                       = azurerm_resource_group.rg.location
  resource_group_name                            = azurerm_resource_group.rg.name
  service_plan_id                                = azurerm_service_plan.lab.id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  site_config {
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
  }

  tags = local.default_tags
}

## LAB-LINUX-VM
resource "tls_private_key" "linux" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_subnet" "linux" {
  name                 = "${local.lab_name}-linux-subnet-${local.resource_suffix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_network_security_group" "linux" {
  name                = "${local.lab_name}-linux-nsg-${local.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # The two app environments are public for classroom verification. The shared
  # subscription removes persistent Internet SSH rules; the trainer opens port
  # 22 only immediately before the optional SSH comparison and removes it after.
  security_rule {
    name                       = "AllowTestAppFromInternet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowProductionAppFromInternet"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = local.default_tags
}

resource "azurerm_subnet_network_security_group_association" "linux" {
  subnet_id                 = azurerm_subnet.linux.id
  network_security_group_id = azurerm_network_security_group.linux.id

  lifecycle {
    # Azure sometimes returns the resource group segment with different casing,
    # which otherwise creates a false ForceNew diff for the same subnet ID.
    ignore_changes = [subnet_id]
  }
}

resource "azurerm_public_ip" "linux" {
  name                = "${local.lab_name}-linux-pip-${local.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.default_tags

  lifecycle {
    # The shared subscription injects FirstPartyUsage and zone metadata.
    ignore_changes = [ip_tags, zones]
  }
}

resource "azurerm_network_interface" "linux" {
  name                = "${local.lab_name}-linux-nic-${local.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${local.lab_name}-linux-ipconfig-${local.resource_suffix}"
    subnet_id                     = azurerm_subnet.linux.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux.id
  }

  tags = local.default_tags
}

resource "azurerm_linux_virtual_machine" "lab" {
  name                            = "${local.lab_name}-linux-${local.resource_suffix}"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.linux.id]
  size                            = local.linux_vm_size
  admin_username                  = local.linux_admin
  disable_password_authentication = true
  custom_data                     = base64encode(file("${path.module}/cloud-init-java.yaml"))

  admin_ssh_key {
    username   = local.linux_admin
    public_key = tls_private_key.linux.public_key_openssh
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${local.lab_name}-linux-osdisk-${local.resource_suffix}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = local.default_tags
}