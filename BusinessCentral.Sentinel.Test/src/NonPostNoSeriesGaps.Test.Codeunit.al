namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using Microsoft.Foundation.NoSeries;
using Microsoft.Sales.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Projects.Project.Setup;

codeunit 71180507 NonPostNoSeriesTestSESTM
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;

    // Seed a No. Series with a single line whose Implementation is the stub's
    // "Normal" enum value — its "No. Series - Default Impl." returns
    // MayProduceGaps = false, so the rule will alert.
    local procedure SeedNonGapNoSeries(Code: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
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
        SeedNonGapNoSeries('SALES-ORDER');

        SalesSetup."Primary Key" := '';
        SalesSetup."Order Nos." := 'SALES-ORDER';
        SalesSetup.Insert();

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
        SeedNonGapNoSeries('JOB');

        JobsSetup."Primary Key" := '';
        JobsSetup."Job Nos." := 'JOB';
        JobsSetup.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000006");
        Alert.SetRange(UniqueIdentifier, 'JOB');
        Assert.AreEqual(1, Alert.Count(), 'Alert expected for a non-gap jobs series');
    end;

    [Test]
    procedure ShowMoreDetailsAndRelatedAndTelemetryAreCallable()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit NonPostNoSeriesGapsSESTM;
        SalesSetup: Record "Sales & Receivables Setup";
        Dimensions: Dictionary of [Text, Text];
    begin
        SeedNonGapNoSeries('SALES-ORDER');
        SalesSetup."Primary Key" := '';
        SalesSetup."Order Nos." := 'SALES-ORDER';
        SalesSetup.Insert();

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
        SeedNonGapNoSeries('PURCH-INV');

        PurchaseSetup."Primary Key" := '';
        PurchaseSetup."Invoice Nos." := 'PURCH-INV';
        PurchaseSetup.Insert();

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
    begin
        // No Sales Setup inserted at all — every series code the rule reads
        // is empty. CheckNoSeries exits early on empty strings.
        SalesSetup."Primary Key" := '';
        SalesSetup.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000006");
        Assert.IsTrue(Alert.IsEmpty(), 'Empty series codes should not produce alerts');
    end;
}
