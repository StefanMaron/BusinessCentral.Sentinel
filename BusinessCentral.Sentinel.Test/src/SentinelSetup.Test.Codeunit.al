namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.TestLibraries.Utilities;

codeunit 71180510 SentinelSetupTestSESTM
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure GetTelemetryLoggingFallsBackToGlobalInitValueDefault()
    var
        Setup: Record SentinelSetup;
        Result: Enum TelemetryLogging;
    begin
        // Nothing in SentinelRuleSet, nothing pre-seeded. `SaveGet` inside
        // `GetTelemetryLoggingSetting` calls `Init` + `Insert` on the
        // singleton, and `InitValue = Daily` on the table field establishes
        // the default.
        Result := Setup.GetTelemetryLoggingSetting("AlertCodeSESTM"::"SE-000001");

        Assert.AreEqual(TelemetryLogging::Daily, Result, 'Without rule override, return the InitValue default (Daily)');
    end;

    [Test]
    procedure GetTelemetryLoggingHonoursRuleSetOverride()
    var
        Setup: Record SentinelSetup;
        RuleSet: Record SentinelRuleSetSESTM;
        Result: Enum TelemetryLogging;
    begin
        RuleSet.AlertCode := "AlertCodeSESTM"::"SE-000002";
        RuleSet.TelemetryLogging := TelemetryLogging::OnRuleLogging;
        RuleSet.Insert();

        Result := Setup.GetTelemetryLoggingSetting("AlertCodeSESTM"::"SE-000002");

        Assert.AreEqual(TelemetryLogging::OnRuleLogging, Result, 'Rule-level override should take precedence over global default');
    end;

    [Test]
    procedure GetTelemetryLoggingIgnoresBlankRuleSetEntry()
    var
        Setup: Record SentinelSetup;
        RuleSet: Record SentinelRuleSetSESTM;
        Result: Enum TelemetryLogging;
    begin
        // An entry exists but TelemetryLogging is the blank " " sentinel —
        // the hierarchy should treat that as "no override" and return the
        // global default.
        RuleSet.AlertCode := "AlertCodeSESTM"::"SE-000003";
        RuleSet.TelemetryLogging := TelemetryLogging::" ";
        RuleSet.Insert();

        Result := Setup.GetTelemetryLoggingSetting("AlertCodeSESTM"::"SE-000003");

        Assert.AreEqual(TelemetryLogging::Daily, Result, 'Blank override should fall through to the InitValue default');
    end;

    [Test]
    procedure GetTelemetryLoggingRespectsChangedGlobalValue()
    var
        Setup: Record SentinelSetup;
        Result: Enum TelemetryLogging;
    begin
        // First lookup populates the singleton via SaveGet → InitValue → Daily.
        Setup.GetTelemetryLoggingSetting("AlertCodeSESTM"::"SE-000004");

        Setup.Get();
        Setup.TelemetryLogging := TelemetryLogging::Off;
        Setup.Modify();

        Assert.AreEqual(
            TelemetryLogging::Off,
            Setup.GetTelemetryLoggingSetting("AlertCodeSESTM"::"SE-000004"),
            'Modified global value should be observed by subsequent lookups');
    end;
}
