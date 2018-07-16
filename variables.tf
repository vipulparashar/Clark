#
# Variables Configuration
#

variable "cluster-name" {
  default = "eks-clark-clu"
  type    = "string"
}

variable "local-workstation" {
  default = ["x.x.x.x/32","x.x.x.x/32"]
  type = "list"
}

