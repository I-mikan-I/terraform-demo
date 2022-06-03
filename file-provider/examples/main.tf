terraform {
  required_providers {
    filesystem = {
      version = "0.1.0"
      source  = "example.org/edu/filesystem"
    }
  }
}

resource "filesystem_file" "file" {
  path = "${path.module}/resource-file2"
  data = "Hello, World"
}