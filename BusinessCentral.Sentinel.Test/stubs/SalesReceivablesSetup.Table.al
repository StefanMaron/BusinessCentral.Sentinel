// Stub for Microsoft.Sales.Setup."Sales & Receivables Setup"
namespace Microsoft.Sales.Setup;

table 311 "Sales & Receivables Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10]) { }
        field(51; "Order Nos."; Code[20]) { }
        field(52; "Invoice Nos."; Code[20]) { }
        field(53; "Credit Memo Nos."; Code[20]) { }
        field(54; "Quote Nos."; Code[20]) { }
        field(55; "Customer Nos."; Code[20]) { }
        field(56; "Blanket Order Nos."; Code[20]) { }
        field(57; "Reminder Nos."; Code[20]) { }
        field(58; "Fin. Chrg. Memo Nos."; Code[20]) { }
        field(59; "Direct Debit Mandate Nos."; Code[20]) { }
        field(60; "Price List Nos."; Code[20]) { }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
