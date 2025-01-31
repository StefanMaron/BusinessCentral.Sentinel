# Changelog

## [Unreleased](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/HEAD)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/compare/1.6.26...HEAD)

- Improve telemetry logging for rules, change logging to daily, give option to disable logging, log to "All" instead of "ExtensionPublisher"
- Ability to completely turn off telemetry
- Ability to control telemetry via ruleset per Alert individually
- Added card page for alerts and remove long description and action recommendation from the list page
- Improve Interface documentation

## [1.6.26](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/1.6.26)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/compare/1.5.25...1.6.26)

- Next attempt to get Rule 7 fixed. It tried to insert alerts even if the extension was not installed.

## [1.5.25](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/1.5.25)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/compare/1.4.22...1.5.25)

**Changes:**
- Added JobsSetup to NoSeries Checks Merge pull request [\#6](https://github.com/StefanMaron/BusinessCentral.Sentinel/pull/6) from [pri-kise](https://github.com/pri-kise)
- Added Rule in Ruleset to make the `this.` rule a warning
- Added Instructions for the Sentinel Tool on the Alert list
- Improved documentation on Rule 1-3

**Closed Issues:**
- Improve Rule SE-000007, there where cases where the App Name was not shown, also display the App ID [\#7](https://github.com/StefanMaron/BusinessCentral.Sentinel/issues/7)

## [1.4.22](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/1.4.22) (2024-12-05)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/compare/1.3.17...1.4.22)

**Changes:**

- Added extensions to Rule SE-000007: Shopify Connector, AMC Banking, API - Cross Environment Intercompany, Business Central Cloud Migration - Previous Release, Business Central Cloud Migration API, Business Central Intelligent Cloud, Ceridian Payroll
- Adjusted rule SE-000007 to be more generic and not Shopify Connector specific
- Fixed a bug that prevented the full rerun to work
- Added Changelog
- Move additional info to wiki instead of a message
- hide ignored alerts by default
- Add Sentinel Rule Set functionality and update alert severity handling


## [1.3.17](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/1.3.17) (2024-11-26)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/compare/1.2.15...1.3.17)

**Closed Issues:**

- The record is already open. [\#5](https://github.com/StefanMaron/BusinessCentral.Sentinel/issues/5)
- The number sequence 'BCSentinelSESTMAlertId' does not exist. [\#5](https://github.com/StefanMaron/BusinessCentral.Sentinel/issues/5)

## [1.2.15](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/1.2.15) (2024-11-26)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/compare/1.1.12...1.2.15)

**Changes:**

- Added rule to warn if the Shopify Connector is installed but unused (no Shops configured)
- Fixed an issue which prevented alerts to get created
- Added Telemetry for alerts

## [1.1.12](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/1.1.12) (2024-11-25)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/compare/1.0.10...1.1.12)

**Changes:**

- Changes of the Interface to seperate action recomendations, and auto fix action
- moved the drill down link to seperate actions to make the UX better
- `Alert.New()` for easier rule creation

**Closed issues:**

- Fix for Bug: Rec.FindFirst could give error [\#4](https://github.com/StefanMaron/BusinessCentral.Sentinel/issues/4)
- Fix for Evaluation company in a Sandbox [\#2](https://github.com/StefanMaron/BusinessCentral.Sentinel/issues/2)


## [1.0.10](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/1.0.10) (2024-11-25)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/commits/1.0.10)

**Changes:**

- First release to AppSource
- Contains the "engine" to run the alerts
- Warns if Per Tenant Extension do not allow Download Code
- Warns if Extension in DEV Scope are installed
- Evaluation Company detected in Production
- Demo Data Extensions should get uninstalled from production
- Inform about users with Super permissions
- Consider configuring non-posting number series to allow gaps to increase performance