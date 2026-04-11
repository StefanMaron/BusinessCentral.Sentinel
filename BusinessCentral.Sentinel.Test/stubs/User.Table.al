// Stub for System.Security.User.User — used by al-runner only.
namespace System.Security.User;

table 2000000120 User
{
    fields
    {
        field(1; "User Security ID"; Guid) { }
        field(2; "User Name"; Code[50]) { }
        field(11; "License Type"; Option)
        {
            OptionMembers = "Full User","Limited User","Device Only User","Windows Group","External User","External Administrator","External Accountant","Application","AAD Group";
        }
    }

    keys
    {
        key(PK; "User Security ID") { Clustered = true; }
    }
}
