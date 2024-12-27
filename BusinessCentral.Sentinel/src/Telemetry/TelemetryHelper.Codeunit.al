namespace STM.BusinessCentral.Sentinel;

using System.Environment;
using System.Telemetry;

codeunit 71180284 "TelemetryHelperSESTM"
{
    Access = Internal;

    procedure LogUsage(Alert: Enum AlertCodeSESTM; Description: Text; CustomDimensions: Dictionary of [Text, Text])
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if not this.IsSaaS() then
            exit;

        FeatureTelemetry.LogUsage(
            Alert.Names().Get(Alert.AsInteger()),
            Format(Alert),
            Description,
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