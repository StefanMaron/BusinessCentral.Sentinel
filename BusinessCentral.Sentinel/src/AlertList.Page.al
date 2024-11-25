namespace STM.BusinessCentral.Sentinel;

page 71180275 AlertListSESTM
{
    AboutText = 'This page shows a list of all alerts that have been generated by the system. Alerts are generated when the system detects an issue that requires attention.';
    AboutTitle = 'Business Central Sentinel: Alert List';
    AdditionalSearchTerms = 'Sentinel';
    ApplicationArea = All;
    Caption = 'Alert List';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = AlertSESTM;
    UsageCategory = Lists;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Id; Rec.Id)
                {
                    Visible = false;
                }
                field("Code"; Rec.AlertCode)
                {
                    AboutText = 'The code representing the type of alert. You may see more than one alert with the same code if the same issue is detected multiple times.';
                    AboutTitle = 'Alert Code';
                    StyleExpr = SeverityStyle;
                }
                field("Short Description"; Rec."ShortDescription")
                {
                    AboutText = 'A brief description of the alert. Click on the field to see the full explanation.';
                    AboutTitle = 'Short Description';
                    MultiLine = true;

                    trigger OnDrillDown()
                    var
                        IAuditAlert: Interface IAuditAlertSESTM;
                    begin
                        IAuditAlert := Rec.AlertCode;
                        IAuditAlert.ShowMoreDetails(Rec);
                    end;
                }
                field(LongDescription; Rec.LongDescription)
                {
                    AboutText = 'A more detailed description of the alert. Click on the field to see the full explanation.';
                    AboutTitle = 'Long Description';
                    MultiLine = true;

                    trigger OnDrillDown()
                    var
                        IAuditAlert: Interface IAuditAlertSESTM;
                    begin
                        IAuditAlert := Rec.AlertCode;
                        IAuditAlert.ShowMoreDetails(Rec);
                    end;
                }
                field(Severity; Rec.Severity)
                {
                }
                field("Area"; Rec."Area")
                {
                }
                field(ActionRecommendation; Rec.ActionRecommendation)
                {
                    AboutText = 'Recommended actions to take in response to the alert. Depending on the alert, you may be able to run an action to fix the issue.';
                    AboutTitle = 'Action Recommendation';
                    MultiLine = true;

                    trigger OnDrillDown()
                    var
                        IAuditAlert: Interface IAuditAlertSESTM;
                    begin
                        IAuditAlert := Rec.AlertCode;
                        IAuditAlert.RunActionRecommendations(Rec);
                    end;
                }
                field(Ignore; Rec.Ignore)
                {
                    AboutText = 'Indicates whether the alert has been marked as ignored. Ignored alerts will be excluded from reports and queues on the Role Center.';
                    AboutTitle = 'Ignore';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunAnalysis)
            {
                AboutText = 'Run the analysis of the current environment, and check for new alerts.';
                AboutTitle = 'Run Analysis';
                Caption = 'Run Analysis';
                Image = Suggest;
                ToolTip = 'Run the analysis of the current environment, and check for new alerts.';

                trigger OnAction()
                begin
                    Rec.FindNewAlerts();
                end;
            }
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
            action(ClearAllAlerts)
            {
                AboutText = 'Clear all alerts that have been generated by the system. It will save which alerts have been ignored. But lets you start fresh to remove resolved alerts.';
                AboutTitle = 'Clear All Alerts';
                Caption = 'Clear All Alerts';
                Image = Delete;
                ToolTip = 'Clear all alerts.';

                trigger OnAction()
                begin
                    Rec.ClearAllAlerts();
                end;
            }
            action(FullReRun)
            {
                AboutText = 'Remove all alerts and re-runs the analysis of the current environment.';
                AboutTitle = 'Full Re-Run';
                Caption = 'Full Re-Run';
                Image = Suggest;
                ToolTip = 'Run the analysis of the current environment, and check for new alerts.';

                trigger OnAction()
                begin
                    Rec.FullRerun();
                end;
            }
        }
        area(Promoted)
        {
            group(Run)
            {
                ShowAs = SplitButton;
                actionref(RunAnalysis_Promoted; RunAnalysis) { }
                actionref(ClearAllAlerts_Promoted; ClearAllAlerts) { }
                actionref(FullReRun_Promoted; FullReRun) { }
            }
            group(Ignore_promoted)
            {
                ShowAs = SplitButton;
                actionref(SetToIgnore_Promoted; SetToIgnore) { }
                actionref(ClearIgnore_Promoted; ClearIgnore) { }
            }
        }
    }

    var
        SeverityStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Severity of
            SeveritySESTM::Info:
                SeverityStyle := Format(PageStyle::StandardAccent);
            SeveritySESTM::Warning:
                SeverityStyle := Format(PageStyle::Ambiguous);
            SeveritySESTM::Error:
                SeverityStyle := Format(PageStyle::Attention);
            SeveritySESTM::Critical:
                SeverityStyle := Format(PageStyle::Unfavorable);
        end;
    end;

}