namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;
using System.Environment;
using System.Environment.Configuration;

codeunit 71180278 EvaluationCompanyInProdSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata Company = R;

    procedure CreateAlerts()
    var
        Alert: Record AlertSESTM;
        Company: Record Company;
        EnvironmentInformation: Codeunit "Environment Information";
        CallToActionLbl: Label 'Delete the Company called %1', Comment = '%1 = Company Name';
        LongDescLbl: Label 'An evaluation company has been detected in the production environment. This company should be deleted.';
        ShortDescLbl: Label 'Evaluation Company In Prod detected: %1', Comment = '%1 = Company Name';
    begin
        Company.SetRange("Evaluation Company", true);
        Company.ReadIsolation(IsolationLevel::ReadUncommitted);
        Company.SetLoadFields("Name", SystemId);
        if Company.FindSet() then
            repeat
                Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
                Alert.SetRange("UniqueIdentifier", Company.SystemId);
                if Alert.IsEmpty() then begin
                    Alert.Validate(AlertCode, "AlertCodeSESTM"::"SE-000003");
                    Alert.Validate("ShortDescription", StrSubstNo(ShortDescLbl, Company.Name));
                    if EnvironmentInformation.IsProduction() then
                        Alert.Validate(Severity, SeveritySESTM::Warning)
                    else
                        Alert.Validate(Severity, SeveritySESTM::Info);
                    Alert.Validate("Area", AreaSESTM::Technical);
                    Alert.Validate(LongDescription, LongDescLbl);
                    Alert.Validate(ActionRecommendation, StrSubstNo(CallToActionLbl, Company.Name));
                    Alert.Validate(UniqueIdentifier, Company.SystemId);
                    Alert.Insert(true);
                end;
            until Company.Next() = 0;


    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    begin

    end;

    procedure RunActionRecommendations(var Alert: Record AlertSESTM)
    begin

    end;
}