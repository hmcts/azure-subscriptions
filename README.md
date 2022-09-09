# Azure Enterprise

Inspired by [Azure/terraform-azurerm-caf-enterprise-scale](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale).
Simplified for our use-cases / retrofitting.

```mermaid
graph TD
    Root --> HMCTS(HMCTS Programmes)
    HMCTS --> CFT
    HMCTS --> SDS
    HMCTS --> Crime
    HMCTS --> Heritage
    HMCTS --> Security
    HMCTS --> Platform
    CFT --> CFT-Sandbox
    CFT --> CFT-NonProd
    CFT --> CFT-Prod

    SDS --> SDS-Sandbox
    SDS --> SDS-NonProd
    SDS --> SDS-Prod

    Heritage --> Heritage-Sandbox
    Heritage --> Heritage-NonProd
    Heritage --> Heritage-Prod

    Platform --> Platform-Sandbox
    Platform --> Platform-NonProd
    Platform --> Platform-Prod
```

## New subscription

### Naming the subscription

First you will need to decide on a name for the new subscription you want.

The format is `${department}-${service}-${environment}`

Department is normally `DTS`
For all of HMCTS e.g. CFT, Crime, SDS, then use `HMCTS`.

Service is a short name that normally maps to the project or group of projects.
e.g. BAR (banking and returns) or CFT, (Civil, Family and Tribunals group of projects).

Environment is one of the allowed environments names:
- SBOX (Sandbox)
- TEST
- ITHC (IT healthcheck)
- DEMO
- STG (Staging)
- PROD

Example subscription names:
- DTS-CFTAPPS-PROD
- HMCTS-HUB-PROD
- DTS-DOCMOSIS-PROD

### Creating the subscription

Request approval for a new subscription by emailing "DTS Platform Operations"

Once approved create a pull request adding the required subscriptions.

