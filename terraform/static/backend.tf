terraform {
  cloud {
    organization = "shutthegoatup"

    workspaces {
      name = "static"
    }
  }
}
