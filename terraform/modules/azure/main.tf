data "azuread_client_config" "current" {}

data "azuread_service_principal" "master_app" {
  application_id = data.azuread_client_config.current.client_id
}

data "azuread_users" "additional_owners" {
  user_principal_names = var.additional_owners
}

resource "azuread_group" "super_user" {
  display_name     = "superusers"
  owners           = [data.azuread_service_principal.master_app.object_id]
  members          = data.azuread_users.additional_owners.object_ids
  security_enabled = true
}

resource "azuread_application" "homelab" {
  display_name            = "homelab"
  owners                  = concat(data.azuread_users.additional_owners.object_ids, [data.azuread_service_principal.master_app.object_id])
  group_membership_claims = ["SecurityGroup"]

  app_role {
    id = "72c6e997-67aa-4724-b574-9f2cb40f2a53"
    allowed_member_types = [
      "User",
    ]
    description  = "Used as roles or groups on downstream apps"
    display_name = "superusers"
    value        = "superusers"
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "homelab" {
  application_id               = azuread_application.homelab.application_id
  app_role_assignment_required = false
}

resource "azuread_application_password" "concourse" {
  application_object_id = azuread_application.homelab.id
  end_date_relative     = "240h"
}

resource "azuread_application_password" "vault" {
  application_object_id = azuread_application.homelab.id
  end_date_relative     = "240h"
}

resource "random_password" "concourse_password" {
  length  = 32
  special = true
}

resource "random_password" "vault_password" {
  length  = 32
  special = true
}
