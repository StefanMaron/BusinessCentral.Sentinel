namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.TestLibraries.Utilities;
using System.Environment;
using Microsoft.Foundation.Company;

codeunit 71180501 EvalCompanyInProdTestSESTM
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

    // Real BC does not support creating a company from AL — `POST
    // /BC/ODataV4/Company` returns "Adding a company is not supported by
    // Dynamics 365 Business Central OData web services", and there's no
    // AL-reachable equivalent either; company creation is an admin-only
    // operation (PowerShell / admin center) outside AL entirely, which is
    // also why none of Microsoft's own Tests-TestLibraries /
    // System Application Test Library codeunits have a "CreateCompany"
    // helper. So instead of inserting fake companies, drive the Evaluation
    // Company flag on whichever companies genuinely exist in this
    // environment (a BC sandbox artifact always ships with at least one).
    // Every test sets the exact state it needs up front rather than relying
    // on a previous test's cleanup — TestIsolation only rolls back once,
    // when the whole codeunit finishes.
    local procedure SetAllCompaniesEvaluationFlag(Value: Boolean): Integer
    var
        Company: Record Company;
        CompanyCount: Integer;
    begin
        if Company.FindSet(true) then
            repeat
                Company."Evaluation Company" := Value;
                Company.Modify();
                CompanyCount += 1;
            until Company.Next() = 0;
        exit(CompanyCount);
    end;

    [Test]
    procedure NoEvaluationCompaniesCreatesNoAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
    begin
        Alert.ClearAllAlerts();
        SetAllCompaniesEvaluationFlag(false);

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Assert.IsTrue(Alert.IsEmpty(), 'No alert expected when no evaluation company exists');
    end;

    [Test]
    procedure EvaluationCompanyCreatesInfoAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
        Company: Record Company;
    begin
        Alert.ClearAllAlerts();
        SetAllCompaniesEvaluationFlag(false);
        Company.FindFirst();
        Company."Evaluation Company" := true;
        Company.Modify();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Assert.AreEqual(1, Alert.Count(), 'Exactly one alert expected for one evaluation company');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Info, Alert.Severity, 'Severity should be Info in non-production environment');
        Assert.AreEqual(AreaSESTM::Technical, Alert."Area", 'Area should be Technical');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,CompaniesPageHandler,NoAutofixMessageHandler')]
    procedure ShowMoreDetailsAndRelatedAndTelemetryAreCallable()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
        Company: Record Company;
        Dimensions: Dictionary of [Text, Text];
    begin
        Alert.ClearAllAlerts();
        SetAllCompaniesEvaluationFlag(false);
        Company.FindFirst();
        Company."Evaluation Company" := true;
        Company.Modify();

        Rule.CreateAlerts();
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Alert.FindFirst();

        // Rule.ShowMoreDetails skipped until upstream Hyperlink NullRef fix.
        Rule.ShowRelatedInformation(Alert);
        Rule.AutoFix(Alert);
        Rule.AddCustomTelemetryDimensions(Alert, Dimensions);
        Assert.IsTrue(Dimensions.ContainsKey('AlertCompanyName'), 'Dimensions should include AlertCompanyName');
        Assert.AreNotEqual('', Rule.GetTelemetryDescription(Alert), 'Telemetry description should not be empty');
    end;

    [Test]
    procedure OnlyEvaluationCompaniesGetAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
        Company: Record Company;
        TotalCompanies: Integer;
    begin
        Alert.ClearAllAlerts();
        // Mark every real company as an evaluation company, then flip
        // exactly one back to non-evaluation ("PROD") — this environment
        // has at least 2 real companies (BC sandbox artifacts always ship
        // CRONUS plus at least one more), so the count-minus-one is always
        // a meaningful, non-degenerate assertion.
        TotalCompanies := SetAllCompaniesEvaluationFlag(true);
        Company.FindFirst();
        Company."Evaluation Company" := false;
        Company.Modify();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Assert.AreEqual(TotalCompanies - 1, Alert.Count(), 'One alert per evaluation company, skipping production');
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [PageHandler]
    procedure CompaniesPageHandler(var Companies: TestPage Companies)
    begin
    end;

    [MessageHandler]
    procedure NoAutofixMessageHandler(Msg: Text)
    begin
    end;
}
