namespace STM.BusinessCentral.Sentinel;

using System.Environment;
using System.Telemetry;

codeunit 71180284 "TelemetryHelperSESTM"
{
    Access = Internal;

    procedure LogUptake(Feature: Enum TelemetryFeaturesSESTM; FeatureStatus: Enum "Feature Uptake Status")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not IsSaaS() then
            exit;

        FeatureTelemetry.LogUptake(
            Feature.Names().Get(Feature.AsInteger()),
            Format(Feature),
            FeatureStatus
        );
    end;

    procedure LogError(Feature: Enum TelemetryFeaturesSESTM; EventName: Text; ErrorText: Text)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not IsSaaS() then
            exit;

        FeatureTelemetry.LogError(
            Feature.Names().Get(Feature.AsInteger()),
            Format(Feature),
            EventName,
            ErrorText
        );
    end;

    procedure LogUsage(Feature: Enum TelemetryFeaturesSESTM; EventName: Text)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not IsSaaS() then
            exit;

        FeatureTelemetry.LogUsage(
            Feature.Names().Get(Feature.AsInteger()),
            Format(Feature),
            EventName
        );
    end;

    procedure LogUsage(Feature: Enum TelemetryFeaturesSESTM; EventName: Text; CustomDimensions: Dictionary of [Text, Text])
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not IsSaaS() then
            exit;

        FeatureTelemetry.LogUsage(
            Feature.Names().Get(Feature.AsInteger()),
            Format(Feature),
            EventName,
            CustomDimensions
        );
    end;

    local procedure IsSaaS(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        exit(EnvironmentInformation.IsSaaS());
    end;
}