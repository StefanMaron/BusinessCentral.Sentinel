namespace STM.BusinessCentral.Sentinel;

table 71180277 SentinelRuleSetSESTM
{
    Access = Internal;
    Caption = 'Sentinel Rule Set';
    DataClassification = CustomerContent;
    DrillDownPageId = SentinelRuleSetSESTM;
    LookupPageId = SentinelRuleSetSESTM;

    fields
    {
        field(1; AlertCode; Enum "AlertCodeSESTM")
        {
            Caption = 'Code';
            NotBlank = true;
            ToolTip = 'The code representing the type of alert.';
        }
        field(3; Severity; Enum SeveritySESTM)
        {
            Caption = 'Severity';
            ToolTip = 'The severity level of the alert.';
        }
        field(4; TelemetryLogging; Enum TelemetryLogging)
        {
            Caption = 'Telemetry Logging';
            ToolTip = 'Specifies how sentinel emits telemetry data.';
        }
    }

    keys
    {
        key(Key1; AlertCode)
        {
            Clustered = true;
        }
    }
}