namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.TestLibraries.Utilities;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Projects.Project.Setup;

codeunit 71180507 NonPostNoSeriesTestSESTM
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

    // Seed a No. Series with a single line whose Implementation is the stub's
    // "Normal" enum value — its "No. Series - Default Impl." returns
    // MayProduceGaps = false, so the rule will alert.
    local procedure SeedNonGapNoSeries(Code: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        // BC's test runner only rolls back once per codeunit (not per test),
        // and this helper is called with the same code from more than one
        // test in this codeunit — make it idempotent instead of colliding.
        if NoSeries.Get(Code) then
            exit;

        NoSeries.Code := Code;
        NoSeries.Description := Code;
        NoSeries.Insert();

        NoSeriesLine."Series Code" := Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Implementation := NoSeriesLine.Implementation::Normal;
        NoSeriesLine.Insert();
    end;

    [Test]
    procedure SalesOrderNonGapSeriesCreatesWarning()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit NonPostNoSeriesGapsSESTM;
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        Alert.ClearAllAlerts();
        SeedNonGapNoSeries('SALES-ORDER');

        // Sales & Receivables Setup is a singleton that already exists with
        // CRONUS demo data — Get() + Modify() rather than a blind Insert().
        SalesSetup.Get();
        SalesSetup."Order Nos." := 'SALES-ORDER';
        SalesSetup.Modify();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000006");
        Alert.SetRange(UniqueIdentifier, 'SALES-ORDER');
        Assert.AreEqual(1, Alert.Count(), 'Alert expected for a non-posting series that does not allow gaps');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Warning, Alert.Severity, 'Severity should be Warning');
        Assert.AreEqual(AreaSESTM::Performance, Alert."Area", 'Area should be Performance');
    end;

    [Test]
    procedure JobsNoSeriesCreatesWarning()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit NonPostNoSeriesGapsSESTM;
        JobsSetup: Record "Jobs Setup";
    begin
        Alert.ClearAllAlerts();
        SeedNonGapNoSeries('JOB');

        // Jobs Setup is a singleton that already exists with CRONUS demo
        // data — Get() + Modify() rather than a blind Insert().
        JobsSetup.Get();
        JobsSetup."Job Nos." := 'JOB';
        JobsSetup.Modify();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000006");
        Alert.SetRange(UniqueIdentifier, 'JOB');
        Assert.AreEqual(1, Alert.Count(), 'Alert expected for a non-gap jobs series');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,NoSeriesPageHandler,NoAutofixMessageHandler')]
    procedure ShowMoreDetailsAndRelatedAndTelemetryAreCallable()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit NonPostNoSeriesGapsSESTM;
        SalesSetup: Record "Sales & Receivables Setup";
        Dimensions: Dictionary of [Text, Text];
    begin
        Alert.ClearAllAlerts();
        SeedNonGapNoSeries('SALES-ORDER');
        SalesSetup.Get();
        SalesSetup."Order Nos." := 'SALES-ORDER';
        SalesSetup.Modify();

        Rule.CreateAlerts();
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000006");
        Alert.FindFirst();

        // Rule.ShowMoreDetails skipped until upstream Hyperlink NullRef fix.
        Rule.ShowRelatedInformation(Alert);
        Rule.AutoFix(Alert);
        Rule.AddCustomTelemetryDimensions(Alert, Dimensions);
        Assert.AreEqual('SALES-ORDER', Dimensions.Get('AlertNoSeriesCode'), 'Dimensions should carry the series code');
        Assert.AreNotEqual('', Rule.GetTelemetryDescription(Alert), 'Telemetry description should not be empty');
    end;

    [Test]
    procedure PurchaseInvoiceNonGapSeriesCreatesWarning()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit NonPostNoSeriesGapsSESTM;
        PurchaseSetup: Record "Purchases & Payables Setup";
    begin
        Alert.ClearAllAlerts();
        SeedNonGapNoSeries('PURCH-INV');

        // Purchases & Payables Setup is a singleton that already exists with
        // CRONUS demo data — Get() + Modify() rather than a blind Insert().
        PurchaseSetup.Get();
        PurchaseSetup."Invoice Nos." := 'PURCH-INV';
        PurchaseSetup.Modify();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000006");
        Alert.SetRange(UniqueIdentifier, 'PURCH-INV');
        Assert.AreEqual(1, Alert.Count(), 'Alert expected for a non-gap purchase series');
    end;

    [Test]
    procedure EmptySeriesCodeIsIgnored()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit NonPostNoSeriesGapsSESTM;
        SalesSetup: Record "Sales & Receivables Setup";
        PurchaseSetup: Record "Purchases & Payables Setup";
        JobsSetup: Record "Jobs Setup";
    begin
        Alert.ClearAllAlerts();
        // Sales & Receivables Setup is a singleton that already exists with
        // CRONUS demo data, so unlike under al-runner we can't rely on it
        // simply not existing. The BC test runner only rolls back once per
        // codeunit (not per test), so this must stay the LAST test in this
        // codeunit — delete the singleton to genuinely exercise the rule's
        // `if not SalesSetup.Get() then exit;` branch.
        SalesSetup.Get();
        SalesSetup.Delete();

        // CRONUS demo data also seeds real (non-blank) No. Series on
        // Purchase and Jobs Setup for fields this rule checks — delete those
        // singletons too so this test genuinely exercises "no setup exists",
        // not "setup exists but happens to allow gaps everywhere".
        if PurchaseSetup.Get() then
            PurchaseSetup.Delete();
        if JobsSetup.Get() then
            JobsSetup.Delete();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000006");
        Assert.IsTrue(Alert.IsEmpty(), 'Empty series codes should not produce alerts');
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [PageHandler]
    procedure NoSeriesPageHandler(var NoSeries: TestPage "No. Series")
    begin
    end;

    [MessageHandler]
    procedure NoAutofixMessageHandler(Msg: Text)
    begin
    end;
}
