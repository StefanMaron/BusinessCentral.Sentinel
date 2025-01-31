namespace STM.BusinessCentral.Sentinel;

table 71180278 SentinelSetup
{
    Access = Internal;
    Caption = 'Sentinel Setup';
    DataClassification = SystemMetadata;
    InherentPermissions = R;
    Permissions =
        tabledata SentinelRuleSetSESTM = R,
        tabledata SentinelSetup = RI;

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            Caption = 'Primary Key';
            NotBlank = false;
        }
        field(2; TelemetryLogging; Enum TelemetryLogging)
        {
            Caption = 'Telemetry Logging';
            InitValue = Daily;
            ToolTip = 'Specifies how sentinel emits telemetry data.';
            ValuesAllowed = Daily, OnRuleLogging, Off;
        }
    }

    keys
    {
        key(Key1; PrimaryKey)
        {
            Clustered = true;
        }
    }

    internal procedure SaveGet()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;

    internal procedure GetTelemetryLoggingSetting(AlertCode: Enum AlertCodeSESTM): Enum TelemetryLogging
    var
        SentinelRuleSet: Record SentinelRuleSetSESTM;
    begin
        SentinelRuleSet.ReadIsolation(IsolationLevel::ReadCommitted);
        SentinelRuleSet.SetLoadFields(TelemetryLogging);
        if SentinelRuleSet.Get(AlertCode) and (SentinelRuleSet.TelemetryLogging <> SentinelRuleSet.TelemetryLogging::" ") then
            exit(SentinelRuleSet.TelemetryLogging);

        Rec.SetLoadFields(TelemetryLogging);
        Rec.ReadIsolation(IsolationLevel::ReadCommitted);
        Rec.SaveGet();
        exit(Rec.TelemetryLogging);
    end;

}