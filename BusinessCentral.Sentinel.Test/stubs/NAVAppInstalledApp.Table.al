// Stub for System.Apps."NAV App Installed App"
namespace System.Apps;

table 2000000153 "NAV App Installed App"
{
    fields
    {
        field(1; "Package ID"; Guid) { }
        field(2; "App ID"; Guid) { }
        field(3; Name; Text[250]) { }
        field(4; Publisher; Text[250]) { }
        field(5; "Version Major"; Integer) { }
        field(6; "Version Minor"; Integer) { }
        field(7; "Version Build"; Integer) { }
        field(8; "Version Revision"; Integer) { }
        field(9; "Published As"; Option)
        {
            OptionMembers = Global,PTE,Dev;
        }
    }

    keys
    {
        key(PK; "Package ID") { Clustered = true; }
    }
}
