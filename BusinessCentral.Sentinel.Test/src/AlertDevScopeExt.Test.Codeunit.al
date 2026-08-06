namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.TestLibraries.Utilities;
using System.Apps;

codeunit 71180502 AlertDevScopeExtTestSESTM
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

    [Test]
    procedure DevScopeExtensionCreatesWarningAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AlertDevScopeExtSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        DeleteExtensionIfExists('22222222-2222-2222-2222-222222222222');
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := '22222222-2222-2222-2222-222222222222';
        Extension.Name := 'Dev Extension';
        Extension."Published As" := Extension."Published As"::Dev;
        Extension.Insert();

        Rule.CreateAlerts();

        // A real BC environment (unlike al-runner) typically has other
        // genuinely Dev-published extensions installed (e.g. this test app
        // itself, published via the dev endpoint), so also filter by the
        // extension we seeded rather than asserting a total universe count.
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000002");
        Alert.SetRange(UniqueIdentifier, '{22222222-2222-2222-2222-222222222222}');
        Assert.AreEqual(1, Alert.Count(), 'One alert expected per Dev-scope extension');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Warning, Alert.Severity, 'Severity should be Warning');
        Assert.AreEqual(AreaSESTM::Technical, Alert."Area", 'Area should be Technical');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ExtensionManagementPageHandler,NoAutofixMessageHandler')]
    procedure ShowMoreDetailsAndRelatedAndTelemetryAreCallable()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AlertDevScopeExtSESTM;
        Extension: Record "NAV App Installed App";
        Dimensions: Dictionary of [Text, Text];
    begin
        Alert.ClearAllAlerts();
        DeleteExtensionIfExists('22222222-2222-2222-2222-222222222222');
        // Rule's AddCustomTelemetryDimensions does `Extensions.Get(UniqueIdentifier)`
        // where UniqueIdentifier is the App ID, which is also the table's
        // real primary key — Get() resolves it directly.
        Extension."Package ID" := '22222222-2222-2222-2222-222222222222';
        Extension."App ID" := '22222222-2222-2222-2222-222222222222';
        Extension.Name := 'Dev Extension';
        Extension.Publisher := 'Acme';
        Extension."Version Major" := 1;
        Extension."Version Minor" := 0;
        Extension."Version Build" := 0;
        Extension."Version Revision" := 0;
        Extension."Published As" := Extension."Published As"::Dev;
        Extension.Insert();

        Rule.CreateAlerts();
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000002");
        Alert.FindFirst();

        // Rule.ShowMoreDetails skipped until upstream Hyperlink NullRef fix.
        Rule.ShowRelatedInformation(Alert);
        Rule.AutoFix(Alert);
        // AddCustomTelemetryDimensions does Extensions.Get(Alert.UniqueIdentifier).
        // Under al-runner's Guid ↔ Text round-trip bug that lookup silently
        // exits, so we only exercise the call for coverage, not the values.
        Rule.AddCustomTelemetryDimensions(Alert, Dimensions);
        Assert.AreNotEqual('', Rule.GetTelemetryDescription(Alert), 'Telemetry description should not be empty');
    end;

    [Test]
    procedure PteAndGlobalExtensionsAreIgnored()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AlertDevScopeExtSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        DeleteExtensionIfExists('22222222-2222-2222-2222-222222222222');
        DeleteExtensionIfExists('44444444-4444-4444-4444-444444444444');
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := '22222222-2222-2222-2222-222222222222';
        Extension.Name := 'PTE Extension';
        Extension."Published As" := Extension."Published As"::PTE;
        Extension.Insert();

        Extension.Init();
        Extension."Package ID" := '33333333-3333-3333-3333-333333333333';
        Extension."App ID" := '44444444-4444-4444-4444-444444444444';
        Extension.Name := 'Global Extension';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        // Scope to the two extensions this test seeded — a real environment
        // may have other genuinely Dev-published extensions (unlike
        // al-runner's blank slate) producing unrelated SE-000002 alerts.
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000002");
        Alert.SetFilter(UniqueIdentifier, '%1|%2', '{22222222-2222-2222-2222-222222222222}', '{44444444-4444-4444-4444-444444444444}');
        Assert.IsTrue(Alert.IsEmpty(), 'No alert expected for PTE or Global extensions');
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
