build {
  hcp_packer_registry {
    bucket_name = "learn-packer-ubuntu"
    description = "Description about the image being published."

    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "Ubuntu",
      "ubuntu-version" = "Focal 20.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  sources = [
    "source.amazon-ebs.basic-example-east",
    "source.amazon-ebs.basic-example-west"
  ]
}