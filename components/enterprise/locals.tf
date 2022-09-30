locals {
  cft                = { for k, v in var.cft_subscriptions : k => merge(tomap({ group = "cft" }), v) }
  cft_sandbox        = { for k, v in var.cft_sandbox_subscriptions : k => merge(tomap({ group = "cft_sandbox" }), v) }
  cft_non_production = { for k, v in var.cft_non_production_subscriptions : k => merge(tomap({ group = "cft_non_production" }), v) }
  cft_production     = { for k, v in var.cft_production_subscriptions : k => merge(tomap({ group = "cft_production" }), v) }

  sds                = { for k, v in var.sds_subscriptions : k => merge(tomap({ group = "sds" }), v) }
  sds_sandbox        = { for k, v in var.sds_sandbox_subscriptions : k => merge(tomap({ group = "sds_sandbox" }), v) }
  sds_non_production = { for k, v in var.sds_non_production_subscriptions : k => merge(tomap({ group = "sds_non_production" }), v) }
  sds_production     = { for k, v in var.sds_production_subscriptions : k => merge(tomap({ group = "sds_production" }), v) }

  crime = { for k, v in var.crime_subscriptions : k => merge(tomap({ group = "crime" }), v) }

  heritage                = { for k, v in var.heritage_subscriptions : k => merge(tomap({ group = "heritage" }), v) }
  heritage_sandbox        = { for k, v in var.heritage_sandbox_subscriptions : k => merge(tomap({ group = "heritage_sandbox" }), v) }
  heritage_non_production = { for k, v in var.heritage_non_production_subscriptions : k => merge(tomap({ group = "heritage_non_production" }), v) }
  heritage_production     = { for k, v in var.heritage_production_subscriptions : k => merge(tomap({ group = "heritage_production" }), v) }

  security = { for k, v in var.security_subscriptions : k => merge(tomap({ group = "security" }), v) }

  platform                = { for k, v in var.platform_subscriptions : k => merge(tomap({ group = "platform" }), v) }
  platform_sandbox        = { for k, v in var.platform_sandbox_subscriptions : k => merge(tomap({ group = "platform_sandbox" }), v) }
  platform_non_production = { for k, v in var.platform_non_production_subscriptions : k => merge(tomap({ group = "platform_non_production" }), v) }
  platform_production     = { for k, v in var.platform_production_subscriptions : k => merge(tomap({ group = "platform_production" }), v) }

  subscriptions = merge(
    local.cft,
    local.cft_sandbox,
    local.cft_non_production,
    local.cft_production,

    local.sds,
    local.sds_sandbox,
    local.sds_non_production,
    local.sds_production,

    local.crime,

    local.heritage,
    local.heritage_sandbox,
    local.heritage_non_production,
    local.heritage_production,

    local.security,

    local.platform,
    local.platform_sandbox,
    local.platform_non_production,
    local.platform_production,
  )

  environments = {
    demo = {}
    dev  = {}
    ithc = {}
    ptl = {
      display_name_prefix = "DTS-SHAREDSERVICESPTL"
    }
    ptlsbox = {
      display_name_prefix = "DTS-SHAREDSERVICESPTL-SBOX"
    }
    prod = {}
    sbox = {}
    stg  = {}
    test = {}
  }

  regex_last_section_hyphen      = "/.*-([A-Za-z]+).*/" # extracts the last section of a string after any hyphens (-) e.g. extracts `SBOX` from `DTS-RBAC-SBOX`
  regex_string                   = "/([A-Za-z]).*/"     # used to replace string with another string e.g. replacing `security` with `soc`
  regex_first_section_underscore = "/([A-Za-z])_.*/"    # extracts the first section of a string before any underscores (_) e.g. extracting `cft` from `cft_production_subscriptions`

  groups = {
    "Contributor" = {
      name        = "DTS Contributors (sub:)"
      description = "Grants contributor permissions to the subscription"
      members     = ["Bla1", "Bla2", "Bla3"]
    }
    }
}
