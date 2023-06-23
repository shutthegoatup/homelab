terraform {
  cloud {
    organization = "shutthegoatup"
    workspaces {
      tags = ["cicd"]
    }
  }
}
