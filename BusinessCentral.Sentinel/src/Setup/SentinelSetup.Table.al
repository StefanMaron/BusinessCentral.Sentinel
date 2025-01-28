namespace STM.BusinessCentral.Sentinel;

table 71180278 SentinelSetup
{
    Access = Internal;
    Caption = 'Sentinel Setup';
    DataClassification = SystemMetadata;
    InherentPermissions = R;
    Permissions = tabledata SentinelSetup = RI;

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

}