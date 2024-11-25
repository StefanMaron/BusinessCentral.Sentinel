namespace STM.BusinessCentral.Sentinel;

using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;
using Microsoft.Sales.Setup;
using STM.BusinessCentral.Sentinel;

codeunit 71180281 NonPostNoSeriesGapsSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata "No. Series" = R,
        tabledata "No. Series Line" = R,
        tabledata "Purchases & Payables Setup" = R,
        tabledata "Sales & Receivables Setup" = R;

    procedure CreateAlerts()
    begin
        CheckSalesSetup();
        CheckPurchaseSetup();
    end;

    local procedure CheckPurchaseSetup()
    var
        PurchaseSetup: Record "Purchases & Payables Setup";
    begin
        PurchaseSetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        PurchaseSetup.SetLoadFields("Order Nos.", "Invoice Nos.", "Credit Memo Nos.", "Quote Nos.", "Vendor Nos.", "Blanket Order Nos.", "Price List Nos.", "Return Order Nos.");
        if not PurchaseSetup.Get() then
            exit;

        CheckNoSeries(PurchaseSetup."Order Nos.");
        CheckNoSeries(PurchaseSetup."Invoice Nos.");
        CheckNoSeries(PurchaseSetup."Credit Memo Nos.");
        CheckNoSeries(PurchaseSetup."Quote Nos.");
        CheckNoSeries(PurchaseSetup."Vendor Nos.");
        CheckNoSeries(PurchaseSetup."Blanket Order Nos.");
        CheckNoSeries(PurchaseSetup."Price List Nos.");
        CheckNoSeries(PurchaseSetup."Return Order Nos.");
    end;

    local procedure CheckSalesSetup()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        SalesSetup.SetLoadFields("Order Nos.", "Invoice Nos.", "Credit Memo Nos.", "Quote Nos.", "Customer Nos.", "Blanket Order Nos.", "Reminder Nos.", "Fin. Chrg. Memo Nos.", "Direct Debit Mandate Nos.", "Price List Nos.");
        if not SalesSetup.Get() then
            exit;

        CheckNoSeries(SalesSetup."Order Nos.");
        CheckNoSeries(SalesSetup."Invoice Nos.");
        CheckNoSeries(SalesSetup."Credit Memo Nos.");
        CheckNoSeries(SalesSetup."Quote Nos.");
        CheckNoSeries(SalesSetup."Customer Nos.");
        CheckNoSeries(SalesSetup."Blanket Order Nos.");
        CheckNoSeries(SalesSetup."Reminder Nos.");
        CheckNoSeries(SalesSetup."Fin. Chrg. Memo Nos.");
        CheckNoSeries(SalesSetup."Direct Debit Mandate Nos.");
        CheckNoSeries(SalesSetup."Price List Nos.");
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
        NoSeriesLine.SetRange("Series Code", NoSeriesCode);
        if NoSeriesLine.FindSet() then
            repeat
                NoSeriesSingle := NoSeriesLine.Implementation;
                if not NoSeriesSingle.MayProduceGaps() then begin
                    Alert.SetRange("AlertCode", AlertCodeSESTM::"SE-000006");
                    Alert.SetRange(UniqueIdentifier, NoSeriesCode);
                    if Alert.IsEmpty() then begin
                        Alert.Validate(AlertCode, "AlertCodeSESTM"::"SE-000006");
                        Alert.Validate("ShortDescription", StrSubstNo(ShortDescLbl, NoSeriesCode));
                        Alert.Validate(Severity, SeveritySESTM::Warning);
                        Alert.Validate("Area", AreaSESTM::Performance);
                        Alert.Validate(LongDescription, StrSubstNo(LongDescLbl, NoSeriesCode));
                        Alert.Validate(ActionRecommendation, StrSubstNo(ActionRecommendationLbl, NoSeriesCode));
                        Alert.Validate(UniqueIdentifier, NoSeriesCode);
                        Alert.Insert(true);
                    end;
                end;
            until NoSeriesLine.Next() = 0;
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    begin
        // TODO: Implement Detailed description
    end;

    procedure RunActionRecommendations(var Alert: Record AlertSESTM)
    var
        NoSeries: Record "No. Series";
        OpenRecordQst: Label 'Do you want to open the No. Series %1?', Comment = '%1 = No. Series Code';
    begin
        if not Confirm(StrSubstNo(OpenRecordQst, Alert.UniqueIdentifier)) then
            exit;

        NoSeries.SetRange("Code", Alert.UniqueIdentifier);
        Page.Run(Page::"No. Series", NoSeries);
    end;
}