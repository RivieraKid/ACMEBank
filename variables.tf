variable region {
    default    = "eu-west-2"
    description = "AWS region to deploy resources into"
}

variable "app_name" {
    default = "ACMEBankInterestCalculator"
}

variable "bank_name" {
    default = "ACMEBank"
}

variable "apigateway_name" {
    default = "ACMEBankApiGateway"
}
