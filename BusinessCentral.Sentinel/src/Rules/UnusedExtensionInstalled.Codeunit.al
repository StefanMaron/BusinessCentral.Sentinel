namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;
using System.Apps;
using System.Environment;
using System.Utilities;

codeunit 71180283 UnusedExtensionInstalledSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata "NAV App Installed App" = R;

    procedure CreateAlerts()
    var
        AMCBankingTok: Label '16319982-4995-4fb1-8fb2-2b1e13773e3b', Locked = true;
        CeridianPayrollTok: Label '30828ce4-53e3-407f-ba80-13ce8d79d110', Locked = true;
        CloudMigrationApiTok: Label '57623bfa-0559-4bc2-ae1c-0979c29fc8d1', Locked = true;
        CloudMigrationTok: Label '6992416f-3f39-4d3c-8242-3fff61350bea', Locked = true;
        IntelligentCloudTok: Label '334ef79e-547e-4631-8ba1-7a7f18e14de6', Locked = true;
        IntercompanyAPITok: Label 'a190e87b-2f59-4e14-a727-421877802768', Locked = true;
        ShopifyConnectorIdTok: Label 'ec255f57-31d0-4ca2-b751-f2fa7c745abb', Locked = true;
    begin
        this.RaiseAlertIfExtensionIsUnused(ShopifyConnectorIdTok, 30102);
        this.RaiseAlertIfExtensionIsUnused(AMCBankingTok, 20101);
        this.RaiseAlertIfExtensionIsUnused(IntercompanyAPITok, 413);
        this.RaiseAlertIfExtensionIsUnused(CloudMigrationTok);
        this.RaiseAlertIfExtensionIsUnused(CloudMigrationApiTok);
        this.RaiseAlertIfExtensionIsUnused(IntelligentCloudTok);
        this.RaiseAlertIfExtensionIsUnused(CeridianPayrollTok, 1665);
    end;

    local procedure RaiseAlertIfExtensionIsUnused(AppId: Text)
    var
        TablesToVerify: List of [Integer];
    begin
        this.RaiseAlertIfExtensionIsUnused(AppId, TablesToVerify);
    end;

    local procedure RaiseAlertIfExtensionIsUnused(AppId: Text; TableToVerify: Integer)
    var
        TablesToVerify: List of [Integer];
    begin
        TablesToVerify.Add(TableToVerify);
        this.RaiseAlertIfExtensionIsUnused(AppId, TablesToVerify);
    end;

    local procedure RaiseAlertIfExtensionIsUnused(AppId: Text; TablesToVerify: List of [Integer])
    var
        Alert: Record AlertSESTM;
        Company: Record Company;
        Extensions: Record "NAV App Installed App";
        RecRef: RecordRef;
        TableId: Integer;
        ActionRecommendationLbl: Label 'If you are not using the extension, consider uninstalling it. This can have a positive impact on performance.';
        LongDescLbl: Label 'Extension "%1" is installed in the environment but there is no data configured for it. This may indicate that the extension is not being used. App ID: %2', Comment = '%1 = Extension Name, %2 = App ID';
        ShortDescLbl: Label 'Extension "%1" is installed but unused. App ID: %2', Comment = '%1 = Extension Name, %2 = App ID';
        AppInfo: ModuleInfo;
        AppName: Text;
    begin
        Extensions.SetRange("App ID", AppId);
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        if not Extensions.IsEmpty() then begin
            Company.SetRange("Evaluation Company", false);
            if Company.FindSet() then
                repeat
                    foreach TableId in TablesToVerify do begin
                        Clear(RecRef);

                        RecRef.Open(TableId, false, Company.Name);
                        if not RecRef.IsEmpty() then
                            exit;
                        RecRef.Close();
                    end;
                until Company.Next() = 0;
        end;

        AppName := NavApp.GetModuleInfo(AppId, AppInfo) ? AppInfo.Name : '<unknown>';

        Alert.New(
            AlertCodeSESTM::"SE-000007",
            StrSubstNo(ShortDescLbl, AppName, AppId),
            SeveritySESTM::Warning,
            AreaSESTM::Performance,
            StrSubstNo(LongDescLbl, AppName, AppId),
            ActionRecommendationLbl,
            CopyStr(AppId, 1, 100)
        );
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000007', Locked = true;
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
    begin

    end;
}