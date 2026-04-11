namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.Threading;

codeunit 71180506 AnalysisNotSchedTestSESTM
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure MissingJobQueueEntryCreatesAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AnalysisNotScheduledSESTM;
    begin
        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000008");
        Assert.AreEqual(1, Alert.Count(), 'Alert expected when no rerun job queue is scheduled');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Info, Alert.Severity, 'Severity should be Info');
        Assert.AreEqual(AreaSESTM::Technical, Alert."Area", 'Area should be Technical');
    end;

    [Test]
    procedure ExistingJobQueueEntrySuppressesAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AnalysisNotScheduledSESTM;
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.ID := '00000000-0000-0000-0000-000000000001';
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::ReRunAllAlerts;
        JobQueueEntry.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000008");
        Assert.IsTrue(Alert.IsEmpty(), 'No alert expected when the rerun job queue entry already exists');
    end;

    [Test]
    procedure UnrelatedJobQueueEntryDoesNotSuppressAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AnalysisNotScheduledSESTM;
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.ID := '00000000-0000-0000-0000-000000000001';
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := 99999; // not ReRunAllAlerts
        JobQueueEntry.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000008");
        Assert.AreEqual(1, Alert.Count(), 'A different job queue entry should not satisfy the check');
    end;
}
