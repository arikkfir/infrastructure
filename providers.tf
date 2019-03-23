provider "archive" {
  version = "~> 1.1.0"
}

provider "cloudflare" {
  version = "~> 1.11.0"
  email   = "${var.cloudflare_email}"
  token   = "${var.cloudflare_token}"
}

provider "google" {
  version = "~> 2.0.0"
}

provider "google-beta" {
  version = "~> 2.0.0"
}

provider "local" {
  version = "~> 1.1.0"
}

provider "template" {
  version = "~> 2.1.0"
}
