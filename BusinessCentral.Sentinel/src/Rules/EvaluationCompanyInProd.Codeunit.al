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
        LongDescLbl: Label 'An evaluation company has been detected in the environment. If you do not need it anymore, you should consider deleting it.';
        ShortDescLbl: Label 'Evaluation Company detected: %1', Comment = '%1 = Company Name';
    begin
        Company.SetRange("Evaluation Company", true);
        Company.ReadIsolation(IsolationLevel::ReadUncommitted);
        Company.SetLoadFields("Name", SystemId);
        if Company.FindSet() then
            repeat
                Alert.New(
                    "AlertCodeSESTM"::"SE-000003",
                    StrSubstNo(ShortDescLbl, Company.Name),
                    EnvironmentInformation.IsProduction() ? SeveritySESTM::Warning : SeveritySESTM::Info,
                    AreaSESTM::Technical,
                    LongDescLbl,
                    StrSubstNo(CallToActionLbl, Company.Name),
                    Company.SystemId
                );
            until Company.Next() = 0;


    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000003', Locked = true;
    begin
        Hyperlink(WikiLinkTok);
    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    begin

    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    begin

    end;
}