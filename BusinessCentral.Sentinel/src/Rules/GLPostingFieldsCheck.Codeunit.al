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
        GLSetUp2: Record "General Ledger Setup";
        ActionRecommendationLbl: Label 'Ensure that an appropriate date value is entered in both the "Allow Posting From" and "Allow Posting To" fields on the General Ledger Setup page.';
        LongDescLbl: Label 'The "Allow Posting From" and/or the "Allow Posting To" date does not have a value in the General Ledger Setup page.  Both of these dates should always be populated to ensure that transactions are not accidentally posted to a prior fiscal period or future fiscal period.  These dates restrict posting for all users in the Company.  User specific allowed posting dates can be set on the User Setup page.';
        ShortDescLbl: Label 'Verify that General Ledger Setup "Allow Posting" date fields are configured';

    begin
        GLSetUp2.Get();
        if (GLSetUp2."Allow Posting From" = 0D) and (GLSetUp2."Allow Posting To" = 0D) then
            Alert.New(
                AlertCodeSESTM::"SE-000009",
                ShortDescLbl,
                SeveritySESTM::Warning,
                AreaSESTM::Configuration,
                LongDescLbl,
                ActionRecommendationLbl,
               'SE-000009-1'
            )
        else
            this.GenerateSecondAlert();

    end;


    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    begin

    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    var
        OpenGeneralPageQst: Label 'Do you want to open the "General Ledger Set Up" table?';
    begin
        if Confirm(OpenGeneralPageQst) then
            Page.Run(Page::"General Ledger Setup");

    end;

    //GeneratedSecordAlert procedure generate alert if one of the fields
    //Allow Posting From/To set a date value greater than 60 days 
    procedure GenerateSecondAlert()
    var
        Alert: Record AlertSESTM;
        GeneralTable: Record "General Ledger Setup";
        ActionRecommendation2Lbl: Label 'Please review the "%1" field, in the "General Ledger Setup" table. Considerer setting the date to 60 days or less from the current Date', Comment = '%1 = Allow Posting Fields ';
        ShortDes2Lbl: Label 'General Ledger Setup "Allow Posting" date fields exceed 60 days from the current date.';
        LongDesc2Lbl: Label 'Currently, the "%1" field, is set to a date that exceeds 60 days from the current date. To avoid posting transactions outside of closed or future fiscal periods, please considerer adjusting the date to a maximum of 60 days from the current date. \ %1\Current Date Value: %2 \Number of Days: %3', Comment = ' %1 = Allow Posting Fields; %2 = Date Value; %3 = Number of Days';
        TodayDate: Date;
        DurationFrom: Integer;
        DurationTo: Integer;
        FieldName: Text;
        DateValue: Date;

    begin
        GeneralTable.Get();
        TodayDate := Today;
        DurationFrom := TodayDate - GeneralTable."Allow Posting From";
        DurationTo := Abs(GeneralTable."Allow Posting To" - TodayDate);

        if (DurationFrom > 60) then begin
            FieldName := GeneralTable.FieldCaption("Allow Posting From");
            DateValue := GeneralTable."Allow Posting From";
            Alert.New(
                AlertCodeSESTM::"SE-000009",
                ShortDes2Lbl,
                SeveritySESTM::Warning,
                AreaSESTM::Configuration,
                StrSubstNo(LongDesc2Lbl, FieldName, DateValue, DurationFrom),
                StrSubstNo(ActionRecommendation2Lbl, FieldName),
                'SE-000009-2'
            );
        end;


        if (Abs(DurationTo) > 60) then begin
            FieldName := GeneralTable.FieldCaption("Allow Posting To");
            DateValue := GeneralTable."Allow Posting To";
            Alert.New(
                AlertCodeSESTM::"SE-000009",
                ShortDes2Lbl,
                SeveritySESTM::Warning,
                AreaSESTM::Configuration,
                StrSubstNo(LongDesc2Lbl, FieldName, DateValue, DurationTo),
                StrSubstNo(ActionRecommendation2Lbl, FieldName),
                'SE-000009-3'
            );
        end;

    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    begin

    end;

    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])
    begin
        //No custom telemetry dimension to add.
    end;

    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text
    begin

    end;
}