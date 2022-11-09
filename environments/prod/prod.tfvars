cft_sandbox_subscriptions = {
  DCD-CFT-Sandbox = {
    environment = "sbox"
    deploy_acme = true
  }
  DCD-CFTAPPS-SBOX = {
    deploy_acme = true
  }
  DCD-ROBOTICS-SBOX = {}
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
  }
  DCD-CNP-QA = {
    deploy_acme = true
    environment = "test"
  }
}
cft_production_subscriptions = {
  DCD-CFTAPPS-PROD = {
    deploy_acme = true
  }
  DCD-CFTAPPS-STG = {
    deploy_acme = true
  }
  DCD-CNP-Prod = {
    deploy_acme = true
  }
  DTS-CFTPTL-INTSVC = {
    deploy_acme = true
    environment = "ptl"
  }
  DTS-CFTSBOX-INTSVC = {
    deploy_acme = true
    environment = "sbox"
  }
  Reform-CFT-MI-SB = {
    environment = "sbox"
  }
}

sds_sandbox_subscriptions = {
  DTS-SHAREDSERVICES-SBOX = {
    deploy_acme = true
  }
  DCD-MI-SBOX = {}
}
sds_non_production_subscriptions = {
  DTS-SHAREDSERVICES-DEMO = {
    deploy_acme = true
  }
  DTS-SHAREDSERVICES-DEV = {
    deploy_acme = true
  }
  DTS-SHAREDSERVICES-ITHC = {
    deploy_acme = true
  }
  DTS-SHAREDSERVICES-TEST = {
    deploy_acme = true
  }
  DTS-SHAREDSERVICES-SBOX = {
    deploy_acme = true
  }
  Reform-CFT-VH-Dev = {
    deploy_acme = true
    environment = "dev"
  }
}
sds_production_subscriptions = {
  DTS-SHAREDSERVICES-STG = {
    deploy_acme = true
  }
  DTS-SHAREDSERVICES-PROD = {
    deploy_acme = true
  }
  DCD-AWS-Migration = {
    environment = "prod"
  }
  DCD-CFT-VH-Pilot = {
    deploy_acme = true
    environment = "prod"
  }
  DTS-SHAREDSERVICESPTL = {
    deploy_acme = true
    environment = "ptl"
  }
  DTS-SHAREDSERVICESPTL-SBOX = {
    deploy_acme = true
    environment = "ptlsbox"
  }
}

crime_subscriptions = {
  "MoJ Common Platform Online Plea Production" = {
    environment = "prod"
  }
  "MoJ Common Platform Production" = {
    environment = "prod"
  }
  "MoJ Common Platform Security Operations" = {
    environment = "prod"
  }
  "MOJ DCD Atlassian LVE" = {
    environment = "prod"
  }
  "MoJ Operational Services Validation" = {
    environment = "prod"
  }
}

heritage_sandbox_subscriptions = {}
heritage_non_production_subscriptions = {
  DTS-HERITAGE-EXTSVC-STG = {
    environment = "stg"
  }
  DTS-HERITAGE-INTSVC-STG = {
    environment = "stg"
  }
}
heritage_production_subscriptions = {
  DTS-HERITAGE-EXTSVC-PROD = {
    environment = "prod"
  }
  DTS-HERITAGE-INTSVC-PROD = {
    environment = "prod"
  }
  DTS-ARCHIVING-PROD = {
    environment = "prod"
    product     = "heritage"
  }
}

security_subscriptions = {
  HMCTS-SOC-SBOX = {
    deploy_acme = true
  }
  HMCTS-SOC-PROD = {
    deploy_acme = true
  }
}

platform_sandbox_subscriptions = {
  DTS-MANAGEMENT-SBOX = {
    product = "mgmt"
  }
  DTS-MANAGEMENT-SBOX-INTSVC = {
    environment = "sbox"
    product     = "mgmt"
  }
  HMCTS-HUB-SBOX = {
    deploy_acme = true
    product     = "hub"
  }
  HMCTS-HUB-SBOX-INTSVC = {
    environment = "sbox"
    deploy_acme = true
    product     = "hub"
  }
  DTS-DACS-SBOX = {
    product = "enterprise"
  }
}
platform_non_production_subscriptions = {
  DTS-MANAGEMENT-TEST = {
    product = "mgmt"
  }
  DTS-MANAGEMENT-NONPROD-INTSVC = {
    environment = "stg"
    product     = "mgmt"
  }
  HMCTS-HUB-DEV = {
    deploy_acme = true
    product     = "hub"
  }
  HMCTS-HUB-NONPROD-INTSVC = {
    environment = "stg"
    product     = "hub"
  }
  HMCTS-HUB-TEST = {
    deploy_acme = true
    product     = "hub"
  }
}
platform_production_subscriptions = {
  HMCTS-CONTROL = {
    environment      = "prod"
    product          = "enterprise"
    replication_type = "RAGRS"
  }
  DTS-MANAGEMENT-PROD-INTSVC = {
    environment = "prod"
    product     = "mgmt"
  }
  HMCTS-HUB-PROD-INTSVC = {
    environment = "prod"
    deploy_acme = true
    product     = "hub"
  }
  Reform-CFT-Mgmt = {
    environment = "mgmt"
    product     = "mgmt"
  }
  DCD-RDO-Production = {
    environment = "prod"
    product     = "mgmt"
  }
  "Access to Azure Active Directory" = {
    environment = "prod"
    product     = "mgmt"
  }
}

vh_subscriptions = {
  DTS-VH-PROD = {}
}

enrollment_account_name = "233705"

add_service_connection_to_ado = true
