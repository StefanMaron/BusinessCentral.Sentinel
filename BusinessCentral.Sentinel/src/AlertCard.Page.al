namespace STM.BusinessCentral.Sentinel;

using System.Reflection;

page 71180279 AlertCard
{
    ApplicationArea = All;
    Caption = 'Alert Card';
    Editable = false;
    Extensible = false;
    PageType = Card;
    SourceTable = AlertSESTM;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(AlertCode; Rec.AlertCode) { }
                field(ShortDescription; Rec.ShortDescription)
                {
                    MultiLine = true;
                }
                field("Area"; Rec."Area") { }
                field(Severity; Rec.Severity) { }
                field(Ignore; Rec.Ignore) { }
                group(ActionRecommendationGrp)
                {
                    Caption = 'Action Recommendation';
                    field(ActionRecommendation; Rec.ActionRecommendation)
                    {
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
            }
            group(LongDescriptionGrp)
            {
                Caption = 'Long Description';
                field(LongDescription; this.LongDescriptionTxt)
                {
                    ExtendedDatatype = RichContent;
                    MultiLine = true;
                    ShowCaption = false;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetToIgnore)
            {
                AboutText = 'Flags the alert as ignored. Ignored alerts will be excluded from reports and queues on the Role Center.';
                AboutTitle = 'Ignore';
                Caption = 'Ignore';
                Image = Delete;
                ToolTip = 'Ignore this alert.';

                trigger OnAction()
                begin
                    Rec.SetToIgnore();
                end;
            }
            action(ClearIgnore)
            {
                Caption = 'Stop Ignoring';
                Image = Restore;
                ToolTip = 'Clear the ignore status of this alert.';

                trigger OnAction()
                begin
                    Rec.ClearIgnore();
                end;
            }
            action(MoreDetails)
            {
                Caption = 'More Details';
                Ellipsis = true;
                Image = LaunchWeb;
                Scope = Repeater;
                ToolTip = 'Show more details about this alert.';

                trigger OnAction()
                var
                    IAuditAlert: Interface IAuditAlertSESTM;
                begin
                    IAuditAlert := Rec.AlertCode;
                    IAuditAlert.ShowMoreDetails(Rec);
                end;
            }
            action(AutoFix)
            {
                Caption = 'Auto Fix';
                Ellipsis = true;
                Image = Action;
                Scope = Repeater;
                ToolTip = 'Automatically fix the issue that caused this alert.';

                trigger OnAction()
                var
                    IAuditAlert: Interface IAuditAlertSESTM;
                begin
                    IAuditAlert := Rec.AlertCode;
                    IAuditAlert.AutoFix(Rec);
                end;
            }
            action(ShowRelatedInformation)
            {
                Caption = 'Show Related Information';
                Ellipsis = true;
                Image = ViewDetails;
                Scope = Repeater;
                ToolTip = 'Show related information about this alert.';

                trigger OnAction()
                var
                    IAuditAlert: Interface IAuditAlertSESTM;
                begin
                    IAuditAlert := Rec.AlertCode;
                    IAuditAlert.ShowRelatedInformation(Rec);
                end;
            }
        }

        area(Promoted)
        {
            group(Ignore_promoted)
            {
                ShowAs = SplitButton;
                actionref(SetToIgnore_Promoted; SetToIgnore) { }
                actionref(ClearIgnore_Promoted; ClearIgnore) { }
            }
            actionref(MoreDetails_Promoted; MoreDetails) { }
            actionref(AutoFix_Promoted; AutoFix) { }
            actionref(ShowRelatedInformation_Promoted; ShowRelatedInformation) { }
        }
    }

    var
        LongDescriptionTxt: Text;

    trigger OnAfterGetRecord()
    begin
        this.LongDescriptionTxt := this.FormatLineBreaksForHTML(Rec.LongDescription);
    end;

    local procedure FormatLineBreaksForHTML(Value: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(Value.Replace('\', '<br />').Replace(TypeHelper.CRLFSeparator(), '<br />'));
    end;
}