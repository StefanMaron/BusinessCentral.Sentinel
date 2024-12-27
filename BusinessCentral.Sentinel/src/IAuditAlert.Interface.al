namespace STM.BusinessCentral.Sentinel;

interface IAuditAlertSESTM
{
    Access = Internal;

    /// <summary>
    /// This procedure should be used to create alerts. It should determine any alerts for a rule and create the records in the alert table.
    /// Use `Alert.New()` to create a new alert.
    /// </summary>
    procedure CreateAlerts()

    /// <summary>
    /// This should a very detailed description of the alert. It can also use `Hyperlink` to open a documentation page in a browser.
    /// </summary>
    /// <param name="Alert"></param>
    procedure ShowMoreDetails(var Alert: Record AlertSESTM)

    /// <summary>
    /// This procedure should offer the user to open a page within BC where the user can get more information about the alert
    /// or where the user can take actions to resolve the alert.
    /// </summary>
    /// <param name="Alert"></param>
    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)

    /// <summary>
    /// AutoFix is a procedure that will be called when the user wants to fix the alert automatically.
    /// It should just fix the issue described in the alert.
    /// Before executing the autofix, the procedure should inform the user about the changes that will be made and ask for confirmation.
    /// If no autofix is available, the procedure should inform the user about it.
    /// </summary>
    /// <param name="Alert"></param>
    procedure AutoFix(var Alert: Record AlertSESTM)

    /// <summary>
    /// Add custom telemetry dimensions to the alert. Severity, Area and Ignore are already added by default.
    /// </summary>
    /// <param name="Alert"></param>
    /// <param name="CustomDimensions"></param>
    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])

    /// <summary>
    /// Get the telemetry description for the alert.
    /// </summary>
    /// <param name="Alert"></param>
    /// <returns></returns>
    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text

}