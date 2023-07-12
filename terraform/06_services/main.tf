module "downloads" {
  source = "../modules/downloads"
}

module "jellyfin" {
  source = "../modules/jellyfin"
}

module "sonarr" {
  source = "../modules/sonarr"
}

module "radarr" {
  source = "../modules/radarr"
}

module "sabnzbd" {
  source = "../modules/sabnzbd"
}

module "backstage" {
  source = "../modules/backstage"
}
