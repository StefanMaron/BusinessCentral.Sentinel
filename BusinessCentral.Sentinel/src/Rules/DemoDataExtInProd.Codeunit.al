namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;
using System.Apps;
using System.Environment;

codeunit 71180279 DemoDataExtInProdSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata Company = R;

    procedure CreateAlerts()
    var
        Extensions: Record "NAV App Installed App";
        ContosoCoffeeDemoDatasetAppIdTok: Label '5a0b41e9-7a42-4123-d521-2265186cfb31', Locked = true;
        ContosoCoffeeDemoDatasetUSAppIdTok: Label '3a3f33b1-7b42-4123-a521-2265186cfb31', Locked = true;
        SustainabilityContosoCoffeeDemoDatasetAppIdTok: Label 'a0673989-48a4-48a0-9517-499c9f4037d3', Locked = true;
    begin
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        Extensions.SetLoadFields("App ID", Name);

        this.CreateAlert(Extensions, ContosoCoffeeDemoDatasetAppIdTok);
        this.CreateAlert(Extensions, ContosoCoffeeDemoDatasetUSAppIdTok);
        this.CreateAlert(Extensions, SustainabilityContosoCoffeeDemoDatasetAppIdTok);
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000004', Locked = true;
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
        NoAutofixAvailableLbl: Label 'No autofix available for this alert. (SE-000004)';
    begin
        Message(NoAutofixAvailableLbl);
    end;

    local procedure CreateAlert(var Extensions: Record "NAV App Installed App"; AppId: Text)
    var
        Alert: Record AlertSESTM;
        EnvironmentInformation: Codeunit "Environment Information";
        ActionRecommendationLbl: Label 'Uninstall the "%1" Extension', Comment = '%1 = Extension Name';
        LongDescLbl: Label 'Extension for generation of demo data can mess up your data. If you do not need it to generate demo data anymore, you should consider uninstalling it.';
        ShotDescLbl: Label 'Demo Data Extension Found: %1', Comment = '%1 = Extension Name';
    begin
        Extensions.SetRange("App ID", AppId);
        if Extensions.FindFirst() then
            Alert.New(
                "AlertCodeSESTM"::"SE-000004",
                StrSubstNo(ShotDescLbl, Extensions."Name"),
                EnvironmentInformation.IsProduction() ? SeveritySESTM::Warning : SeveritySESTM::Info,
                AreaSESTM::Technical,
                LongDescLbl,
                StrSubstNo(ActionRecommendationLbl, Extensions."Name"),
                Extensions."App ID"
            );
    end;

    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])
    var
        Extensions: Record "NAV App Installed App";
    begin
        Extensions.SetLoadFields("Name", "App ID", Publisher, "Version Major", "Version Minor", "Version Build", "Version Revision");
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        if not Extensions.Get(Alert.UniqueIdentifier) then
            exit;

        CustomDimensions.Add('AlertExtensionName', Extensions.Name);
        CustomDimensions.Add('AlertAppID', Extensions."App ID");
        CustomDimensions.Add('AlertPublisher', Extensions.Publisher);
        CustomDimensions.Add('AlertAppVersion', StrSubstNo('%1.%2.%3.%4', Extensions."Version Major", Extensions."Version Minor", Extensions."Version Build", Extensions."Version Revision"));
    end;

    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text
    begin
        exit(Alert.ShortDescription);
    end;
}