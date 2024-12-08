namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;
using System.Apps;
using System.Utilities;

codeunit 71180277 AlertDevScopeExtSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata "NAV App Installed App" = R;

    procedure CreateAlerts()
    var
        Alert: Record AlertSESTM;
        Extensions: Record "NAV App Installed App";
        ActionRecommendationLbl: Label 'Talk to the developer that developed the extension and ask them to publish the extension in PTE scope instead.';
        LongDescLbl: Label 'Extension in DEV Scope will get uninstalled when the environment is upgraded to a newer version. This can be Minor updates (monthly) or Major updates (bi-yearly). Publishing them in PTE scope instead will prevent this and make sure the business processes are not interrupted.';
        ShortDescLbl: Label 'Extension in DEV Scope found: Name: "%1" AppId: "%2"', Comment = '%1 = Extension Name, %2 = App ID';
    begin
        Extensions.SetRange("Published As", Extensions."Published As"::Dev);
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        Extensions.SetLoadFields("App ID", Name);
        if Extensions.FindSet() then
            repeat
                Alert.New(
                    AlertCodeSESTM::"SE-000002",
                    StrSubstNo(ShortDescLbl, Extensions."Name", DelChr(Extensions."App ID", '=', '{}')),
                    SeveritySESTM::Warning,
                    AreaSESTM::Technical,
                    LongDescLbl,
                    ActionRecommendationLbl,
                    Extensions."App ID"
                );
            until Extensions.Next() = 0;
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000002', Locked = true;
    begin
        Hyperlink(WikiLinkTok);
    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    var
        OpenPageQst: Label 'Do you want to open the page to manage the extension?';
    begin
        if Confirm(OpenPageQst) then
            Page.Run(Page::"Extension Management");
    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    var
        NoAutofixAvailableLbl: Label 'No autofix available for this alert. (SE-000001)';
    begin
        Message(NoAutofixAvailableLbl);
    end;
}