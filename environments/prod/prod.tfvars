cft_sandbox_subscriptions = {
  DCD-CFT-Sandbox = {
    environment = "sbox"
    deploy_acme = true
  }
  DCD-CFTAPPS-SBOX = {
    deploy_acme = true
  }
}
cft_non_production_subscriptions = {
  DCD-CFTAPPS-DEMO = {
    deploy_acme = true
  }
  DCD-CFTAPPS-DEV = {
    deploy_acme = true
  }
  DCD-CFTAPPS-ITHC = {
    deploy_acme = true
  }
  DCD-CFTAPPS-TEST = {
    deploy_acme = true
  }
  DCD-CFTAPPSDATA-DEMO = {
    deploy_acme = true
  }
  DCD-CFT-Idam-Dev = {
    deploy_acme = true
    environment = "dev"
  }
  DCD-CNP-DEV = {
    deploy_acme = true
    environment = "stg"
  }
  DCD-CNP-QA = {
    deploy_acme = true
    environment = "test"
  }
}
cft_production_subscriptions = {}

sds_sandbox_subscriptions        = {}
sds_non_production_subscriptions = {}
sds_production_subscriptions     = {}

crime_subscriptions = {}

heritage_sandbox_subscriptions        = {}
heritage_non_production_subscriptions = {}
heritage_production_subscriptions     = {}

security_subscriptions = {}

platform_sandbox_subscriptions        = {}
platform_non_production_subscriptions = {}
platform_production_subscriptions     = {}

vh_subscriptions = {
  DTS-VH-PROD = {}
}

enrollment_account_name = "233705"

add_service_connection_to_ado = true
