// Stub for System.Security.AccessControl."Access Control"
namespace System.Security.AccessControl;

table 2000000053 "Access Control"
{
    fields
    {
        field(1; "User Security ID"; Guid) { }
        field(2; "Role ID"; Code[20]) { }
        field(4; "Company Name"; Text[30]) { }
    }

    keys
    {
        key(PK; "User Security ID", "Role ID", "Company Name") { Clustered = true; }
    }
}
