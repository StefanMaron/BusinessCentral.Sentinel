// Stub for Microsoft.Purchases.Setup."Purchases & Payables Setup"
namespace Microsoft.Purchases.Setup;

table 312 "Purchases & Payables Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10]) { }
        field(51; "Order Nos."; Code[20]) { }
        field(52; "Invoice Nos."; Code[20]) { }
        field(53; "Credit Memo Nos."; Code[20]) { }
        field(54; "Quote Nos."; Code[20]) { }
        field(55; "Vendor Nos."; Code[20]) { }
        field(56; "Blanket Order Nos."; Code[20]) { }
        field(57; "Return Order Nos."; Code[20]) { }
        field(58; "Price List Nos."; Code[20]) { }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
