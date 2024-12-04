# BusinessCentral.Sentinel

BusinessCentral.Sentinel is an intelligent monitoring and advisory tool designed for Microsoft Dynamics 365 Business Central users. It focuses on the analysis of technical configuration and may include functional configuration in the future. This app provides real-time insights, proactive alerts, and actionable recommendations to enhance operational efficiency, reduce risks, and optimize decision-making. BusinessCentral.Sentinel acts as a vigilant 'sentinel' for your business, ensuring key processes run smoothly and critical issues are addressed promptly.

## Features

- **Real-Time Alerts**: Get notified instantly about critical business events.
- **Actionable Recommendations**: Receive suggestions to improve business processes.
- **Customizable Rules**: Tailor the monitoring rules to fit your specific needs.
- **Intuitive Dashboards**: Visualize key performance indicators and insights at a glance.
- **Seamless Integration**: Built specifically for Dynamics 365 Business Central, ensuring smooth workflow integration.

## Rules

| ID | Short Description | Area | Severity |
|----------|-----------------------------------------------------------------------------------|------------|----------|
| SE-000001| Warns if Per Tenant Extension do not allow Download Code| Technical| Warning|
| SE-000002| Warns if Extension in DEV Scope are installed | Technical| Warning|
| SE-000003| Evaluation Company detected in Production | Technical | Info |
| SE-000004| Demo Data Extensions should get uninstalled from production | Technical | Info |
| SE-000005| Inform about users with Super permissions | Permissions| Info |
| SE-000006| Consider configuring non-posting number series to allow gaps to increase performance | Performance| Warning|
| SE-000007| Extension installed but unused.| Performance| Warning|

## Documentation

For detailed documentation, visit our [GitHub Wiki](https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki).

## Open Source

This project is open source and we welcome contributions from the community. Feel free to fork the repository, make improvements, and submit pull requests. Your contributions help make this project better for everyone.

## Contributing

We welcome contributions to BusinessCentral.Sentinel!

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please open an issue on our [GitHub Issues](https://github.com/StefanMaron/BusinessCentral.Sentinel/issues) page.

## Acknowledgements

This project is based on the AL-Go AppSource App Template. Learn more about AL-Go [here](https://aka.ms/AL-Go).

[![Use this template](https://github.com/microsoft/AL-Go/assets/10775043/ca1ecc85-2fd3-4ab5-a866-bd2e7e80259d)](https://github.com/new?template_name=AL-Go-AppSource&template_owner=microsoft)