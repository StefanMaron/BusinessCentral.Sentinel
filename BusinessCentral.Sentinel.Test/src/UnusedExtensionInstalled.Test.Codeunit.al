namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.Apps;
using System.Environment;
using System.TestLibraries.Utilities;

codeunit 71180508 UnusedExtInstalledTestSESTM
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    var
        Assert: Codeunit "Library Assert";

    // The rule checks for these App IDs. The "no-table-list" variants skip the
    // RecRef-based data probe entirely — they just alert if the extension is
    // installed.
    local procedure CloudMigrationAppId(): Text
    begin
        exit('6992416f-3f39-4d3c-8242-3fff61350bea');
    end;

    local procedure IntelligentCloudAppId(): Text
    begin
        exit('334ef79e-547e-4631-8ba1-7a7f18e14de6');
    end;

    local procedure ShopifyAppId(): Text
    begin
        exit('ec255f57-31d0-4ca2-b751-f2fa7c745abb');
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
        Ids: List of [Text];
    begin
        Ids.Add(CloudMigrationAppId());
        Ids.Add(IntelligentCloudAppId());
        Ids.Add(ShopifyAppId());
        foreach AppId in Ids do
            if Extension.Get(AppId) then
                Extension.Delete();
    end;

    [Test]
    procedure NoWatchedExtensionsInstalledCreatesNoAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UnusedExtensionInstalledSESTM;
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        // Nothing seeded — every RaiseAlertIfExtensionIsUnused call should
        // early-exit on `Extensions.IsEmpty()`.
        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000007");
        Assert.IsTrue(Alert.IsEmpty(), 'No SE-000007 alerts expected when no watched extensions are installed');
    end;

    [Test]
    procedure InstalledCloudMigrationRaisesAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UnusedExtensionInstalledSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := CloudMigrationAppId();
        Extension.Name := 'Cloud Migration';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000007");
        Alert.SetRange(UniqueIdentifier, CloudMigrationAppId());
        Assert.AreEqual(1, Alert.Count(), 'Alert expected when the CloudMigration extension is installed');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Warning, Alert.Severity, 'Severity should be Warning');
        Assert.AreEqual(AreaSESTM::Performance, Alert."Area", 'Area should be Performance');
    end;

    // NOTE: blocked in this local bc-linux environment — Company.Insert()
    // for a genuinely new company ('CRONUS' here, distinct from the real
    // 'CRONUS International Ltd.') throws
    // "System.InvalidOperationException: Tenant numeric id must be set" from
    // the platform's native company-provisioning code, independent of any
    // AL trigger. That's a bc-linux/company-creation limitation, not
    // something fixable from this app's AL code — see task report.
    [Test]
    procedure ShopifyInstalledButNoShopsRaisesAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UnusedExtensionInstalledSESTM;
        Extension: Record "NAV App Installed App";
        Company: Record Company;
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        // Exercises the RecRef-based data probe path: an installed watched
        // extension + a non-evaluation company + an empty probed table
        // (Shpfy Shop, 30102) should raise SE-000007.
        Extension."Package ID" := ShopifyAppId();
        Extension."App ID" := ShopifyAppId();
        Extension.Name := 'Shopify Connector';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Company.Name := 'CRONUS';
        Company."Evaluation Company" := false;
        Company.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000007");
        Alert.SetRange(UniqueIdentifier, ShopifyAppId());
        Assert.AreEqual(1, Alert.Count(), 'Alert expected when Shopify is installed but Shpfy Shop is empty');
    end;

    // NOTE: the "probed table has data → no alert" branch cannot be
    // exercised under al-runner — the `--guide` documents that
    // `RecordRef` stubs compile but do not function, so
    // `RecRef.Open(...).IsEmpty` always evaluates the same regardless of
    // what we seed. Once the runner wires up RecRef to the in-memory store
    // we can add a "seed Shpfy Shop row → no SE-000007" test here.

    [Test]
    procedure MultipleWatchedExtensionsEachCreateTheirOwnAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UnusedExtensionInstalledSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Alert.ClearAllAlerts();
        ResetSeededExtensions();
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := CloudMigrationAppId();
        Extension.Name := 'Cloud Migration';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Extension.Init();
        Extension."Package ID" := '22222222-2222-2222-2222-222222222222';
        Extension."App ID" := IntelligentCloudAppId();
        Extension.Name := 'Intelligent Cloud';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000007");
        Alert.SetFilter(UniqueIdentifier, '%1|%2', CloudMigrationAppId(), IntelligentCloudAppId());
        Assert.AreEqual(2, Alert.Count(), 'One alert per installed watched extension');
    end;
}
