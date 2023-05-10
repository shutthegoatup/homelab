terraform {
  cloud {
    organization = "shutthegoatup"
    workspaces {
      tags = ["bootstrap"]
    }
  }
}
