namespace STM.BusinessCentral.Sentinel;

using System.Telemetry;

codeunit 71180285 "SentinelTelemetryLoggerSESTM" implements "Telemetry Logger"
{
    Access = Internal;

    procedure LogMessage(EventId: Text; Message: Text; Verbosity: Verbosity; DataClassification: DataClassification; TelemetryScope: TelemetryScope; CustomDimensions: Dictionary of [Text, Text])
    begin
        Session.LogMessage(EventId, Message, Verbosity, DataClassification, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;

    // For the functionality to behave as expected, there must be exactly one implementation of the "Telemetry Logger" interface registered per app publisher
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Loggers", 'OnRegisterTelemetryLogger', '', true, true)]
    local procedure OnRegisterTelemetryLogger(var Sender: Codeunit "Telemetry Loggers")
    var
        SentinelTelemetryLogger: Codeunit SentinelTelemetryLoggerSESTM;
    begin
        Sender.Register(SentinelTelemetryLogger);
    end;
}