// Stub for Microsoft.Foundation.NoSeries."No. Series"
namespace Microsoft.Foundation.NoSeries;

table 308 "No. Series"
{
    fields
    {
        field(1; "Code"; Code[20]) { }
        field(2; Description; Text[100]) { }
    }

    keys
    {
        key(PK; "Code") { Clustered = true; }
    }
}
