namespace STM.BusinessCentral.Sentinel;

codeunit 71180282 AlertDispatcherSESTM
{
    Access = Internal;
    Permissions = tabledata AlertSESTM = RIMD;

    procedure FindNewAlerts()
    var
        Alert: Record AlertSESTM;
        currOrdinal: Integer;
        AlertImpl: Interface IAuditAlertSESTM;
        AlertsToRun: List of [Interface IAuditAlertSESTM];
    begin
        foreach currOrdinal in Enum::AlertCodeSESTM.Ordinals() do
            AlertsToRun.Add(Enum::AlertCodeSESTM.FromInteger(currOrdinal));

        foreach AlertImpl in AlertsToRun do
            AlertImpl.CreateAlerts();

        if not Alert.FindFirst() then
            ; // Move to the first record, after Alert creation. If no alerts where created, do nothing
    end;

    procedure FullRerun()
    var
        Alert: Record AlertSESTM;
    begin
        Alert.ClearAllAlerts();
        Commit(); // Commit the transaction to ensure that the alerts are deleted before they are recreated
        FindNewAlerts();
    end;
}
