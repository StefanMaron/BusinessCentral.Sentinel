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
        LongDescLbl: Label 'Per Tenant Extension does not allow Download Code, if the code was developed for you by a third party, you might want to make sure to have access to the code in case you need to make changes in the future and the third party is not available anymore.';
        ShortDescLbl: Label 'Download Code not allowed for PTE: %1', Comment = '%1 = Extension Name';
    begin
        Extensions.SetRange("Published As", Extensions."Published As"::PTE);
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        Extensions.SetLoadFields("Package ID", "App ID", Name);
        if Extensions.FindSet() then
            repeat
                Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
                Alert.SetRange("UniqueIdentifier", Extensions."App ID");
                if Alert.IsEmpty() then
                    if not this.CanDownloadSourceCode(Extensions."Package ID") then begin
                        Alert.Validate(AlertCode, "AlertCodeSESTM"::"SE-000001");
                        Alert.Validate("ShortDescription", StrSubstNo(ShortDescLbl, Extensions."Name"));
                        Alert.Validate(Severity, SeveritySESTM::Warning);
                        Alert.Validate("Area", AreaSESTM::Technical);
                        Alert.Validate(LongDescription, LongDescLbl);
                        Alert.Validate(ActionRecommendation, ActionRecommendationLbl);
                        Alert.Validate(UniqueIdentifier, Extensions."App ID");
                        Alert.Insert(true);
                    end;
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
        MoreDetailsMsg: Label 'The extension is a Per Tenant Extension and does not allow Download Code. If the code was developed for you by a third party, you might want to make sure to have access to the code in case you need to make changes in the future and the third party is not available anymore.';
    begin
        Message(MoreDetailsMsg);
    end;

    procedure RunActionRecommendations(var Alert: Record AlertSESTM)
    var
        OpenPageQst: Label 'Do you want to open the page to manage the extension?';
    begin
        if Confirm(OpenPageQst) then
            Page.Run(Page::"Extension Management");
    end;
}