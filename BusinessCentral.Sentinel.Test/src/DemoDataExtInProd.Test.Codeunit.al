namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.Apps;

codeunit 71180504 DemoDataExtInProdTestSESTM
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;

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

    [Test]
    procedure InstalledContosoDemoDataCreatesAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit DemoDataExtInProdSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := ContosoCoffeeAppId();
        Extension.Name := 'Contoso Coffee Demo Data';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
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
        Assert.AreEqual(2, Alert.Count(), 'One alert expected per installed demo-data extension');
    end;

    [Test]
    procedure UnrelatedExtensionsDoNotCreateAlerts()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit DemoDataExtInProdSESTM;
        Extension: Record "NAV App Installed App";
    begin
        Extension."Package ID" := '11111111-1111-1111-1111-111111111111';
        Extension."App ID" := 'deadbeef-dead-beef-dead-beefdeadbeef';
        Extension.Name := 'Some Other Extension';
        Extension."Published As" := Extension."Published As"::Global;
        Extension.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000004");
        Assert.IsTrue(Alert.IsEmpty(), 'No alerts expected when no demo-data extension is installed');
    end;
}
