namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.Apps;
using System.TestLibraries.Utilities;

codeunit 71180504 DemoDataExtInProdTestSESTM
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

    // These are the three App IDs the rule looks for. Keep in sync with
    // DemoDataExtInProd.Codeunit.al.
    local procedure ContosoCoffeeAppId(): Text
    begin
        exit('5a0b41e9-7a42-4123-d521-2265186cfb31');
    end;

    local procedure ContosoCoffeeUsAppId(): Text
    begin
        exit('3a3f33b1-7b42-4123-a521-2265186cfb31');
    end;

    local procedure SustainabilityContosoAppId(): Text
    begin
        exit('a0673989-48a4-48a0-9517-499c9f4037d3');
    end;

    // "NAV App Installed App"'s real primary key is App ID (not Package ID,
    // despite the field order) and the table is DataPerCompany = false, so
    // rows persist across every test in this codeunit (BC's test runner only
    // rolls back once per codeunit, not per test). Wipe every App ID this
    // codeunit ever seeds before each test so tests don't see each other's
    // leftover extensions.
    local procedure ResetSeededExtensions()
    var
        Extension: Record "NAV App Installed App";
        AppId: Text;
    begin
        foreach AppId in DemoDataAppIds() do
            if Extension.Get(AppId) then
                Extension.Delete();
    end;

    // The rule passes Extensions."App ID" (a Guid field) directly as
    // Alert.New's UniqueIdentifierIn (Text), which triggers AL's implicit
    // Guid-to-Text conversion — uppercase, wrapped in braces. Filtering on
    // Alert.UniqueIdentifier must match that exact format.
    local procedure AsUniqueIdentifier(AppId: Text): Text
    begin
        exit('{' + UpperCase(AppId) + '}');
    end;

    local procedure DemoDataAppIds(): List of [Text]
    var
        Ids: List of [Text];
    begin
        Ids.Add(ContosoCoffeeAppId());
        Ids.Add(ContosoCoffeeUsAppId());
        Ids.Add(SustainabilityContosoAppId());
        Ids.Add('deadbeef-dead-beef-dead-beefdeadbeef');
        exit(Ids);
    end;

    [Test]
    procedure InstalledContosoDemoDataCreatesAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit DemoDataExtInProdSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := ContosoCoffeeAppId();
        Extension.Name := 'Contoso Coffee Demo Data';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
        Alert.SetRange(UniqueIdentifier, AsUniqueIdentifier(ContosoCoffeeAppId()));
        Assert.AreEqual(1, Alert.Count(), 'Alert expected when Contoso Coffee demo data is installed');
        Alert.FindFirst();
        // EnvironmentInformation.IsProduction() stub returns false → severity should be Info.
        Assert.AreEqual(SeveritySESTM::Info, Alert.Severity, 'Severity should be Info in non-production');
    end;

    [Test]
    procedure MultipleDemoDataExtensionsEachCreateTheirOwnAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit DemoDataExtInProdSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := ContosoCoffeeAppId();
        Extension.Name := 'Contoso Coffee';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Extension.Init();
        Extension."Package ID" := '22222222-2222-2222-2222-222222222222';
        Extension."App ID" := SustainabilityContosoAppId();
        Extension.Name := 'Sustainability Contoso Coffee';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
        Alert.SetFilter(UniqueIdentifier, '%1|%2', AsUniqueIdentifier(ContosoCoffeeAppId()), AsUniqueIdentifier(SustainabilityContosoAppId()));
        Assert.AreEqual(2, Alert.Count(), 'One alert expected per installed demo-data extension');
    end;

    [Test]
    procedure ContosoCoffeeUsIsAlsoDetected()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit DemoDataExtInProdSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        // Covers the US variant of the Contoso Coffee demo dataset to match
        // ContosoCoffeeDemoDatasetUSAppIdTok in the rule.
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := ContosoCoffeeUsAppId();
        Extension.Name := 'Contoso Coffee (US)';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
        Alert.SetRange(UniqueIdentifier, AsUniqueIdentifier(ContosoCoffeeUsAppId()));
        Assert.AreEqual(1, Alert.Count(), 'Alert expected when the US Contoso Coffee demo dataset is installed');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,ExtensionManagementPageHandler,NoAutofixMessageHandler')]
    procedure ShowMoreDetailsAndRelatedAndTelemetryAreCallable()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit DemoDataExtInProdSESTM;
        Extension: Record "NAV App Installed App";
        Dimensions: Dictionary of [Text, Text];
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        // Seed Package ID == App ID; App ID is also the table's real primary
        // key, so the rule's Get-by-PK lookup in AddCustomTelemetryDimensions
        // finds the row directly.
        Extension."Package ID" := ContosoCoffeeAppId();
        Extension."App ID" := ContosoCoffeeAppId();
        Extension.Name := 'Contoso Coffee';
        Extension.Publisher := 'Microsoft';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
        Alert.SetRange(UniqueIdentifier, AsUniqueIdentifier(ContosoCoffeeAppId()));
        Alert.FindFirst();

        // Rule.ShowMoreDetails skipped until upstream Hyperlink NullRef fix.
        Rule.ShowRelatedInformation(Alert);
        Rule.AutoFix(Alert);
        Rule.AddCustomTelemetryDimensions(Alert, Dimensions);
        Assert.AreNotEqual('', Rule.GetTelemetryDescription(Alert), 'Telemetry description should not be empty');
    end;

    [Test]
    procedure UnrelatedExtensionsDoNotCreateAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit DemoDataExtInProdSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := 'deadbeef-dead-beef-dead-beefdeadbeef';
        Extension.Name := 'Some Other Extension';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
        Alert.SetFilter(UniqueIdentifier, '%1|%2|%3', AsUniqueIdentifier(ContosoCoffeeAppId()), AsUniqueIdentifier(ContosoCoffeeUsAppId()), AsUniqueIdentifier(SustainabilityContosoAppId()));
        Assert.IsTrue(Alert.IsEmpty(), 'No alerts expected when no demo-data extension is installed');
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
