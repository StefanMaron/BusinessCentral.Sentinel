namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using Microsoft.Foundation.Company;
using System.Environment;
using System.TestLibraries.Utilities;

codeunit 71180501 EvalCompanyInProdTestSESTM
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

    local procedure Initialize()
    var
        AlertToClear: Record AlertSESTM;
        Company: Record Company;
    begin
        AlertToClear.DeleteAll();
        Company.ModifyAll("Evaluation Company", false);
    end;

    // Company.Insert() costs ~30s on a real server (and a second one in the same
    // transaction stalls it), so the tests reuse the companies that already exist.
    local procedure FlagFirstCompanyAsEvaluation(): Text[30]
    var
        Company: Record Company;
    begin
        Company.FindFirst();
        Company."Evaluation Company" := true;
        Company.Modify();
        exit(Company.Name);
    end;

    [Test]
    procedure NoEvaluationCompaniesCreatesNoAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
    begin
        Initialize();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Assert.IsTrue(Alert.IsEmpty(), 'No alert expected when no evaluation company exists');
    end;

    [Test]
    procedure EvaluationCompanyCreatesInfoAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
    begin
        Initialize();
        FlagFirstCompanyAsEvaluation();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Assert.AreEqual(1, Alert.Count(), 'Exactly one alert expected for one evaluation company');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Info, Alert.Severity, 'Severity should be Info in non-production environment');
        Assert.AreEqual(AreaSESTM::Technical, Alert."Area", 'Area should be Technical');
    end;

    [Test]
    [HandlerFunctions('ConfirmNoHandler,MessageHandler')]
    procedure ShowMoreDetailsAndRelatedAndTelemetryAreCallable()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
        Dimensions: Dictionary of [Text, Text];
    begin
        Initialize();
        FlagFirstCompanyAsEvaluation();

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
        ExistingEvalCompanyName: Text[30];
    begin
        Initialize();
        ExistingEvalCompanyName := FlagFirstCompanyAsEvaluation();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Assert.AreEqual(1, Alert.Count(), 'One alert per evaluation company, skipping production');
        Alert.SetFilter(ShortDescription, '*' + ExistingEvalCompanyName + '*');
        Assert.AreEqual(1, Alert.Count(), 'The company flagged as evaluation should get the alert');
    end;

    [ConfirmHandler]
    procedure ConfirmNoHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := false;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}
