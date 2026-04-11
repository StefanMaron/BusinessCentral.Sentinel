namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.Apps;

codeunit 71180503 PteDownloadCodeTestSESTM
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;

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
        Extension."Package ID" := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
        Extension."App ID" := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
        Extension.Name := 'Customer PTE';
        Extension."Published As" := Extension."Published As"::PTE;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        Assert.AreEqual(1, Alert.Count(), 'One alert expected per PTE without source-code access');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Warning, Alert.Severity, 'Severity should be Warning');
        Assert.AreEqual(AreaSESTM::Technical, Alert."Area", 'Area should be Technical');
    end;

    [Test]
    procedure DevAndGlobalExtensionsAreIgnored()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit AlertPteDownloadCodeSESTM;
        Extension: Record "NAV App Installed App";
    begin
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

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000001");
        Assert.IsTrue(Alert.IsEmpty(), 'Non-PTE extensions should not trigger SE-000001');
    end;
}
