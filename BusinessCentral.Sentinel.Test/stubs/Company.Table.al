// Stub for the BC Company table. Left in the global namespace so unqualified
// `Record Company` references from any rule resolve regardless of which
// `using` directive that rule carries (several different namespace imports
// are mixed in the main src).
table 2000000006 Company
{
    fields
    {
        field(1; Name; Text[30]) { }
        field(2; "Evaluation Company"; Boolean) { }
    }

    keys
    {
        key(PK; Name) { Clustered = true; }
    }
}
