variable "integrations" {
  type = list(object({
    arn = string
    route = string
  }))
}