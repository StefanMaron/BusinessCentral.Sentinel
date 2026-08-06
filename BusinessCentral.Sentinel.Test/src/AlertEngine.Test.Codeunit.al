namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.TestLibraries.Utilities;

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
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

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

    [Test]
    procedure SetToIgnoreMarksAlertIgnoredAndClearIgnoreReverts()
    var
        Alert: Record AlertSESTM;
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
        Alert.CalcFields(Ignore);
        Assert.IsFalse(Alert.Ignore, 'Fresh alert should not be ignored');

        Alert.SetToIgnore();
        Alert.CalcFields(Ignore);
        Assert.IsTrue(Alert.Ignore, 'SetToIgnore should flip the FlowField');

        Alert.ClearIgnore();
        Alert.CalcFields(Ignore);
        Assert.IsFalse(Alert.Ignore, 'ClearIgnore should flip it back');
    end;

    [Test]
    procedure ClearAllAlertsRestartsExistingNumberSequence()
    var
        Alert: Record AlertSESTM;
    begin
        // Covers the `if NumberSequence.Exists(...) then Restart(...)` arm in
        // ClearAllAlerts. We create the sequence manually because the real
        // creation site (Alert.OnInsert) does not fire under al-runner (#27).
        if not NumberSequence.Exists('BCSentinelSESTMAlertId') then
            NumberSequence.Insert('BCSentinelSESTMAlertId');

        Alert.ClearAllAlerts();
        Assert.IsTrue(Alert.IsEmpty(), 'ClearAllAlerts should leave the table empty');
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

    // NOTE: the `if not IgnoredAlerts.Insert(true) then exit;` branch in
    // Alert.SetToIgnore cannot be covered — al-runner's in-memory store
    // does not enforce primary-key uniqueness on Insert, so the duplicate
    // Insert returns true instead of false and the exit arm is never taken.
    [Test]
    procedure SetToIgnoreIsNoopWhenAlreadyIgnored()
    var
        Alert: Record AlertSESTM;
        IgnoredAlert: Record IgnoredAlertsSESTM;
    begin
        Alert.New("AlertCodeSESTM"::"SE-000001", 's', SeveritySESTM::Warning, AreaSESTM::Technical, 'l', 'a', 'GUARD-1');
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        Alert.SetRange(UniqueIdentifier, 'GUARD-1');
        Alert.FindFirst();

        Alert.SetToIgnore();
        Alert.CalcFields(Ignore);
        Alert.SetToIgnore(); // second call: FlowField guard should early-exit

        IgnoredAlert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        IgnoredAlert.SetRange(UniqueIdentifier, 'GUARD-1');
        Assert.AreEqual(1, IgnoredAlert.Count(), 'SetToIgnore on an already-ignored alert must not double-insert');
    end;

    [Test]
    procedure ClearIgnoreIsNoopWhenNotIgnored()
    var
        Alert: Record AlertSESTM;
        IgnoredAlert: Record IgnoredAlertsSESTM;
    begin
        Alert.New("AlertCodeSESTM"::"SE-000002", 's', SeveritySESTM::Warning, AreaSESTM::Technical, 'l', 'a', 'GUARD-2');
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000002");
        Alert.SetRange(UniqueIdentifier, 'GUARD-2');
        Alert.FindFirst();
        Alert.CalcFields(Ignore);

        Alert.ClearIgnore(); // FlowField says not-ignored, early-exit branch

        IgnoredAlert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000002");
        IgnoredAlert.SetRange(UniqueIdentifier, 'GUARD-2');
        Assert.IsTrue(IgnoredAlert.IsEmpty(), 'ClearIgnore on a non-ignored alert should be a no-op');
    end;

    // NOTE: we invoke `Alert.LogUsage()` directly rather than triggering it
    // via `Alert.OnInsert` + `OnRuleLogging` telemetry. al-runner currently
    // does not execute table `trigger OnInsert()` bodies at all — tracked
    // upstream — so the "OnInsert → LogUsage" path isn't exercisable via the
    // production call site.
    [Test]
    procedure LogUsageBuildsTelemetryDimensionsWithoutCrashing()
    var
        Alert: Record AlertSESTM;
    begin
        // SE-000001's rule (AlertPteDownloadCodeSESTM) does
        // `Extensions.Get(Alert.UniqueIdentifier)` in AddCustomTelemetryDimensions,
        // and "NAV App Installed App" keys on a Guid field — a non-GUID
        // UniqueIdentifier now throws "Invalid format of GUID string" against
        // real BC (al-runner's Guid<->Text handling silently no-op'd instead,
        // which is what let 'TELEM-1' pass before). Use a well-formed GUID so
        // we still exercise LogUsage's plumbing without hitting that unrelated
        // format error; the extension record is deliberately not seeded, so
        // Get() legitimately returns false either way.
        Alert.New("AlertCodeSESTM"::"SE-000001", 's', SeveritySESTM::Warning, AreaSESTM::Technical, 'l', 'a', '99999999-9999-9999-9999-999999999999');
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        Alert.SetRange(UniqueIdentifier, '99999999-9999-9999-9999-999999999999');
        Alert.FindFirst();

        // Covers Alert.Table.LogUsage (populates Severity/Area/Ignore
        // dimensions, resolves the interface, calls TelemetryHelper.LogUsage)
        // plus TelemetryHelperSESTM.LogUsage's IsSaaS short-circuit.
        Alert.LogUsage();

        Assert.AreEqual(1, Alert.Count(), 'LogUsage must not alter the alert table');
    end;
}
