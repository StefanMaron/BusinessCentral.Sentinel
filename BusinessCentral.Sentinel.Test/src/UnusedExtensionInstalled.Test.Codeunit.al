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

    // NOTE: the happy path (seed a watched extension and expect SE-000007)
    // hits `NavApp.GetModuleInfo(...)` in the rule, which currently fails in
    // al-runner with "Could not load file or assembly
    // 'Microsoft.Dynamics.Nav.CodeAnalysis'". Tracked upstream; once fixed we
    // can add tests that seed each of the 9 watched extensions.
}
