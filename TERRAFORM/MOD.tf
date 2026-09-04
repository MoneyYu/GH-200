## LAB-NETWORK
resource "azurerm_virtual_network" "lab" {
  name                = "${local.lab_name}-vnet-${local.resource_suffix}"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.default_tags
}

## LAB-WEB-APP
resource "azurerm_service_plan" "lab" {
  name                = "${local.lab_name}-app-plan-${local.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "S1"

  tags = local.default_tags
}

resource "azurerm_linux_web_app" "lab" {
  name                                           = "gh200-java-web-${local.resource_suffix}"
  location                                       = azurerm_resource_group.rg.location
  resource_group_name                            = azurerm_resource_group.rg.name
  service_plan_id                                = azurerm_service_plan.lab.id
  https_only                                     = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  site_config {
    application_stack {
      java_version        = "21"
      java_server         = "JAVA"
      java_server_version = "21"
    }
  }

  # Managed test-environment marker so the PaaS/OIDC contrast reports
  # environment: test instead of the misleading default "local". This is the
  # only managed app setting; runtime, site config, and lifecycle are unchanged.
  app_settings = {
    APP_ENVIRONMENT = "test"
  }

  tags = local.default_tags
}

## LAB-LINUX-VM
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

  # The two app environments are public for classroom verification. SSH stays
  # limited to AzureCloud; broader Internet SSH is a short-lived trainer action.
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

  security_rule {
    name                       = "AllowSshFromAzureCloud"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "AzureCloud"
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
    public_key = var.linux_ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    name                 = "${local.lab_name}-linux-osdisk-${local.resource_suffix}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = local.default_tags

  lifecycle {
    # Both are create-time settings on an existing classroom VM; changing either would replace it.
    ignore_changes = [admin_ssh_key, custom_data]
  }
}

resource "azurerm_virtual_machine_extension" "linux_runner" {
  name                       = "${local.lab_name}-linux-runner-${local.resource_suffix}"
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_linux_virtual_machine.lab.id

  settings = jsonencode({
    # Normalize CRLF to LF so Azure Linux Custom Script does not fail in /bin/sh.
    commandToExecute = replace(<<-EOT
      set -e
      RUNNER_VERSION="2.337.0"
      RUNNER_DIR="/opt/actions-runner"
      RUNNER_ARCHIVE="actions-runner-linux-x64-$RUNNER_VERSION.tar.gz"
      RUNNER_URL="https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/$RUNNER_ARCHIVE"
      RUNNER_SHA256="70920811a4f8ad4328818682bca5c6469c1c942fab52448868071d0063816613"
      install -d -m 0755 "$RUNNER_DIR"
      cd "$RUNNER_DIR"
      if [ ! -f ".runner-version-$RUNNER_VERSION" ]; then
        curl -fsSL -o "$RUNNER_ARCHIVE" "$RUNNER_URL"
        echo "$RUNNER_SHA256  $RUNNER_ARCHIVE" | sha256sum -c -
        tar -xzf "$RUNNER_ARCHIVE"
        rm -f "$RUNNER_ARCHIVE"
        touch ".runner-version-$RUNNER_VERSION"
      fi
      chown -R ${local.linux_admin}:${local.linux_admin} "$RUNNER_DIR"
    EOT
    , "\r\n", "\n")
  })

  tags = local.default_tags
}
