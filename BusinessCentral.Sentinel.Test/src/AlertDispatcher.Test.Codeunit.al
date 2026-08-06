namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.TestLibraries.Utilities;
using System.Environment;
using System.Apps;

// End-to-end test for AlertDispatcher — confirms that the enum-driven fan-out
// to every IAuditAlertSESTM implementation actually runs and produces alerts
// on the underlying table.
codeunit 71180509 AlertDispatcherTestSESTM
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

    // Real BC does not support creating a company from AL (see
    // EvaluationCompanyInProd.Test's comment for the full explanation) — drive
    // the Evaluation Company flag on a company that genuinely exists instead,
    // and return its SystemId (as Alert.UniqueIdentifier formats it: a
    // braces-wrapped, uppercase Guid) so callers can scope SE-000003 to it.
    local procedure MarkOneCompanyAsEvaluation(): Text
    var
        Company: Record Company;
    begin
        if Company.FindSet(true) then
            repeat
                Company."Evaluation Company" := false;
                Company.Modify();
            until Company.Next() = 0;

        Company.FindFirst();
        Company."Evaluation Company" := true;
        Company.Modify();
        exit('{' + UpperCase(Format(Company.SystemId, 0, 4)) + '}');
    end;

    [Test]
    procedure FindNewAlertsFiresAnalysisNotScheduledOnEmptyEnv()
    var
        Alert: Record AlertSESTM;
        Dispatcher: Codeunit AlertDispatcherSESTM;
    begin
        Alert.ClearAllAlerts();
        // With nothing seeded, the "analysis not scheduled" rule has a trigger
        // (no Job Queue Entry matching the rerun codeunit) — all the other
        // rules early-exit.
        Dispatcher.FindNewAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000008");
        Assert.AreEqual(1, Alert.Count(), 'SE-000008 should fire when no rerun job queue is scheduled');
    end;

    [Test]
    procedure FindNewAlertsPicksUpMultipleRuleTriggers()
    var
        Alert: Record AlertSESTM;
        Dispatcher: Codeunit AlertDispatcherSESTM;
        Extension: Record "NAV App Installed App";
        EvalCompanyUniqueId: Text;
    begin
        Alert.ClearAllAlerts();
        EvalCompanyUniqueId := MarkOneCompanyAsEvaluation();

        if Extension.Get('22222222-2222-2222-2222-222222222222') then
            Extension.Delete();
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := '22222222-2222-2222-2222-222222222222';
        Extension.Name := 'Dev Ext';
        Extension."Published As" := Extension."Published As"::Dev;
        Extension.Insert();

        Dispatcher.FindNewAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Alert.SetRange(UniqueIdentifier, EvalCompanyUniqueId);
        Assert.AreEqual(1, Alert.Count(), 'SE-000003 should fire for the evaluation company');

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000002");
        Alert.SetRange(UniqueIdentifier, '{22222222-2222-2222-2222-222222222222}');
        Assert.AreEqual(1, Alert.Count(), 'SE-000002 should fire for the dev-scope extension');

        // SetRange on UniqueIdentifier from the SE-000002 check above is
        // still in effect — SetRange calls on different fields accumulate
        // (AND together) rather than replacing each other, so it must be
        // cleared explicitly or this filter would never match SE-000008's
        // blank UniqueIdentifier.
        Alert.SetRange(UniqueIdentifier);
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000008");
        Assert.AreEqual(1, Alert.Count(), 'SE-000008 should still fire');
    end;

    [Test]
    procedure FindNewAlertsIsIdempotentOnRerun()
    var
        Alert: Record AlertSESTM;
        Dispatcher: Codeunit AlertDispatcherSESTM;
        EvalCompanyUniqueId: Text;
    begin
        Alert.ClearAllAlerts();
        EvalCompanyUniqueId := MarkOneCompanyAsEvaluation();

        Dispatcher.FindNewAlerts();
        Dispatcher.FindNewAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Alert.SetRange(UniqueIdentifier, EvalCompanyUniqueId);
        Assert.AreEqual(1, Alert.Count(), 'Running the dispatcher twice should not create duplicates');
    end;

    [Test]
    procedure FullRerunClearsAndRecreatesAlerts()
    var
        Alert: Record AlertSESTM;
        Dispatcher: Codeunit AlertDispatcherSESTM;
        EvalCompanyUniqueId: Text;
    begin
        Alert.ClearAllAlerts();
        EvalCompanyUniqueId := MarkOneCompanyAsEvaluation();

        Dispatcher.FindNewAlerts();
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Alert.SetRange(UniqueIdentifier, EvalCompanyUniqueId);
        Assert.AreEqual(1, Alert.Count(), 'precondition: SE-000003 was created');

        Dispatcher.FullRerun();
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000003");
        Alert.SetRange(UniqueIdentifier, EvalCompanyUniqueId);
        Assert.AreEqual(1, Alert.Count(), 'FullRerun should re-create the same alert, not double or clear it');
    end;
}
