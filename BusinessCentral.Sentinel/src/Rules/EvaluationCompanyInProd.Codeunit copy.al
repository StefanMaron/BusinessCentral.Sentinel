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
        Alert: Record AlertSESTM;
        Extensions: Record "NAV App Installed App";
        EnvironmentInformation: Codeunit "Environment Information";
        ActionRecommendationLbl: Label 'Uninstall the "%1" Extension', Comment = '%1 = Extension Name';
        ContosoCoffeeDemoDatasetAppIdTok: Label '5a0b41e9-7a42-4123-d521-2265186cfb31', Locked = true;
        ContosoCoffeeDemoDatasetUSAppIdTok: Label '3a3f33b1-7b42-4123-a521-2265186cfb31', Locked = true;
        LongDescLbl: Label 'Extension for generation of demo data can mess up your data. If you do not need it to generate demo data anymore, you should consider uninstalling it.';
        ShotDescLbl: Label 'Demo Data Extension Found: %1', Comment = '%1 = Extension Name';
        SustainabilityContosoCoffeeDemoDatasetAppIdTok: Label 'a0673989-48a4-48a0-9517-499c9f4037d3', Locked = true;
    begin
        Extensions.SetRange("App ID", ContosoCoffeeDemoDatasetAppIdTok);
        Extensions.ReadIsolation(IsolationLevel::ReadUncommitted);
        Extensions.SetLoadFields("App ID", Name);

        if Extensions.FindFirst() then begin
            Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
            Alert.SetRange("UniqueIdentifier", Extensions."App ID");
            if Alert.IsEmpty then begin
                Alert.Validate(AlertCode, "AlertCodeSESTM"::"SE-000004");
                Alert.Validate("ShortDescription", StrSubstNo(ShotDescLbl, Extensions."Name"));
                if EnvironmentInformation.IsProduction() then
                    Alert.Validate(Severity, SeveritySESTM::Warning)
                else
                    Alert.Validate(Severity, SeveritySESTM::Info);
                Alert.Validate("Area", AreaSESTM::Technical);
                Alert.Validate(LongDescription, LongDescLbl);
                Alert.Validate(ActionRecommendation, StrSubstNo(ActionRecommendationLbl, Extensions."Name"));
                Alert.Validate(UniqueIdentifier, Extensions."App ID");
                Alert.Insert(true);
            end;
        end;

        Extensions.SetRange("App ID", ContosoCoffeeDemoDatasetUSAppIdTok);
        if Extensions.FindFirst() then begin
            Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
            Alert.SetRange("UniqueIdentifier", Extensions."App ID");
            if Alert.IsEmpty then begin
                Alert.Validate(AlertCode, "AlertCodeSESTM"::"SE-000004");
                Alert.Validate("ShortDescription", StrSubstNo(ShotDescLbl, Extensions."Name"));
                if EnvironmentInformation.IsProduction() then
                    Alert.Validate(Severity, SeveritySESTM::Warning)
                else
                    Alert.Validate(Severity, SeveritySESTM::Info);
                Alert.Validate("Area", AreaSESTM::Technical);
                Alert.Validate(LongDescription, LongDescLbl);
                Alert.Validate(ActionRecommendation, StrSubstNo(ActionRecommendationLbl, Extensions."Name"));
                Alert.Validate(UniqueIdentifier, Extensions."App ID");
                Alert.Insert(true);
            end;
        end;

        Extensions.SetRange("App ID", SustainabilityContosoCoffeeDemoDatasetAppIdTok);
        if Extensions.FindFirst() then begin
            Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
            Alert.SetRange("UniqueIdentifier", Extensions."App ID");
            if Alert.IsEmpty then begin
                Alert.Validate(AlertCode, "AlertCodeSESTM"::"SE-000004");
                Alert.Validate("ShortDescription", StrSubstNo(ShotDescLbl, Extensions."Name"));
                if EnvironmentInformation.IsProduction() then
                    Alert.Validate(Severity, SeveritySESTM::Warning)
                else
                    Alert.Validate(Severity, SeveritySESTM::Info);
                Alert.Validate("Area", AreaSESTM::Technical);
                Alert.Validate(LongDescription, LongDescLbl);
                Alert.Validate(ActionRecommendation, StrSubstNo(ActionRecommendationLbl, Extensions."Name"));
                Alert.Validate(UniqueIdentifier, Extensions."App ID");
                Alert.Insert(true);
            end;
        end;
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    begin

    end;

    procedure RunActionRecommendations(var Alert: Record AlertSESTM)
    var
        OpenPageQst: Label 'Do you want to open the page to manage the extension?';
    begin
        if Confirm(OpenPageQst) then
            Page.Run(Page::"Extension Management");
    end;
}