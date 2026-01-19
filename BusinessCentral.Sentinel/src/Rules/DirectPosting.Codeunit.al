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
    begin
        this.CheckPostingGroup(Database::"Customer Posting Group");
        this.CheckPostingGroup(Database::"Customer Posting Group");
        this.CheckPostingGroup(Database::"Vendor Posting Group");
        this.CheckPostingGroup(Database::"Job Posting Group");
        this.CheckPostingGroup(Database::"General Posting Setup");
        this.CheckPostingGroup(Database::"Bank Account Posting Group");
        this.CheckPostingGroup(Database::"VAT Posting Setup");
        this.CheckPostingGroup(Database::"FA Posting Group");
        this.CheckPostingGroup(Database::"Inventory Posting Setup");
    end;

    local procedure CheckPostingGroup(pTableID: Integer)
    var
        RecordRef: RecordRef;
        KeyRef: KeyRef;
    begin
        RecordRef.Open(pTableID);
        KeyRef := RecordRef.KeyIndex(1);
        if RecordRef.FindSet() then
            repeat
                this.CheckAccounts(RecordRef, KeyRef)
            until RecordRef.Next() = 0;
    end;

    local procedure CheckAccounts(pRecordRef: RecordRef; pKeyRef: KeyRef)
    var
        FieldRef: FieldRef;
        i: Integer;
    begin
        for i := 1 to pRecordRef.FieldCount() do begin
            FieldRef := pRecordRef.FieldIndex(i);
            if FieldRef.Relation = Database::"G/L Account" then
                this.CheckAccount(pRecordRef, pKeyRef, FieldRef);
        end;
    end;

    local procedure CheckAccount(pRecordRef: RecordRef; pKeyRef: KeyRef; pFieldRef: FieldRef)
    var
        GLAccount: Record "G/L Account";
        Alert: Record AlertSESTM;
        ShortDescLbl: Label '"%1" %2 "%3" %4 : "%5" show not be allowed', Comment = '%1 = WhereUsed.TableCaption, %2 = WhereUsed PrimaryKey, %3 = UsedAs.FieldCaption(), %4 = "G/L Account"."No.", %5 : FieldCaption("Direct Posting")';
        LongDescLbl: Label 'G/L Account %1 (%2) should not be %3 allowed when used for %4 %5 as %6.', Comment = '%1 = "G/L Account"."No.", %2 = "G/L Account".Name, %3 = FieldCaption("Direct Posting"), %4 = WhereUsed.TableCaption, %5 = WhereUsed PrimaryKey, %6 = UsedAs.FieldCaption()';
        CallToActionLbl: Label 'Set "%1" not allowed for %2 %3 "%4"', Comment = '%1 = FieldCaption("Direct Posting"), %2 = TableCaption, %3 = "G/L Account"."No.", %4 = "G/L Account".Name';
        DoesntExistsLbl: Label '!! doesn''t exists !!';
    begin
        GLAccount."No." := pFieldRef.Value;
        if GLAccount."No." = '' then
            exit;
        if not GLAccount.Get(GLAccount."No.") then
            GLAccount.Name := DoesntExistsLbl
        else
            if GLAccount."Direct Posting" and not this.MustBeDirectPosting(pRecordRef, pFieldRef) then
                Alert.New(
                    "AlertCodeSESTM"::"SE-000009",
                    StrSubstNo(ShortDescLbl, pRecordRef.Caption, this.KeyValue(pKeyRef), pFieldRef.Caption, GLAccount."No.", GLAccount.FieldCaption("Direct Posting")),
                    SeveritySESTM::Warning,
                    AreaSESTM::Database,
                    StrSubstNo(LongDescLbl, GLAccount."No.", GLAccount.Name, GLAccount.FieldCaption("Direct Posting"), pRecordRef.Caption, this.KeyValue(pKeyRef), pFieldRef.Caption),
                    StrSubstNo(CallToActionLbl, GLAccount.FieldCaption("Direct Posting"), pRecordRef.Caption, GLAccount."No.", GLAccount.Name),
                    GLAccount.SystemId
                );
    end;

    local procedure KeyValue(pKeyRef: KeyRef) ReturnValue: Text
    var
        FieldRef: FieldRef;
        i: Integer;
        ValueAsText: Text;
    begin
        for i := 1 to pKeyRef.FieldCount do begin
            FieldRef := pKeyRef.FieldIndex(i);
            if ReturnValue <> '' then
                ReturnValue += ', ';
            Evaluate(ValueAsText, FieldRef.Value);
            ReturnValue += ValueAsText;
        end;
    end;

    local procedure MustBeDirectPosting(var pRecordRef: RecordRef; var pFieldRef: FieldRef): Boolean
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        if (pRecordRef.Number = Database::"FA Posting Group") and (pFieldRef.Number = FAPostingGroup.FieldNo("Depreciation Expense Acc.")) then
            exit(true);
    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    var
        WikiLinkTok: Label 'https://github.com/StefanMaron/BusinessCentral.Sentinel/wiki/SE-000009', Locked = true;
    begin
        Hyperlink(WikiLinkTok);
    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.GetBySystemId(Alert.UniqueIdentifier);
        Page.Run(Page::"G/L Account Card", GLAccount);
    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.GetBySystemId(Alert.UniqueIdentifier);
        GLAccount.Validate("Direct Posting", false);
        GLAccount.Modify(true);
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
}