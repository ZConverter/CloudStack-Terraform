variable "generate" {
  type = object({
    cloud_platform = string
    auth = object({
      api_url = string
      api_key = string
      secret_key = string
    })
    vm_info = object({
      vm_name = string
      project = string
      affinity_group_names = list(string)
      service_offering = string
      root_disk_size = number
      network_id = string
      security_group_names = list(string)
      template = string
      zone = string
    })
  })
  default = {
    auth = {
      api_url = null
      api_key = null
      secret_key = null
    }
    cloud_platform = "cloudstack"
    vm_info = {
      vm_name = null
      project = null
      affinity_group_names = null
      service_offering = null
      root_disk_size = null
      network_id = null
      security_group_names = null
      template = null
      zone = null
    }
  }
}
