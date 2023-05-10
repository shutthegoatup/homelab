terraform {
  cloud {
    organization = "shutthegoatup"
    workspaces {
      tags = ["static"]
    }
  }
}
