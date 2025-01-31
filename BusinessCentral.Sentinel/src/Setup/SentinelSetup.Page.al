namespace STM.BusinessCentral.Sentinel;

page 71180278 SentinelSetup
{
    ApplicationArea = All;
    Caption = 'Sentinel Setup';
    DeleteAllowed = false;
    Extensible = false;
    PageType = Card;
    SourceTable = SentinelSetup;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(TelemetryLogging; Rec.TelemetryLogging) { }
            }
        }
    }
}