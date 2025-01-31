namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;
using System.Telemetry;

codeunit 71180285 "SentinelTelemetryLoggerSESTM" implements "Telemetry Logger"
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = R;

    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
    begin
        Session.LogMessage(EventId, Message, Verbosity, DataClassification, TelemetryScope::All, CustomDimensions);
    end;

    // For the functionality to behave as expected, there must be exactly one implementation of the "Telemetry Logger" interface registered per app publisher
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Loggers", 'OnRegisterTelemetryLogger', '', true, true)]
    local procedure OnRegisterTelemetryLogger(var Sender: Codeunit "Telemetry Loggers")
    var
        SentinelTelemetryLogger: Codeunit SentinelTelemetryLoggerSESTM;
    begin
        Sender.Register(SentinelTelemetryLogger);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Management", OnSendDailyTelemetry, '', false, false)]
    local procedure LogSentinelTelemetry_OnSendDailyTelemetry()
    var
        Alert: Record AlertSESTM;
        Setup: Record SentinelSetup;
    begin
        if Alert.FindSet() then
            repeat
                if Setup.GetTelemetryLoggingSetting(Alert.AlertCode) = Setup.TelemetryLogging::Daily then
                    Alert.LogUsage();
            until Alert.Next() = 0;
    end;
}