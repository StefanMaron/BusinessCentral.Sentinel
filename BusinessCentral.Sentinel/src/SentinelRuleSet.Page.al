namespace STM.BusinessCentral.Sentinel;

page 71180277 SentinelRuleSetSESTM
{
    ApplicationArea = All;
    Caption = 'Sentinel Rule Set';
    Extensible = false;
    PageType = List;
    SourceTable = SentinelRuleSetSESTM;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field(AlertCode; Rec.AlertCode) { }
                field(Severity; Rec.Severity) { }
            }

        }
    }
}