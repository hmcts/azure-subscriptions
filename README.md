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

## Creating a new subscription

Request approval for a new subscription by emailing "DTS Platform Operations"

Once approved create a pull request adding the required subscriptions, ensuring they are in the correct management group.

Create a 'help request' in the [#platops-help](https://hmcts-reform.slack.com/app_redirect?channel=platops-help) Slack channel if you have any questions.

## Renaming a subscription

## Moving a subscription to a different 'Management group'

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

