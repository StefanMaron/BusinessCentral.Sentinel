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
        ShopifyConnectorIdTok: Label 'ec255f57-31d0-4ca2-b751-f2fa7c745abb', Locked = true;
    begin
        RaiseAlertIfExtensionIsUnused(ShopifyConnectorIdTok, 30102); // Shopify Connector / Shops Table
    end;

    local procedure RaiseAlertIfExtensionIsUnused(AppId: Text; TableToVerify: Integer)
    var
        TablesToVerify: List of [Integer];
    begin
        TablesToVerify.Add(TableToVerify);
        RaiseAlertIfExtensionIsUnused(AppId, TablesToVerify);
    end;

    local procedure RaiseAlertIfExtensionIsUnused(AppId: Text; TablesToVerify: List of [Integer])
    var
        Alert: Record AlertSESTM;
        Company: Record Company;
        Extensions: Record "NAV App Installed App";
        RecRef: RecordRef;
        TableId: Integer;
        ActionRecommendationLbl: Label 'If you are not using the extension, consider uninstalling it. This can have a positive impact on performance.';
        LongDescLbl: Label 'Extension "%1" is installed in the environment but there is no data configured for it. This may indicate that the extension is not being used.', Comment = '%1 = Extension Name';
        ShortDescLbl: Label 'Extension "%1" is installed but unused.', Comment = '%1 = Extension Name';
    begin
        Extensions.SetRange("App ID", AppId);
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        if Extensions.FindFirst() then begin
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

        Alert.New(
            AlertCodeSESTM::"SE-000007",
            StrSubstNo(ShortDescLbl, Extensions.Name),
            SeveritySESTM::Warning,
            AreaSESTM::Performance,
            StrSubstNo(LongDescLbl, Extensions.Name),
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