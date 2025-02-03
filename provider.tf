
provider "google" {
  project     = var.projectId
  region      = var.region
  credentials = file("creds.json")
}

