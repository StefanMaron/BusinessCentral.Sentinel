namespace STM.BusinessCentral.Sentinel;

using Microsoft.Foundation.NoSeries;
using Microsoft.Projects.Project.Setup;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Setup;
using STM.BusinessCentral.Sentinel;

codeunit 71180281 NonPostNoSeriesGapsSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata "Jobs Setup" = r,
        tabledata "No. Series" = R,
        tabledata "No. Series Line" = R,
        tabledata "Purchases & Payables Setup" = R,
        tabledata "Sales & Receivables Setup" = R;

    procedure CreateAlerts()
    begin
        this.CheckSalesSetup();
        this.CheckPurchaseSetup();
        this.CheckJobsSetup();
    end;

    local procedure CheckPurchaseSetup()
    var
        PurchaseSetup: Record "Purchases & Payables Setup";
    begin
        PurchaseSetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        PurchaseSetup.SetLoadFields("Order Nos.", "Invoice Nos.", "Credit Memo Nos.", "Quote Nos.", "Vendor Nos.", "Blanket Order Nos.", "Price List Nos.", "Return Order Nos.");
        if not PurchaseSetup.Get() then
            exit;

        this.CheckNoSeries(PurchaseSetup."Order Nos.");
        this.CheckNoSeries(PurchaseSetup."Invoice Nos.");
        this.CheckNoSeries(PurchaseSetup."Credit Memo Nos.");
        this.CheckNoSeries(PurchaseSetup."Quote Nos.");
        this.CheckNoSeries(PurchaseSetup."Vendor Nos.");
        this.CheckNoSeries(PurchaseSetup."Blanket Order Nos.");
        this.CheckNoSeries(PurchaseSetup."Price List Nos.");
        this.CheckNoSeries(PurchaseSetup."Return Order Nos.");
    end;

    local procedure CheckSalesSetup()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        SalesSetup.SetLoadFields("Order Nos.", "Invoice Nos.", "Credit Memo Nos.", "Quote Nos.", "Customer Nos.", "Blanket Order Nos.", "Reminder Nos.", "Fin. Chrg. Memo Nos.", "Direct Debit Mandate Nos.", "Price List Nos.");
        if not SalesSetup.Get() then
            exit;

        this.CheckNoSeries(SalesSetup."Order Nos.");
        this.CheckNoSeries(SalesSetup."Invoice Nos.");
        this.CheckNoSeries(SalesSetup."Credit Memo Nos.");
        this.CheckNoSeries(SalesSetup."Quote Nos.");
        this.CheckNoSeries(SalesSetup."Customer Nos.");
        this.CheckNoSeries(SalesSetup."Blanket Order Nos.");
        this.CheckNoSeries(SalesSetup."Reminder Nos.");
        this.CheckNoSeries(SalesSetup."Fin. Chrg. Memo Nos.");
        this.CheckNoSeries(SalesSetup."Direct Debit Mandate Nos.");
        this.CheckNoSeries(SalesSetup."Price List Nos.");
    end;

    local procedure CheckJobsSetup()
    var
        JobsSetup: Record "Jobs Setup";
    begin
        JobsSetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        JobsSetup.SetLoadFields("Job Nos.", "Price List Nos.");
        if not JobsSetup.Get() then
            exit;

        this.CheckNoSeries(JobsSetup."Job Nos.");
        this.CheckNoSeries(JobsSetup."Price List Nos.");
    end;

    local procedure CheckNoSeries(NoSeriesCode: Code[20])
    var
        Alert: Record AlertSESTM;
        NoSeriesLine: Record "No. Series Line";
        NoSeriesSingle: Interface "No. Series - Single";
        ActionRecommendationLbl: Label 'Change No Series %1 to allow gaps', Comment = '%1 = No. Series Code';
        LongDescLbl: Label 'The No. Series %1 does not allow gaps and is responsible for non-posting documents/records. Consider configuring the No. Series to allow gaps to increase performance and decrease locking.', Comment = '%1 = No. Series Code';
        ShortDescLbl: Label 'No Series %1 does not allow gaps', Comment = '%1 = No. Series Code';
    begin
        if NoSeriesCode = '' then
            exit;

        NoSeriesLine.SetRange("Series Code", NoSeriesCode);
        if NoSeriesLine.FindSet() then
            repeat
                NoSeriesSingle := NoSeriesLine.Implementation;
                if not NoSeriesSingle.MayProduceGaps() then
                    Alert.New(
                        AlertCodeSESTM::"SE-000006",
                        StrSubstNo(ShortDescLbl, NoSeriesCode),
                        SeveritySESTM::Warning,
                        AreaSESTM::Performance,
                        StrSubstNo(LongDescLbl, NoSeriesCode),
                        StrSubstNo(ActionRecommendationLbl, NoSeriesCode),
                        NoSeriesCode
                    );
            until NoSeriesLine.Next() = 0;
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000006', Locked = true;
    begin
        Hyperlink(WikiLinkTok);
    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    var
        NoSeries: Record "No. Series";
        OpenRecordQst: Label 'Do you want to open the No. Series %1?', Comment = '%1 = No. Series Code';
    begin
        if not Confirm(StrSubstNo(OpenRecordQst, Alert.UniqueIdentifier)) then
            exit;

        NoSeries.SetRange("Code", Alert.UniqueIdentifier);
        Page.Run(Page::"No. Series", NoSeries);
    end;


    procedure AutoFix(var Alert: Record AlertSESTM)
    var
        NoAutofixAvailableLbl: Label 'No autofix available for this alert. (SE-000006)';
    begin
        Message(NoAutofixAvailableLbl);
        // TODO: Implement AutoFix
    end;

    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])
    begin
        CustomDimensions.Add('AlertNoSeriesCode', Alert.UniqueIdentifier);
    end;

    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text
    begin
        exit(Alert.ShortDescription);
    end;
}