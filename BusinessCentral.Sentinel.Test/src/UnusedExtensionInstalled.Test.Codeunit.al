namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.Apps;
using Microsoft.Foundation.Company;

codeunit 71180508 UnusedExtInstalledTestSESTM
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;

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

    [Test]
    procedure NoWatchedExtensionsInstalledCreatesNoAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UnusedExtensionInstalledSESTM;
    begin
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

    [Test]
    procedure MultipleWatchedExtensionsEachCreateTheirOwnAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UnusedExtensionInstalledSESTM;
        Extension: Record "NAV App Installed App";
    begin
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
        Assert.AreEqual(2, Alert.Count(), 'One alert per installed watched extension');
    end;
}
