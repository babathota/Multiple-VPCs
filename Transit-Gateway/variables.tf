variable "region" {
  default = "us-east-1"
}

variable "vpc_configs" {
  type = map(object({
    cidr            = string
    public_subnets  = list(string)
    private_subnets = list(string)
    tgw_subnets = list(string)

  }))
  default = {
    "VPC-A" = {
      cidr            = "10.1.0.0/16"
      public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
      private_subnets = ["10.1.10.0/24", "10.1.11.0/24"]

      tgw_subnets     = ["10.1.15.0/28", "10.1.15.16/28"]
    }
    "VPC-B" = {
      cidr            = "10.2.0.0/16"
      public_subnets  = ["10.2.1.0/24", "10.2.2.0/24"]
      private_subnets = ["10.2.10.0/24", "10.2.11.0/24"]

      tgw_subnets     = ["10.2.15.0/28", "10.2.15.16/28"]
    }
    "VPC-C" = {
      cidr            = "10.3.0.0/16"
      public_subnets  = ["10.3.1.0/24", "10.3.2.0/24"]
      private_subnets = ["10.3.10.0/24", "10.3.11.0/24"]

      tgw_subnets     = ["10.3.15.0/28", "10.3.15.16/28"]
    }
  }
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}