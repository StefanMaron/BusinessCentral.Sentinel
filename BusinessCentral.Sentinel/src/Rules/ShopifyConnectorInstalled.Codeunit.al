namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;
using System.Apps;
using System.Environment;
using System.Utilities;

codeunit 71180283 ShopifyConnectorInstalledSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata "NAV App Installed App" = R;

    procedure CreateAlerts()
    var
        Alert: Record AlertSESTM;
        Extensions: Record "NAV App Installed App";
        ActionRecommendationLbl: Label 'If you are not using the extension, consider uninstalling it. This can have a positive impact on performance.';
        LongDescLbl: Label 'Shopify Connector is installed in the environment but there is no shop configured for it. This may indicate that the extension is not being used.';
        ShopifyConnectorIdTok: Label 'ec255f57-31d0-4ca2-b751-f2fa7c745abb';
        ShortDescLbl: Label 'Shopify Connector installed but unused.';
    begin
        Extensions.SetRange("App ID", ShopifyConnectorIdTok);
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        if not Extensions.IsEmpty then
            if not this.HasShopsInAnyCompany() then
                Alert.New(
                    AlertCodeSESTM::"SE-000007",
                    ShortDescLbl,
                    SeveritySESTM::Warning,
                    AreaSESTM::Performance,
                    LongDescLbl,
                    ActionRecommendationLbl,
                    ShopifyConnectorIdTok
                );
    end;

    local procedure HasShopsInAnyCompany(): Boolean
    var
        Company: Record Company;
        RecRef: RecordRef;
        ShpfyShopId: Integer;
    begin
        ShpfyShopId := 30102;

        Company.SetRange("Evaluation Company", false);
        if Company.FindSet() then
            repeat
                RecRef.Open(ShpfyShopId, false, Company.Name);
                if not RecRef.IsEmpty() then
                    exit(true);
            until Company.Next() = 0;
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        DetailedExplanationMsg: Label 'This alert searches for the Shopify Connector extension and checks if there are any shops configured in a non-evaluation company. That means that the CRONUS company is not considered.\If there are no shops configured, a warning is raised. Extensions that are not used should be uninstalled to improve performance.';
    begin
        Message(DetailedExplanationMsg);
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