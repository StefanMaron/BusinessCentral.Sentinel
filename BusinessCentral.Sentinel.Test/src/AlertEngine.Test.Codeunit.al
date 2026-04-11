namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;

/// <summary>
/// Exercises the core Alert engine (Alert.Table.al) in isolation:
///  * Alert.New() creates a record with the default severity
///  * Alert.New() honours a SentinelRuleSet severity override
///  * Alert.New() short-circuits when the effective severity is Disabled
///  * Alert.New() is idempotent per (AlertCode, UniqueIdentifier)
///  * SetToIgnore / ClearIgnore toggle the Ignore FlowField
///  * ClearAllAlerts wipes the table
/// </summary>
codeunit 71180500 AlertEngineTestSESTM
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure NewInsertsAlertWithDefaultSeverity()
    var
        Alert: Record AlertSESTM;
    begin
        Alert.New(
            "AlertCodeSESTM"::"SE-000001",
            'short',
            SeveritySESTM::Warning,
            AreaSESTM::Technical,
            'long',
            'action',
            'UID-1');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        Alert.SetRange(UniqueIdentifier, 'UID-1');
        Assert.IsTrue(Alert.FindFirst(), 'Alert should be inserted');
        Assert.AreEqual(SeveritySESTM::Warning, Alert.Severity, 'default severity used');
        Assert.AreEqual(AreaSESTM::Technical, Alert."Area", 'area preserved');
        Assert.AreEqual('short', Alert.ShortDescription, 'short description preserved');
    end;

    [Test]
    procedure NewAppliesRuleSetSeverityOverride()
    var
        Alert: Record AlertSESTM;
        RuleSet: Record SentinelRuleSetSESTM;
    begin
        RuleSet.AlertCode := "AlertCodeSESTM"::"SE-000002";
        RuleSet.Severity := SeveritySESTM::Info;
        RuleSet.Insert();

        Alert.New(
            "AlertCodeSESTM"::"SE-000002",
            'short',
            SeveritySESTM::Warning,
            AreaSESTM::Technical,
            'long',
            'action',
            'UID-2');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000002");
        Alert.SetRange(UniqueIdentifier, 'UID-2');
        Assert.IsTrue(Alert.FindFirst(), 'Alert should be inserted');
        Assert.AreEqual(SeveritySESTM::Info, Alert.Severity, 'override severity applied');
    end;

    [Test]
    procedure NewSkipsWhenRuleSetSeverityIsDisabled()
    var
        Alert: Record AlertSESTM;
        RuleSet: Record SentinelRuleSetSESTM;
    begin
        RuleSet.AlertCode := "AlertCodeSESTM"::"SE-000003";
        RuleSet.Severity := SeveritySESTM::Disabled;
        RuleSet.Insert();

        Alert.New(
            "AlertCodeSESTM"::"SE-000003",
            'short',
            SeveritySESTM::Warning,
            AreaSESTM::Technical,
            'long',
            'action',
            'UID-3');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Alert.SetRange(UniqueIdentifier, 'UID-3');
        Assert.IsTrue(Alert.IsEmpty(), 'Disabled severity suppresses insert');
    end;

    [Test]
    procedure NewSkipsWhenDefaultSeverityIsDisabled()
    var
        Alert: Record AlertSESTM;
    begin
        Alert.New(
            "AlertCodeSESTM"::"SE-000004",
            'short',
            SeveritySESTM::Disabled,
            AreaSESTM::Technical,
            'long',
            'action',
            'UID-4');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
        Alert.SetRange(UniqueIdentifier, 'UID-4');
        Assert.IsTrue(Alert.IsEmpty(), 'Disabled default severity suppresses insert');
    end;

    [Test]
    procedure NewIsIdempotentForSameAlertCodeAndUniqueId()
    var
        Alert: Record AlertSESTM;
    begin
        Alert.New(
            "AlertCodeSESTM"::"SE-000005",
            'first',
            SeveritySESTM::Warning,
            AreaSESTM::Permissions,
            'long',
            'action',
            'UID-5');

        Alert.New(
            "AlertCodeSESTM"::"SE-000005",
            'second',
            SeveritySESTM::Info,
            AreaSESTM::Permissions,
            'long 2',
            'action 2',
            'UID-5');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000005");
        Alert.SetRange(UniqueIdentifier, 'UID-5');
        Assert.AreEqual(1, Alert.Count(), 'duplicate insert should be ignored');
        Alert.FindFirst();
        Assert.AreEqual('first', Alert.ShortDescription, 'first write wins');
        Assert.AreEqual(SeveritySESTM::Warning, Alert.Severity, 'first severity wins');
    end;

    [Test]
    procedure NewAllowsDifferentUniqueIdentifiersWithinSameCode()
    var
        Alert: Record AlertSESTM;
    begin
        Alert.New(
            "AlertCodeSESTM"::"SE-000006",
            'first',
            SeveritySESTM::Warning,
            AreaSESTM::Performance,
            'long',
            'action',
            'UID-6a');
        Alert.New(
            "AlertCodeSESTM"::"SE-000006",
            'second',
            SeveritySESTM::Warning,
            AreaSESTM::Performance,
            'long',
            'action',
            'UID-6b');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000006");
        Assert.AreEqual(2, Alert.Count(), 'distinct UniqueIdentifiers produce distinct alerts');
    end;

    // NOTE: we assert against the underlying IgnoredAlertsSESTM table instead
    // of `Alert.CalcFields(Ignore)`. al-runner 1.0.3 still does not recompute
    // multi-field `exist(...)` FlowFields (the `Ignore` field's `CalcFormula`
    // filters on both AlertCode and UniqueIdentifier). Single-field `exist`
    // was fixed in 1.0.3; tracked upstream as a follow-up on the same issue.
    [Test]
    procedure SetToIgnoreInsertsIgnoredAlertRow()
    var
        Alert: Record AlertSESTM;
        IgnoredAlert: Record IgnoredAlertsSESTM;
    begin
        Alert.New(
            "AlertCodeSESTM"::"SE-000007",
            'short',
            SeveritySESTM::Warning,
            AreaSESTM::Performance,
            'long',
            'action',
            'UID-7');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000007");
        Alert.SetRange(UniqueIdentifier, 'UID-7');
        Alert.FindFirst();

        Alert.SetToIgnore();

        IgnoredAlert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000007");
        IgnoredAlert.SetRange(UniqueIdentifier, 'UID-7');
        Assert.IsFalse(IgnoredAlert.IsEmpty(), 'SetToIgnore should insert an IgnoredAlertsSESTM row');
    end;

    [Test]
    procedure ClearIgnoreRemovesMatchingIgnoredAlertRow()
    var
        Alert: Record AlertSESTM;
        IgnoredAlert: Record IgnoredAlertsSESTM;
    begin
        Alert.New(
            "AlertCodeSESTM"::"SE-000008",
            'short',
            SeveritySESTM::Warning,
            AreaSESTM::Performance,
            'long',
            'action',
            'UID-8');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000008");
        Alert.SetRange(UniqueIdentifier, 'UID-8');
        Alert.FindFirst();

        IgnoredAlert.Validate(AlertCode, "AlertCodeSESTM"::"SE-000008");
        IgnoredAlert.Validate(UniqueIdentifier, 'UID-8');
        IgnoredAlert.Insert();

        Alert.ClearIgnore();

        IgnoredAlert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000008");
        IgnoredAlert.SetRange(UniqueIdentifier, 'UID-8');
        Assert.IsTrue(IgnoredAlert.IsEmpty(), 'ClearIgnore should delete the matching IgnoredAlertsSESTM row');
    end;

    [Test]
    procedure ClearAllAlertsEmptiesTheTable()
    var
        Alert: Record AlertSESTM;
    begin
        Alert.New("AlertCodeSESTM"::"SE-000001", 's', SeveritySESTM::Warning, AreaSESTM::Technical, 'l', 'a', 'C-1');
        Alert.New("AlertCodeSESTM"::"SE-000002", 's', SeveritySESTM::Warning, AreaSESTM::Technical, 'l', 'a', 'C-2');
        Assert.IsFalse(Alert.IsEmpty(), 'precondition: alerts exist');

        Alert.ClearAllAlerts();
        Assert.IsTrue(Alert.IsEmpty(), 'ClearAllAlerts should empty the alert table');
    end;
}
