namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;
using System.Apps;
using System.Utilities;

codeunit 71180276 AlertPteDownloadCodeSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata "NAV App Installed App" = R;

    procedure CreateAlerts()
    var
        Alert: Record AlertSESTM;
        Extensions: Record "NAV App Installed App";
        ActionRecommendationLbl: Label 'Talk to the third party that developed the extension and ask for a copy of the code or to enable the download code option.';
        LongDescLbl: Label 'The Per Tenant Extension does not allow Download Code, if the code was developed for you by a third party, you might want to make sure to have access to the code in case you need to make changes in the future and the third party is not available anymore. If you have access to the source, for example, because you developed the extension yourself or you have been granted access though another way, like GitHub, you can ignore this alert.';
        ShortDescLbl: Label 'Download Code not allowed for PTE: Name: "%1" AppId: "%2"', Comment = '%1 = Extension Name, %2 = App ID';
    begin
        Extensions.SetRange("Published As", Extensions."Published As"::PTE);
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        Extensions.SetLoadFields("Package ID", "App ID", Name);
        if Extensions.FindSet() then
            repeat
                if not this.CanDownloadSourceCode(Extensions."Package ID") then
                    Alert.New(
                        "AlertCodeSESTM"::"SE-000001",
                        StrSubstNo(ShortDescLbl, Extensions."Name", DelChr(Extensions."App ID", '=', '{}')),
                        SeveritySESTM::Warning,
                        AreaSESTM::Technical,
                        LongDescLbl,
                        ActionRecommendationLbl,
                        Extensions."App ID"
                    );
            until Extensions.Next() = 0;
    end;

    [TryFunction]
    local procedure CanDownloadSourceCode(PackageId: Guid)
    var
        ExtensionManagement: Codeunit "Extension Management";
        ExtensionSourceTempBlob: Codeunit "Temp Blob";
    begin
        ExtensionManagement.GetExtensionSource(PackageId, ExtensionSourceTempBlob);
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000001', Locked = true;
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