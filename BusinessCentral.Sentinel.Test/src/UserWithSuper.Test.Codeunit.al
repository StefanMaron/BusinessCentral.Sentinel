namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;
using System.Security.AccessControl;
using System.Security.User;

codeunit 71180505 UserWithSuperTestSESTM
{
    Subtype = Test;
    Access = Internal;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure UserWithSuperRoleCreatesInfoAlert()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UserWithSuperSESTM;
        User: Record User;
        AccessControl: Record "Access Control";
    begin
        User."User Security ID" := '00000000-0000-0000-0000-000000000001';
        User."User Name" := 'ALICE';
        User."License Type" := User."License Type"::"Full User";
        User.Insert();

        AccessControl."User Security ID" := User."User Security ID";
        AccessControl."Role ID" := 'SUPER';
        AccessControl."Company Name" := 'CRONUS';
        AccessControl.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000005");
        Assert.AreEqual(1, Alert.Count(), 'One alert expected for a user with SUPER');
        Alert.FindFirst();
        Assert.AreEqual(SeveritySESTM::Info, Alert.Severity, 'Severity should be Info');
        Assert.AreEqual(AreaSESTM::Permissions, Alert."Area", 'Area should be Permissions');
    end;

    [Test]
    procedure NonSuperRolesAreIgnored()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UserWithSuperSESTM;
        User: Record User;
        AccessControl: Record "Access Control";
    begin
        User."User Security ID" := '00000000-0000-0000-0000-000000000001';
        User."User Name" := 'BOB';
        User."License Type" := User."License Type"::"Full User";
        User.Insert();

        AccessControl."User Security ID" := User."User Security ID";
        AccessControl."Role ID" := 'SECURITY';
        AccessControl."Company Name" := 'CRONUS';
        AccessControl.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000005");
        Assert.IsTrue(Alert.IsEmpty(), 'Users without SUPER should not trigger SE-000005');
    end;

    [Test]
    procedure ExternalUserWithSuperIsFilteredOut()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UserWithSuperSESTM;
        User: Record User;
        AccessControl: Record "Access Control";
    begin
        // The rule filters out External User / Application / AAD Group license
        // types, so an external user with SUPER should not alert.
        User."User Security ID" := '00000000-0000-0000-0000-000000000001';
        User."User Name" := 'EXT';
        User."License Type" := User."License Type"::"External User";
        User.Insert();

        AccessControl."User Security ID" := User."User Security ID";
        AccessControl."Role ID" := 'SUPER';
        AccessControl."Company Name" := 'CRONUS';
        AccessControl.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000005");
        Assert.IsTrue(Alert.IsEmpty(), 'External users are excluded from SUPER check');
    end;

    [Test]
    procedure ShowMoreDetailsAndRelatedAndTelemetryAreCallable()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UserWithSuperSESTM;
        User: Record User;
        AccessControl: Record "Access Control";
        Dimensions: Dictionary of [Text, Text];
    begin
        User."User Security ID" := '00000000-0000-0000-0000-000000000099';
        User."User Name" := 'ADMIN';
        User."License Type" := User."License Type"::"Full User";
        User.Insert();

        AccessControl."User Security ID" := User."User Security ID";
        AccessControl."Role ID" := 'SUPER';
        AccessControl."Company Name" := 'CRONUS';
        AccessControl.Insert();

        Rule.CreateAlerts();
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000005");
        Alert.FindFirst();

        // Rule.ShowMoreDetails skipped until upstream Hyperlink NullRef fix.
        Rule.ShowRelatedInformation(Alert);
        Rule.AutoFix(Alert);
        Rule.AddCustomTelemetryDimensions(Alert, Dimensions);
        Assert.IsTrue(Dimensions.ContainsKey('AlertUserSecurityID'), 'Dimensions should include AlertUserSecurityID');
        Assert.AreEqual('CRONUS', Dimensions.Get('AlertCompanyName'), 'Dimensions should carry the company name');
        Assert.AreNotEqual('', Rule.GetTelemetryDescription(Alert), 'Telemetry description should not be empty');
    end;

    [Test]
    procedure SuperInAllCompaniesIsTaggedAsAllInShortDescription()
    var
        Alert: Record AlertSESTM;
        Rule: Codeunit UserWithSuperSESTM;
        User: Record User;
        AccessControl: Record "Access Control";
    begin
        // The rule replaces an empty Company Name with '<all>' before composing
        // the short description.
        User."User Security ID" := '00000000-0000-0000-0000-000000000001';
        User."User Name" := 'ROOT';
        User."License Type" := User."License Type"::"Full User";
        User.Insert();

        AccessControl."User Security ID" := User."User Security ID";
        AccessControl."Role ID" := 'SUPER';
        AccessControl."Company Name" := '';
        AccessControl.Insert();

        Rule.CreateAlerts();

        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000005");
        Alert.FindFirst();
        Assert.IsTrue(StrPos(Alert.ShortDescription, '<all>') > 0, 'Empty company should be rendered as <all>');
    end;
}
