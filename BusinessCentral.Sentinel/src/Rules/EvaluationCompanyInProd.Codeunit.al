namespace STM.BusinessCentral.Sentinel;

using Microsoft.Foundation.Company;
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
        LongDescLbl: Label 'An evaluation company has been detected in the environment. If you do not need it anymore, you should consider deleting it. It takes up additional space and it is copied to sandboxes if you copy from production.';
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
    var
        Company: Record Company;
        OpenPageQst: Label 'Do you want to open the page to manage companies?';
    begin
        if Confirm(OpenPageQst) then begin
            Company.SetRange(SystemId, Alert.UniqueIdentifier);
            Page.Run(Page::Companies, Company)
        end;
    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    var
        NoAutofixAvailableLbl: Label 'No autofix available for this alert. (SE-000003)';
    begin
        // The base BC logic that happens on delete company is on the page, and can not be reused
        // Therefore, the user has to use the ShowRelatedInformation to open the page and delete from there.
        Message(NoAutofixAvailableLbl);
    end;

    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])
    begin
        CustomDimensions.Add('AlertCompanyName', Alert.ShortDescription);
        CustomDimensions.Add('AlertCompanySystemId', Alert.UniqueIdentifier);
    end;

    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text
    begin
        exit(Alert.LongDescription);
    end;
}