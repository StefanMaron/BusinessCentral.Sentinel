// Stub for System.Threading."Job Queue Entry"
namespace System.Threading;

table 472 "Job Queue Entry"
{
    fields
    {
        field(1; ID; Guid) { }
        field(2; "User ID"; Code[50]) { }
        field(3; "Last Ready State"; DateTime) { }
        field(4; "Expiration Date/Time"; DateTime) { }
        field(5; "Earliest Start Date/Time"; DateTime) { }
        field(6; "Object Type to Run"; Option)
        {
            OptionMembers = "Report",Codeunit;
        }
        field(7; "Object ID to Run"; Integer) { }
        field(9; Status; Option)
        {
            OptionMembers = Ready,"In Process",Error,"On Hold",Finished,"On Hold with Inactivity Timeout";
        }
        field(37; "Recurring Job"; Boolean) { }
        field(38; "Run on Mondays"; Boolean) { }
        field(39; "Run on Tuesdays"; Boolean) { }
        field(40; "Run on Wednesdays"; Boolean) { }
        field(41; "Run on Thursdays"; Boolean) { }
        field(42; "Run on Fridays"; Boolean) { }
        field(43; "Run on Saturdays"; Boolean) { }
        field(44; "Run on Sundays"; Boolean) { }
        field(45; "Next Run Date Formula"; DateFormula) { }
    }

    keys
    {
        key(PK; ID) { Clustered = true; }
    }
}
