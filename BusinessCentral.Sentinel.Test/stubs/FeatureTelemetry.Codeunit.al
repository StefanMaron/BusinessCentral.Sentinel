// Stub for System.Telemetry."Feature Telemetry"
namespace System.Telemetry;

codeunit 8703 "Feature Telemetry"
{
    procedure LogUsage(EventId: Text; FeatureName: Text; EventName: Text)
    begin
    end;

    procedure LogUsage(EventId: Text; FeatureName: Text; EventName: Text; CustomDimensions: Dictionary of [Text, Text])
    begin
    end;
}
