namespace STM.BusinessCentral.Sentinel;

interface IAuditAlertSESTM
{
    Access = Internal;

    procedure CreateAlerts()
    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    /// <summary>
    /// AutoFix is a procedure that will be called when the user wants to fix the alert automatically.
    /// </summary>
    /// <param name="Alert"></param>
    procedure AutoFix(var Alert: Record AlertSESTM)

}