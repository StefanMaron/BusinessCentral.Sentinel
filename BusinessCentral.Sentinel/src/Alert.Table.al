namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;

/// <summary>
/// This table is used to store all the alerts that are generated by the system
/// </summary>
table 71180275 AlertSESTM
{
    Access = Internal;
    Caption = 'Alert';
    DataClassification = SystemMetadata;
    DrillDownPageId = AlertListSESTM;
    Extensible = false;
    LookupPageId = AlertListSESTM;
    Permissions =
        tabledata AlertSESTM = RID,
        tabledata IgnoredAlertsSESTM = RID,
        tabledata SentinelRuleSetSESTM = R,
        tabledata SentinelSetup = R;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'ID';
            NotBlank = true;
            ToolTip = 'The unique identifier for the alert.';

        }
        field(2; AlertCode; Enum "AlertCodeSESTM")
        {
            Caption = 'Code';

            NotBlank = true;
            ToolTip = 'The code representing the type of alert.';
        }
        field(3; ShortDescription; Text[100])
        {
            Caption = 'Short Description';
            ToolTip = 'A brief description of the alert.';

        }
        field(4; LongDescription; Text[2048])
        {
            Caption = 'Long Description';
            ToolTip = 'A detailed description of the alert.';

        }
        field(5; Severity; Enum SeveritySESTM)
        {
            Caption = 'Severity';
            ToolTip = 'The severity level of the alert.';

        }
        field(6; ActionRecommendation; Text[1024])
        {
            Caption = 'Action Recommendation';
            ToolTip = 'Recommended actions to take in response to the alert.';

        }
        field(7; "Area"; Enum AreaSESTM)
        {
            Caption = 'Area';
            ToolTip = 'The area or module where the alert is relevant.';

        }

        /// <summary>
        /// This is the unique Guid for a specific warning per Alert Code, not a an ID for the Alert Code. 
        /// Its used to allow the user to mark a warning as read
        /// </summary>
        field(8; UniqueIdentifier; Text[100])
        {
            AllowInCustomizations = Always;
            Caption = 'Unique Identifier';
            ToolTip = 'A unique identifier for a specific warning per alert code.';
        }
        field(9; Ignore; Boolean)
        {
            CalcFormula = exist(IgnoredAlertsSESTM where(AlertCode = field(AlertCode), UniqueIdentifier = field(UniqueIdentifier)));
            Caption = 'Ignore';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Indicates whether the alert should be ignored.';
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(UniqueId; AlertCode, UniqueIdentifier) { }
    }

    trigger OnInsert()
    var
        Setup: Record SentinelSetup;
    begin
        if not NumberSequence.Exists('BCSentinelSESTMAlertId') then
            NumberSequence.Insert('BCSentinelSESTMAlertId');

        Rec.Id := NumberSequence.Next('BCSentinelSESTMAlertId');

        if Setup.GetTelemetryLoggingSetting(Rec.AlertCode) = Setup.TelemetryLogging::OnRuleLogging then
            this.LogUsage();
    end;

    procedure FindNewAlerts()
    var
        currOrdinal: Integer;
        Alert: Interface IAuditAlertSESTM;
        AlertsToRun: List of [Interface IAuditAlertSESTM];
    begin
        foreach currOrdinal in Enum::AlertCodeSESTM.Ordinals() do
            AlertsToRun.Add(Enum::AlertCodeSESTM.FromInteger(currOrdinal));

        // TODO: add event to allow other extensions to add Alerts

        foreach Alert in AlertsToRun do
            Alert.CreateAlerts();

        if not Rec.FindFirst() then
        ; // Move to the first record, after Alert creation. If no alerts where created, do nothing
    end;

    procedure SetToIgnore()
    var
        IgnoredAlerts: Record IgnoredAlertsSESTM;
    begin
        if Rec.Ignore then
            exit;

        IgnoredAlerts.Validate(AlertCode, Rec.AlertCode);
        IgnoredAlerts.Validate(UniqueIdentifier, Rec.UniqueIdentifier);
        if not IgnoredAlerts.Insert(true) then
            exit;
    end;

    procedure ClearIgnore()
    var
        IgnoredAlerts: Record IgnoredAlertsSESTM;
    begin
        if not Rec.Ignore then
            exit;

        IgnoredAlerts.SetRange(AlertCode, Rec.AlertCode);
        IgnoredAlerts.SetRange(UniqueIdentifier, Rec.UniqueIdentifier);
        if not IgnoredAlerts.IsEmpty() then
            IgnoredAlerts.DeleteAll(true);
    end;

    procedure FullRerun()
    var
        Alert: Record AlertSESTM;
    begin
        Alert.ClearAllAlerts();
        Commit(); // Commit the transaction to ensure that the alerts are deleted before they are recreated
        Alert.FindNewAlerts();
    end;

    procedure ClearAllAlerts()
    begin
        Rec.DeleteAll(true);

        if NumberSequence.Exists('BCSentinelSESTMAlertId') then
            NumberSequence.Restart('BCSentinelSESTMAlertId');
    end;

    /// <summary>
    /// This function is used to create a new alert in the system. It will only create the alert if it does not already exist.
    /// </summary>
    /// <param name="AlertCodeIn">The alert code to create the alert for.</param>
    /// <param name="ShortDescriptionIn">A brief description of what the issue is.</param>
    /// <param name="SeverityIn">The severity of the alert</param>
    /// <param name="AreaIn">The area of the alert.</param>
    /// <param name="LongDescriptionIn">A longer description of what the issue is.</param>
    /// <param name="ActionRecommendationIn">A description of how to resolve the issue.</param>
    /// <param name="UniqueIdentifierIn">Any value that can distinguish different alerts within the same Alert code.</param>
    procedure New(AlertCodeIn: Enum "AlertCodeSESTM"; ShortDescriptionIn: Text; SeverityIn: Enum SeveritySESTM; AreaIn: Enum AreaSESTM; LongDescriptionIn: Text; ActionRecommendationIn: Text; UniqueIdentifierIn: Text[100])
    var
        Alert: Record AlertSESTM;
        SentinelRuleSet: Record SentinelRuleSetSESTM;
        CurrSeverity: Enum SeveritySESTM;
    begin
        SentinelRuleSet.ReadIsolation(IsolationLevel::ReadUncommitted);

        if SentinelRuleSet.Get(AlertCodeIn) and (SentinelRuleSet.Severity <> SentinelRuleSet.Severity::" ") then
            CurrSeverity := SentinelRuleSet.Severity
        else
            CurrSeverity := SeverityIn;

        if CurrSeverity = Severity::Disabled then
            exit;

        Alert.SetRange(AlertCode, AlertCodeIn);
        Alert.SetRange("UniqueIdentifier", UniqueIdentifierIn);
        Alert.ReadIsolation(IsolationLevel::ReadUncommitted);
        if not Alert.IsEmpty() then
            exit;

        Alert.Validate(AlertCode, AlertCodeIn);
        Alert.Validate(ShortDescription, CopyStr(ShortDescriptionIn, 1, MaxStrLen(Alert.ShortDescription)));
        Alert.Validate(Severity, CurrSeverity);
        Alert.Validate("Area", AreaIn);
        Alert.Validate(LongDescription, CopyStr(LongDescriptionIn, 1, MaxStrLen(Alert.LongDescription)));
        Alert.Validate(ActionRecommendation, CopyStr(ActionRecommendationIn, 1, MaxStrLen(Alert.ActionRecommendation)));
        Alert.Validate(UniqueIdentifier, UniqueIdentifierIn);
        Alert.Insert(true);
    end;

    internal procedure LogUsage()
    var
        TelemetryHelper: Codeunit TelemetryHelperSESTM;
        CustomDimensions: Dictionary of [Text, Text];
        Alert: Interface IAuditAlertSESTM;
    begin
        CustomDimensions.Add('AlertSeverity', Format(Rec.Severity));
        CustomDimensions.Add('AlertArea', Format(Rec."Area"));
        Rec.CalcFields(Ignore);
        CustomDimensions.Add('AlertIgnore', Format(Rec.Ignore));

        Alert := Rec.AlertCode;
        Alert.AddCustomTelemetryDimensions(Rec, CustomDimensions);

        TelemetryHelper.LogUsage(Rec.AlertCode, Alert.GetTelemetryDescription(Rec), CustomDimensions);
    end;
}