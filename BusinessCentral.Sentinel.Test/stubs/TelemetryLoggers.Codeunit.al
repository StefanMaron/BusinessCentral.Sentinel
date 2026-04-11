// Stub for System.Telemetry."Telemetry Loggers"
namespace System.Telemetry;

codeunit 8708 "Telemetry Loggers"
{
    procedure Register(Logger: Interface "Telemetry Logger")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRegisterTelemetryLogger(var Sender: Codeunit "Telemetry Loggers")
    begin
    end;
}
