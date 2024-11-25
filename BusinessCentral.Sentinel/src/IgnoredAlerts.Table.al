namespace STM.BusinessCentral.Sentinel;

table 71180276 IgnoredAlertsSESTM
{
    Access = Internal;
    Caption = 'Ignored Alerts';
    DataClassification = SystemMetadata;
    Extensible = false;

    fields
    {
        field(1; AlertCode; Enum AlertCodeSESTM)
        {
            Caption = 'Alert Code';
        }
        field(2; UniqueIdentifier; Text[100])
        {
            Caption = 'Unique Identifier';
        }
    }

    keys
    {
        key(Key1; AlertCode, UniqueIdentifier)
        {
            Clustered = true;
        }
    }
}