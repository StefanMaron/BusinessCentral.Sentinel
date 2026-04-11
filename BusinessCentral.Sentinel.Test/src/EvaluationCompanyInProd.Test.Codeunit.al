namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using Microsoft.Foundation.Company;

codeunit 71180501 EvalCompanyInProdTestSESTM
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure NoEvaluationCompaniesCreatesNoAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
        Company: Record Company;
    begin
        Company.Name := 'PROD';
        Company."Evaluation Company" := false;
        Company.Insert();

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
        Company.Name := 'EVAL';
        Company."Evaluation Company" := true;
        Company.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Assert.AreEqual(1, Alert.Count(), 'Exactly one alert expected for one evaluation company');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Info, Alert.Severity, 'Severity should be Info in non-production environment');
        Assert.AreEqual(AreaSESTM::Technical, Alert."Area", 'Area should be Technical');
    end;

    [Test]
    procedure OnlyEvaluationCompaniesGetAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit EvaluationCompanyInProdSESTM;
        Company: Record Company;
    begin
        Company.Name := 'PROD';
        Company.SystemId := '00000000-0000-0000-0000-000000000001';
        Company."Evaluation Company" := false;
        Company.Insert();

        Company.Init();
        Company.Name := 'EVAL1';
        Company.SystemId := '00000000-0000-0000-0000-000000000002';
        Company."Evaluation Company" := true;
        Company.Insert();

        Company.Init();
        Company.Name := 'EVAL2';
        Company.SystemId := '00000000-0000-0000-0000-000000000003';
        Company."Evaluation Company" := true;
        Company.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Assert.AreEqual(2, Alert.Count(), 'One alert per evaluation company, skipping production');
    end;
}