1. Modify the file [prod.tfvars](https://github.com/hmcts/azure-enterprise/blob/main/environments/prod/prod.tfvars) with the subscription name.
   * add it into the corresponding management group e.g. for a new heritage production subscription add it to the `heritage_production_subscriptions` variable.
   ```
   heritage_production_subscriptions = {
    DTS-HERITAGE-STG = {
    }
   }
   ```
  
The environment is required to bootstrap the subscription. Most subscriptions have the environment name in the subscription name e.g. DTS-SHAREDSERVICES-DEV. The environment will be extracted automatically where this naming convention is followed. If a subscription does not follow this naming convention, then you must specify the environment in the tfvars file.

   ```
   heritage_production_subscriptions = {
    DTS-HERITAGE-STG-NEWSUB = {
      environment = "stg"
    }
   }
   ```

Create a 'help request' in the [#platops-help](https://hmcts-reform.slack.com/app_redirect?channel=platops-help) Slack channel if you have any questions.

## Adding a new management group

1. Add the required management variables to [variables.tf](https://github.com/hmcts/azure-enterprise/blob/main/components/enterprise/variables.tf)
   * for a new Constoso group, copy an existing `_subscriptions` variable and name it `contoso_subscriptions`
2. Add a variable override to [prod.tfvars](https://github.com/hmcts/azure-enterprise/blob/main/environments/prod/prod.tfvars) this will be used for all the subscriptions in the management group
   * an empty group would be `contoso_subscriptions = {}`
3. Add your new management group to [enterprise.tf](https://github.com/hmcts/azure-enterprise/blob/main/components/enterprise/enterprise.tf)
4. Ensure you update the `subscription.group` field to a key that represents your management group, e.g. `crime_non_production`
5. Add your new management group to [subscriptions.tf](https://github.com/hmcts/azure-enterprise/blob/main/components/enterprise/subscriptions.tf)
   - make sure you add a new `local` variable for the management group and modify the `local.subscriptions` variable to add the new local you created
6. Update the mermaid diagram in this file to include the new management group

<!-- TODO update this when we get a better example that's just doing what is required --> 
[Example pull request](https://github.com/hmcts/azure-enterprise/pull/11)

## Renaming a subscription

In [prod.tfvars](https://github.com/hmcts/azure-enterprise/blob/main/environments/prod/prod.tfvars) your subscription will look something like:

```terraform
cft_non_production_subscriptions = {
  DCD-CFTAPPS-DEV = {
  }
}
```

Modify it to include a `display_name` property:

```diff
diff --git a/environments/prod/prod.tfvars b/environments/prod/prod.tfvars
index 9b27139..4a8f1c0 100644
--- a/environments/prod/prod.tfvars
+++ b/environments/prod/prod.tfvars
@@ -9,7 +9,9 @@ cft_production_subscriptions = {
 cft_non_production_subscriptions = {
-  DCD-CFTAPPS-DEV  = {}
+  DTS-CFTAPPS-DEV  = {
+    display_name = "DTS-CFTAPPS-DEV"
+  }
```

The terraform plan will then only show a subscription name change, and it will be updated in-place:

```hcl
Terraform will perform the following actions:

  # module.subscription["DCD-CFTAPPS-DEV"].azurerm_subscription.this will be updated in-place
  ~ resource "azurerm_subscription" "this" {
        id                = "/providers/Microsoft.Subscription/aliases/DCD-CFTAPPS-DEV"
      ~ subscription_name = "DCD-CFTAPPS-DEV" -> "DTS-CFTAPPS-DEV"
        tags              = {}
        # (4 unchanged attributes hidden)
    }
```

## Moving a subscription to a different 'Management group'

Subscriptions can be easily moved to different management groups by moving it between variables in [prod.tfvars](https://github.com/hmcts/azure-enterprise/blob/main/environments/prod/prod.tfvars).

```diff
diff --git a/environments/prod/prod.tfvars b/environments/prod/prod.tfvars
index 9b27139..8affa55 100644
--- a/environments/prod/prod.tfvars
+++ b/environments/prod/prod.tfvars
@@ -4,12 +4,12 @@ cft_sandbox_subscriptions = {

 cft_production_subscriptions = {
+  DTS-CFTAPPS-STG  = {
}
 }

 cft_non_production_subscriptions = {
-  DTS-CFTAPPS-STG  = {
}
 }
```

The terraform plan will then only show a change to the management group:

```hcl
Terraform will perform the following actions:

  # module.enterprise.azurerm_management_group.level_3["CFT-NonProd"] will be updated in-place
  ~ resource "azurerm_management_group" "level_3" {
        id                         = "/providers/Microsoft.Management/managementGroups/CFT-NonProd"
        name                       = "CFT-NonProd"
      ~ subscription_ids           = [
          - "06069648-d13b-4c3c-9367-f3a1ed8e38bc",
            # (2 unchanged elements hidden)
        ]
        # (2 unchanged attributes hidden)
    }

  # module.enterprise.azurerm_management_group.level_3["CFT-Prod"] will be updated in-place
  ~ resource "azurerm_management_group" "level_3" {
        id                         = "/providers/Microsoft.Management/managementGroups/CFT-Prod"
        name                       = "CFT-Prod"
      ~ subscription_ids           = [
          + "06069648-d13b-4c3c-9367-f3a1ed8e38bc",
            # (1 unchanged element hidden)
        ]
```

## Cancelling a subscription

There is two options for cancelling a subscription depending on how confident you are the subscription is not in use

### Removing from terraform

> Use this option when you are sure the subscription is not in use

Currently, it is not possible to cancel a subscription if it contains resources.

So to cancel the subscription you need to:

1. Delete any existing resources
2. Remove the subscription from this repository
3. Verify pipeline succeeded
4. Wait ~30 minutes for the portal to update and check it is in a disabled state

It will then stay for 90 days or can be force deleted after 72 hours.

There are feature requests open to allow a subscription soft-delete with resources inside it, see:
- [hashicorp/terraform-provider-azurerm #12264 (Support for IgnoreResourceCheck when cancelling a subscription)](https://github.com/hashicorp/terraform-provider-azurerm/issues/12264)
- [Azure/azure-rest-api-specs #20254 (Ignore existing resources within a subscription)](https://github.com/Azure/azure-rest-api-specs/issues/20254)

### Portal

> Use this option when you aren't sure if the subscription is still in use as it allows you to reactivate

Cancelling through the portal disables the subscription, blocks access to resources and stops the billing.
It will be automatically deleted after 90 days or can be force deleted after 72 hours.

Once the subscription has been fully deleted it can be removed from terraform.

