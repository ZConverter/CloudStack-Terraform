variable "generate" {
  type = object({
    cloud_platform = string
    auth = object({
      api_url    = string
      api_key    = string
      secret_key = string
    })
    vm_info = object({
      vm_name              = string
      project              = optional(string,null)
      affinity_group_names = optional(list(string),null)
      service_offering     = string
      root_disk_size       = optional(number,20)
      network_id           = optional(string,null)
      security_group_names = optional(list(string),["default"])
      template             = string
      zone                 = string
      ip_address           = optional(string,null)
      volume               = optional(list(number),[])
      user_data_file_path  = optional(string,null)
      create_security_group = optional(object({
        ingress = optional(list(object({
          cidr = optional(string)
          protocol = optional(string)
          port = optional(string)
        })))
        egress = optional(list(object({
          cidr = optional(string)
          protocol = optional(string)
          port = optional(string)
        })))
      }),{
        ingress = [
          {
            cidr = "0.0.0.0/0"
            port = "80"
            protocol = "tcp"
          },
          {
            cidr = "0.0.0.0/0"
            port = "443"
            protocol = "tcp"
          },
          {
            cidr = "0.0.0.0/0"
            port = "8080"
            protocol = "tcp"
          }
        ]
      })
    })
  })
  default = {
    auth = {
      api_key = null
      api_url = null
      secret_key = null
    }
    cloud_platform = null
    vm_info = {
      affinity_group_names = []
      network_id = null
      project = null
      root_disk_size = 20
      security_group_names = ["default"]
      service_offering = null
      template = null
      vm_name = null
      zone = null
    }
  }
}
