namespace STM.BusinessCentral.Sentinel;

using System.Threading;

codeunit 71180287 AnalysisNotScheduledSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata "Job Queue Entry" = RI;

    procedure CreateAlerts()
    var
        Alert: Record AlertSESTM;
        JobQueueEntry: Record "Job Queue Entry";
        ActionRecommendationLbl: Label 'Create a Job Queue Entry to run the Scheduled Alert Analysis.';
        LongDescLbl: Label 'Scheduled Alert Analysis is not scheduled to run. This means that the alerts are not being evaluated and the system is not being monitored for potential issues.';
        ShotDescLbl: Label 'Scheduled Alert Analysis is not scheduled to run.';
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"ReRunAllAlerts");
        if JobQueueEntry.IsEmpty() then
            Alert.New(
                AlertCodeSESTM::"SE-000008",
                ShotDescLbl,
                SeveritySESTM::Info,
                AreaSESTM::Technical,
                LongDescLbl,
                ActionRecommendationLbl,
                ''
            );
    end;

    local procedure CreateJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.Validate("Object ID to Run", Codeunit::"ReRunAllAlerts");
        Evaluate(JobQueueEntry."Next Run Date Formula", '<1D>');
        JobQueueEntry.Validate("Next Run Date Formula");
        JobQueueEntry.Validate("Status", JobQueueEntry."Status"::Ready);
        JobQueueEntry.Validate("Recurring Job", true);
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);

        // This Validate will insert the Job Queue Entry
        JobQueueEntry.Validate("Earliest Start Date/Time", CreateDateTime(Today() + 1, 0T));
        JobQueueEntry.Insert(true);
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000008', Locked = true;
    begin
        Hyperlink(WikiLinkTok);
    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    var
        JobQueueEntriesPage: Page "Job Queue Entries";
    begin
        JobQueueEntriesPage.Run();
    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    var
        ConfirmJobQueueCreateQst: Label 'Do you want to create a Job Queue Entry to run the Scheduled Alert Analysis?';
    begin
        if Confirm(ConfirmJobQueueCreateQst) then
            this.CreateJobQueueEntry();
    end;

    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])
    begin
        // No custom telemetry dimensions to add
    end;

    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text
    begin
        exit(Alert.ShortDescription);
    end;
}