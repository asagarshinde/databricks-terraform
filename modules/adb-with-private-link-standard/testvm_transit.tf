# resource "random_string" "password" {
#   special = false
#   upper   = true
#   length  = 8
# }

# resource "azurerm_network_interface" "testvmnic" {
#   name                = "${local.prefix}-testvm-nic"
#   location            = azurerm_resource_group.transit_rg.location
#   resource_group_name = azurerm_resource_group.transit_rg.name

#   ip_configuration {
#     name                          = "testvmip"
#     subnet_id                     = azurerm_subnet.testvmsubnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.testvmpublicip.id
#   }
# }

# resource "azurerm_network_security_group" "testvm-nsg" {
#   name                = "${local.prefix}-testvm-nsg"
#   location            = azurerm_resource_group.transit_rg.location
#   resource_group_name = azurerm_resource_group.transit_rg.name
#   tags                = local.tags
# }

# resource "azurerm_network_interface_security_group_association" "testvmnsgassoc" {
#   network_interface_id      = azurerm_network_interface.testvmnic.id
#   network_security_group_id = azurerm_network_security_group.testvm-nsg.id
# }

# data "http" "my_public_ip" { // add your host machine ip into nsg
#   url = "https://ipinfo.io"
# }

# locals {
#   ifconfig_co_json = jsondecode(data.http.my_public_ip.response_body)
# }

# output "my_ip_addr" {
#   value = local.ifconfig_co_json.ip
# }

# resource "azurerm_network_security_rule" "test0" {
#   name                        = "RDP"
#   priority                    = 200
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "3389"
#   source_address_prefixes     = [local.ifconfig_co_json.ip]
#   destination_address_prefix  = azurerm_public_ip.testvmpublicip.ip_address
#   network_security_group_name = azurerm_network_security_group.testvm-nsg.name
#   resource_group_name         = azurerm_resource_group.transit_rg.name
# }

# resource "azurerm_public_ip" "testvmpublicip" {
#   name                = "${local.prefix}-vmpublicip"
#   location            = azurerm_resource_group.transit_rg.location
#   resource_group_name = azurerm_resource_group.transit_rg.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_windows_virtual_machine" "testvm" {
#   name                = "${local.prefix}vm"
#   resource_group_name = azurerm_resource_group.transit_rg.name
#   location            = azurerm_resource_group.transit_rg.location
#   size                = "Standard_F4s_v2"
#   admin_username      = "azureuser"
#   admin_password      = "T${random_string.password.result}!!"
#   network_interface_ids = [
#     azurerm_network_interface.testvmnic.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsDesktop"
#     offer     = "windows-10"
#     sku       = "19h2-pro-g2"
#     version   = "latest"
#   }
# }

# resource "azurerm_subnet" "testvmsubnet" {
#   name                 = "${local.prefix}-testvmsubnet"
#   resource_group_name  = azurerm_resource_group.transit_rg.name
#   virtual_network_name = azurerm_virtual_network.transit_vnet.name
#   address_prefixes     = [cidrsubnet(var.cidr_transit, 3, 3)]
# }



resource "random_string" "password" {
  special = false
  upper   = true
  length  = 8
}

resource "azurerm_network_interface" "testvmnic" {
  name                = "${local.prefix}-testvm-nic"
  location            = azurerm_resource_group.transit_rg.location
  resource_group_name = azurerm_resource_group.transit_rg.name

  ip_configuration {
    name                          = "testvmip"
    subnet_id                     = azurerm_subnet.testvmsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testvmpublicip.id
  }
}

resource "azurerm_network_security_group" "testvm-nsg" {
  name                = "${local.prefix}-testvm-nsg"
  location            = azurerm_resource_group.transit_rg.location
  resource_group_name = azurerm_resource_group.transit_rg.name
  tags                = local.tags
}

resource "azurerm_network_interface_security_group_association" "testvmnsgassoc" {
  network_interface_id      = azurerm_network_interface.testvmnic.id
  network_security_group_id = azurerm_network_security_group.testvm-nsg.id
}

data "http" "my_public_ip" { // Capture host machine IP to allow SSH
  url = "https://ipinfo.io"
}

locals {
  ifconfig_co_json = jsondecode(data.http.my_public_ip.response_body)
}

output "my_ip_addr" {
  value = local.ifconfig_co_json.ip
}

# Update Network Security Group to allow SSH instead of RDP
resource "azurerm_network_security_rule" "test0" {
  name                        = "SSH"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = [local.ifconfig_co_json.ip]
  destination_address_prefix  = azurerm_public_ip.testvmpublicip.ip_address
  network_security_group_name = azurerm_network_security_group.testvm-nsg.name
  resource_group_name         = azurerm_resource_group.transit_rg.name
}

resource "azurerm_public_ip" "testvmpublicip" {
  name                = "${local.prefix}-vmpublicip"
  location            = azurerm_resource_group.transit_rg.location
  resource_group_name = azurerm_resource_group.transit_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Deploy CentOS 8-based Virtual Machine
resource "azurerm_linux_virtual_machine" "testvm" {
  name                = "${local.prefix}vm"
  resource_group_name = azurerm_resource_group.transit_rg.name
  location            = azurerm_resource_group.transit_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "T${random_string.password.result}!!"
  disable_password_authentication = false  # Enable password-based login

  network_interface_ids = [
    azurerm_network_interface.testvmnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Use a CentOS 8 image from Azure Marketplace
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_4"
    version   = "latest"
  }

  # Cloud-init to enable password login for SSH
  custom_data = base64encode(<<EOF
#cloud-config
password: T${random_string.password.result}!!
chpasswd: { expire: False }
ssh_pwauth: True
EOF
  )
}

resource "azurerm_subnet" "testvmsubnet" {
  name                 = "${local.prefix}-testvmsubnet"
  resource_group_name  = azurerm_resource_group.transit_rg.name
  virtual_network_name = azurerm_virtual_network.transit_vnet.name
  address_prefixes     = [cidrsubnet(var.cidr_transit, 3, 3)]
}
