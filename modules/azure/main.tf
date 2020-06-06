data "azuread_client_config" "current" {}
data "azuread_service_principal" "master_app" {
  application_id = data.azuread_client_config.current.client_id
}

data "azuread_users" "additional_owners" {
  user_principal_names = var.additional_owners
}

resource "azuread_group" "super_user" {
  name    = "superusers"
  owners  = [data.azuread_service_principal.master_app.object_id]
  members = data.azuread_users.additional_owners.object_ids
}

resource "azuread_application" "homelab" {
  name                    = "homelab"
  owners                  = concat(data.azuread_users.additional_owners.object_ids, [data.azuread_service_principal.master_app.object_id])
  group_membership_claims = "SecurityGroup"

  reply_urls = var.homelab_redirect_uris

  app_role {
    allowed_member_types = [
      "User",
    ]
    description  = "Used as roles or groups on downstream apps"
    display_name = "superusers"
    is_enabled   = true
    value        = "superusers"
  }
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
  type                       = "webapp/api"

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
  description           = "concourse 10 day"
  value                 = random_password.concourse_password.result
  end_date_relative     = "240h"
  depends_on            = [random_password.concourse_password]
}

resource "azuread_application_password" "vault" {
  application_object_id = azuread_application.homelab.id
  description           = "vault 10 day"
  value                 = random_password.concourse_password.result
  end_date_relative     = "240h"
  depends_on            = [random_password.vault_password]
}

resource "random_password" "concourse_password" {
  length  = 32
  special = true
}

resource "random_password" "vault_password" {
  length  = 32
  special = true
}
