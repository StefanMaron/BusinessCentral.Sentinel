namespace STM.BusinessCentral.Sentinel;

using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Vendor;
using Microsoft.Projects.Project.Job;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;

codeunit 71180574 DirectPostingSESTM implements IAuditAlertSESTM
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = RI;
    procedure CreateAlerts()
    var
        Alert: Record AlertSESTM;
    begin
        Alert.SetRange(AlertCode, "AlertCodeSESTM"::"SE-000009");
        Alert.DeleteAll(true);

        this.CheckPostingGroup(Database::"Customer Posting Group");
        this.CheckPostingGroup(Database::"Vendor Posting Group");
        this.CheckPostingGroup(Database::"Job Posting Group");
        this.CheckPostingGroup(Database::"General Posting Setup");
        this.CheckPostingGroup(Database::"Bank Account Posting Group");
        this.CheckPostingGroup(Database::"VAT Posting Setup");
        this.CheckPostingGroup(Database::"FA Posting Group");
        this.CheckPostingGroup(Database::"Inventory Posting Setup");
    end;

    local procedure CheckPostingGroup(TableID: Integer)
    var
        RecordRef: RecordRef;
        KeyRef: KeyRef;
    begin
        RecordRef.Open(TableID);
        RecordRef.ReadIsolation(IsolationLevel::ReadUncommitted);
        KeyRef := RecordRef.KeyIndex(1);
        if RecordRef.FindSet() then
            repeat
                this.CheckAccounts(RecordRef, KeyRef)
            until RecordRef.Next() = 0;
    end;

    local procedure CheckAccounts(RecordRef: RecordRef; KeyRef: KeyRef)
    var
        FieldRef: FieldRef;
        i: Integer;
    begin
        for i := 1 to RecordRef.FieldCount() do begin
            FieldRef := RecordRef.FieldIndex(i);
            if FieldRef.Relation = Database::"G/L Account" then
                this.CheckAccount(RecordRef, KeyRef, FieldRef);
        end;
    end;

    local procedure CheckAccount(RecordRef: RecordRef; KeyRef: KeyRef; FieldRef: FieldRef)
    var
        GLAccount: Record "G/L Account";
        Alert: Record AlertSESTM;
        ShortDescLbl: Label '"%1" %2 "%3" %4 : "%5" should not be allowed', Comment = '%1 = WhereUsed.TableCaption, %2 = WhereUsed PrimaryKey, %3 = UsedAs.FieldCaption(), %4 = "G/L Account"."No.", %5 : FieldCaption("Direct Posting")';
        LongDescLbl: Label 'G/L Account %1 (%2) should not be %3 allowed when used for %4 %5 as %6.', Comment = '%1 = "G/L Account"."No.", %2 = "G/L Account".Name, %3 = FieldCaption("Direct Posting"), %4 = WhereUsed.TableCaption, %5 = WhereUsed PrimaryKey, %6 = UsedAs.FieldCaption()';
        CallToActionLbl: Label 'Set "%1" not allowed for %2 %3 "%4"', Comment = '%1 = FieldCaption("Direct Posting"), %2 = TableCaption, %3 = "G/L Account"."No.", %4 = "G/L Account".Name';
        DoesntExistsShortDescLbl: Label '%1 as "%2" in "%3" %4 doesn''t exists.', Comment = '%1 = GLAccount."No.", %2 = UsedAs.FieldCaption(), %3 = WhereUsed.TableCaption, %4 = WhereUsed PrimaryKey';
        DoesntExistsLongDescLbl: Label 'G/L Account %1 used as "%2" in "%3" %4 doesn''t exists.\Review Setup or use AutoFix to create it.', Comment = '%1 = "G/L Account"."No.", %2 = UsedAs.FieldCaption(), %3 = WhereUsed.TableCaption, %4 = WhereUsed PrimaryKey';
        DoesntExistsCallToActionLbl: Label 'Create G/L Account %1 %2', Comment = '%1 = GLAccount."No.", %2 = GLAccount.Name';
    begin
        GLAccount.ReadIsolation(IsolationLevel::ReadCommitted);
        GLAccount.SetLoadFields("No.", Name, "Direct Posting");
        GLAccount."No." := FieldRef.Value;
        if GLAccount."No." = '' then
            exit;
        if not GLAccount.Get(GLAccount."No.") then
            Alert.New(
                "AlertCodeSESTM"::"SE-000009",
                StrSubstNo(DoesntExistsShortDescLbl, GLAccount."No.", FieldRef.Caption, RecordRef.Caption, this.KeyValue(KeyRef)),
                SeveritySESTM::Error,
                AreaSESTM::Accounting,
                StrSubstNo(DoesntExistsLongDescLbl, GLAccount."No.", FieldRef.Caption, RecordRef.Caption, this.KeyValue(KeyRef)),
                StrSubstNo(DoesntExistsCallToActionLbl, GLAccount."No.", FieldRef.Caption),
                StrSubstNo('%1|%2|%3|%4|%5', RecordRef.Number, this.SystemId(RecordRef), FieldRef.Number, GLAccount."No.", FieldRef.Caption)
            )
        else
            if GLAccount."Direct Posting" and not this.MustBeDirectPosting(RecordRef, FieldRef) then
                Alert.New(
                    "AlertCodeSESTM"::"SE-000009",
                    StrSubstNo(ShortDescLbl, RecordRef.Caption, this.KeyValue(KeyRef), FieldRef.Caption, GLAccount."No.", GLAccount.FieldCaption("Direct Posting")),
                    SeveritySESTM::Warning,
                    AreaSESTM::Accounting,
                    StrSubstNo(LongDescLbl, GLAccount."No.", GLAccount.Name, GLAccount.FieldCaption("Direct Posting"), RecordRef.Caption, this.KeyValue(KeyRef), FieldRef.Caption),
                    StrSubstNo(CallToActionLbl, GLAccount.FieldCaption("Direct Posting"), RecordRef.Caption, GLAccount."No.", GLAccount.Name),
                    GLAccount.SystemId
                );
    end;

    local procedure KeyValue(KeyRef: KeyRef) ReturnValue: Text
    var
        FieldRef: FieldRef;
        i: Integer;
        ValueAsText: Text;
    begin
        for i := 1 to KeyRef.FieldCount do begin
            FieldRef := KeyRef.FieldIndex(i);
            if ReturnValue <> '' then
                ReturnValue += ', ';
            Evaluate(ValueAsText, FieldRef.Value);
            ReturnValue += ValueAsText;
        end;
    end;

    local procedure SystemId(RecordRef: RecordRef): Guid
    begin
        exit(RecordRef.Field(RecordRef.SystemIdNo()).Value);
    end;

    local procedure MustBeDirectPosting(var RecordRef: RecordRef; var FieldRef: FieldRef): Boolean
    var
        FAPostingGroup: Record "FA Posting Group";
        IsHandled: Boolean;
    begin
        this.OnBeforeMustBeDirectPosting(RecordRef, FieldRef, IsHandled);
        if IsHandled then
            exit(true);
        case true of
            (RecordRef.Number = Database::"FA Posting Group") and (FieldRef.Number = FAPostingGroup.FieldNo("Depreciation Expense Acc.")):
                exit(true);
        end;
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000009', Locked = true;
    begin
        Hyperlink(WikiLinkTok);
    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    begin
        if Alert.Severity = SeveritySESTM::Warning then
            this.ShowAccountCard(Alert)
        else
            this.ShowPostingGroups(Alert);
    end;

    local procedure ShowAccountCard(var Alert: Record AlertSESTM)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.ReadIsolation(IsolationLevel::ReadUncommitted);
        GLAccount.SetLoadFields("SystemId", "No.", Name, "Direct Posting");
        GLAccount.GetBySystemId(Alert.UniqueIdentifier);
        Page.Run(Page::"G/L Account Card", GLAccount);
    end;

    local procedure ShowPostingGroups(var Alert: Record AlertSESTM)
    var
        RecordRef: RecordRef;
        Rec: Variant;
        TableNo: Integer;
        Guid: Guid;
        FieldNo: Integer;
    begin
        Evaluate(TableNo, this.GetToken(Alert.UniqueIdentifier, 1));
        RecordRef.Open(TableNo);
        RecordRef.ReadIsolation(IsolationLevel::ReadUncommitted);
        Evaluate(Guid, this.GetToken(Alert.UniqueIdentifier, 2));
        RecordRef.GetBySystemId(Guid);
        RecordRef.SetRecFilter();
        RecordRef.FindFirst();
        RecordRef.Reset();
        Rec := RecordRef;
        Evaluate(FieldNo, this.GetToken(Alert.UniqueIdentifier, 3));
        Page.RunModal(0, Rec, FieldNo);
    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    var
        QuestionMarkLbl: Label '%1?', Comment = '%1 : ActionRecommendation (QuestionMark with or without leading space according to the language syntax rule';
    begin
        if not Confirm(QuestionMarkLbl, false, Alert.ActionRecommendation) then
            exit;
        if Alert.Severity = SeveritySESTM::Warning then
            this.DisableDirectPosting(Alert)
        else
            this.CreateAccount(Alert);
    end;

    local procedure DisableDirectPosting(Alert: Record AlertSESTM)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetLoadFields();
        GLAccount.ReadIsolation(IsolationLevel::UpdLock);
        GLAccount.GetBySystemId(Alert.UniqueIdentifier);
        GLAccount.Find();
        GLAccount.Validate("Direct Posting", false);
        GLAccount.Modify(true);
    end;

    local procedure CreateAccount(Alert: Record AlertSESTM)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Init();
        GLAccount."No." := CopyStr(this.GetToken(Alert.UniqueIdentifier, 4), 1, MaxStrLen(GLAccount."No."));
        GLAccount.Name := CopyStr(this.GetToken(Alert.UniqueIdentifier, 5), 1, MaxStrLen(GLAccount.Name));
        GLAccount."Direct Posting" := false;
        GLAccount.Insert(true);
        Page.Run(Page::"G/L Account Card", GLAccount);
    end;

    local procedure GetToken(Text: Text; Index: Integer): Text
    var
        ListOfText: List of [Text];
    begin
        ListOfText := Text.Split('|');
        if ListOfText.Count >= Index then
            exit(ListOfText.Get(Index));
    end;

    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])
    begin
        CustomDimensions.Add('AlertWhereUsed', Alert.ShortDescription);
        CustomDimensions.Add('AlertGLAccountSystemId', Alert.UniqueIdentifier);
    end;

    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text
    begin
        exit(Alert.LongDescription);
    end;

    [BusinessEvent(false)]
    local procedure OnBeforeMustBeDirectPosting(var RecordRef: RecordRef; var FieldRef: FieldRef; var IsHandled: Boolean)
    begin
    end;
}