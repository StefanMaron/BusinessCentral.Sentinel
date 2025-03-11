namespace STM.BusinessCentral.Sentinel;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 71180300 GLPostingFieldsCheckSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI,
        tabledata "General Ledger Setup" = R;

    procedure CreateAlerts()
    var
        Alert: Record AlertSESTM;
        GeneralLedgerSetup: Record "General Ledger Setup";
        ActionRecommendationLbl: Label 'Ensure that an appropriate date value is entered in both the "Allow Posting From" and "Allow Posting To" fields on the General Ledger Setup page.';
        LongDescLbl: Label 'The "Allow Posting From" and/or the "Allow Posting To" date does not have a value in the General Ledger Setup page.  Both of these dates should always be populated to ensure that transactions are not accidentally posted to a prior fiscal period or future fiscal period.  These dates restrict posting for all users in the Company.  User specific allowed posting dates can be set on the User Setup page.';
        ShortDescLbl: Label 'Verify that General Ledger Setup "Allow Posting" date fields are configured';
    begin
        GeneralLedgerSetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        GeneralLedgerSetup.SetLoadFields("Allow Posting From", "Allow Posting To");

        if (not GeneralLedgerSetup.Get()) or ((GeneralLedgerSetup."Allow Posting From" = 0D) and (GeneralLedgerSetup."Allow Posting To" = 0D)) then
            Alert.New(
                AlertCodeSESTM::"SE-000009",
                ShortDescLbl,
                SeveritySESTM::Warning,
                AreaSESTM::Configuration,
                LongDescLbl,
                ActionRecommendationLbl,
               ''
            )
        else
            this.GenerateSecondAlert();
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000009', Locked = true;
    begin
        Hyperlink(WikiLinkTok);
    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    var
        OpenGeneralPageQst: Label 'Do you want to open the "General Ledger Setup" table?';
    begin
        if Confirm(OpenGeneralPageQst) then
            Page.Run(Page::"General Ledger Setup");
    end;

    //GeneratedSecondAlert procedure generates alert if one of the fields
    //Allow Posting From/To is set to a date value greater than 60 days 
    procedure GenerateSecondAlert()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DurationFrom: Integer;
        DurationTo: Integer;
    begin
        GeneralLedgerSetup.ReadIsolation(IsolationLevel::ReadUncommitted);
        GeneralLedgerSetup.SetLoadFields("Allow Posting From", "Allow Posting To");
        if not GeneralLedgerSetup.Get() then exit;

        DurationFrom := Today() - GeneralLedgerSetup."Allow Posting From";
        DurationTo := Abs(GeneralLedgerSetup."Allow Posting To" - Today());

        if DurationFrom > 60 then
            this.SendAlert(DurationFrom, GeneralLedgerSetup.FieldCaption("Allow Posting From"), GeneralLedgerSetup."Allow Posting From");

        if DurationTo > 60 then
            this.SendAlert(DurationTo, GeneralLedgerSetup.FieldCaption("Allow Posting To"), GeneralLedgerSetup."Allow Posting To");
    end;

    local procedure SendAlert(Duration: Integer; FieldName: Text; DateValue: Date)
    var
        Alert: Record AlertSESTM;
        ActionRecommendation2Lbl: Label 'Please review the "%1" field, in the "General Ledger Setup" table. Consider setting the date to 60 days or less from the current Date', Comment = '%1 = Allow Posting Fields ';
        ShortDes2Lbl: Label 'General Ledger Setup "Allow Posting" date fields exceed 60 days from the current date.';
        LongDesc2Lbl: Label 'Currently, the "%1" field is set to a date that exceeds 60 days from the current date. To avoid posting transactions outside of closed or future fiscal periods, please consider adjusting the date to a maximum of 60 days from the current date. \ %1\Current Date Value: %2 \Number of Days: %3', Comment = ' %1 = Allow Posting Fields; %2 = Date Value; %3 = Number of Days';
    begin
        Alert.New(
            AlertCodeSESTM::"SE-000009",
            ShortDes2Lbl,
            SeveritySESTM::Warning,
            AreaSESTM::Configuration,
            StrSubstNo(LongDesc2Lbl, FieldName, DateValue, Duration),
            StrSubstNo(ActionRecommendation2Lbl, FieldName),
            ''
        );
    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    var
        NoAutofixAvailableLbl: Label 'No autofix available for this alert. (SE-000002)';
    begin
        Message(NoAutofixAvailableLbl);
    end;

    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])
    begin
        //No custom telemetry dimension to add.
    end;

    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text
    begin
        exit(Alert.ShortDescription);
    end;
}