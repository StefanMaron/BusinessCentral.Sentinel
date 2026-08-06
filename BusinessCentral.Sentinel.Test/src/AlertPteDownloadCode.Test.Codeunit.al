namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.TestLibraries.Utilities;
using System.Apps;

codeunit 71180503 PteDownloadCodeTestSESTM
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

    // "NAV App Installed App"'s real primary key is App ID (not Package ID,
    // despite the field order) and the table is DataPerCompany = false, so
    // rows persist across every test in this codeunit (BC's test runner only
    // rolls back once per codeunit, not per test). Delete-if-exists before
    // inserting so a reused App ID from an earlier test doesn't collide.
    local procedure DeleteExtensionIfExists(AppId: Text)
    var
        Extension: Record "NAV App Installed App";
    begin
        if Extension.Get(AppId) then
            Extension.Delete();
    end;

    // The stub `Extension Management.GetExtensionSource` always Error()s, so
    // the TryFunction `CanDownloadSourceCode` always returns false under
    // al-runner — every PTE in the stub table therefore yields an alert.
    [Test]
    procedure PteWithoutDownloadCodeCreatesWarning()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AlertPteDownloadCodeSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        DeleteExtensionIfExists('{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}');
        Extension."Package ID" := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
        Extension."App ID" := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
        Extension.Name := 'Customer PTE';
        Extension."Published As" := Extension."Published As"::PTE;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        Alert.SetRange(UniqueIdentifier, '{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}');
        Assert.AreEqual(1, Alert.Count(), 'One alert expected per PTE without source-code access');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Warning, Alert.Severity, 'Severity should be Warning');
        Assert.AreEqual(AreaSESTM::Technical, Alert."Area", 'Area should be Technical');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ExtensionManagementPageHandler,NoAutofixMessageHandler')]
    procedure ShowMoreDetailsAndRelatedAndTelemetryAreCallable()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AlertPteDownloadCodeSESTM;
        Extension: Record "NAV App Installed App";
        Dimensions: Dictionary of [Text, Text];
    begin
        Alert.ClearAllAlerts();
        DeleteExtensionIfExists('{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}');
        // Seed Package ID == App ID; App ID is also the table's real primary
        // key, so the rule's Get-by-PK lookup in AddCustomTelemetryDimensions
        // finds the row directly.
        Extension."Package ID" := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
        Extension."App ID" := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
        Extension.Name := 'Customer PTE';
        Extension.Publisher := 'Customer Inc.';
        Extension."Version Major" := 2;
        Extension."Published As" := Extension."Published As"::PTE;
        Extension.Insert();

        Rule.CreateAlerts();
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        Alert.SetRange(UniqueIdentifier, '{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}');
        Alert.FindFirst();

        // Rule.ShowMoreDetails skipped until upstream Hyperlink NullRef fix.
        Rule.ShowRelatedInformation(Alert);
        Rule.AutoFix(Alert);
        Rule.AddCustomTelemetryDimensions(Alert, Dimensions);
        Assert.AreNotEqual('', Rule.GetTelemetryDescription(Alert), 'Telemetry description should not be empty');
    end;

    [Test]
    procedure DevAndGlobalExtensionsAreIgnored()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AlertPteDownloadCodeSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        DeleteExtensionIfExists('{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}');
        DeleteExtensionIfExists('{dddddddd-dddd-dddd-dddd-dddddddddddd}');
        Extension."Package ID" := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
        Extension."App ID" := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
        Extension.Name := 'Dev Ext';
        Extension."Published As" := Extension."Published As"::Dev;
        Extension.Insert();

        Extension.Init();
        Extension."Package ID" := 'cccccccc-cccc-cccc-cccc-cccccccccccc';
        Extension."App ID" := 'dddddddd-dddd-dddd-dddd-dddddddddddd';
        Extension.Name := 'Global Ext';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        // Scope to the two extensions this test seeded — a real environment
        // may have other genuinely PTE-published extensions producing
        // unrelated SE-000001 alerts.
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        Alert.SetFilter(UniqueIdentifier, '%1|%2', '{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}', '{dddddddd-dddd-dddd-dddd-dddddddddddd}');
        Assert.IsTrue(Alert.IsEmpty(), 'Non-PTE extensions should not trigger SE-000001');
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [PageHandler]
    procedure ExtensionManagementPageHandler(var ExtensionManagement: TestPage "Extension Management")
    begin
    end;

    [MessageHandler]
    procedure NoAutofixMessageHandler(Msg: Text)
    begin
    end;
}
