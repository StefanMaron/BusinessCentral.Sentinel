# Changelog

## [Unreleased](https://github.com/StefanMaron/BusinessCentral.Sentinel/tree/HEAD)

[Full Changelog](https://github.com/StefanMaron/BusinessCentral.Sentinel/compare/1.3.17...HEAD)

**Changes:**

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