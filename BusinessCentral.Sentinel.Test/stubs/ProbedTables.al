// Stubs for the five tables UnusedExtensionInstalled probes via RecRef.Open
// to decide whether an installed extension is actually being used. al-runner
// needs the objects to exist at the referenced IDs; field shape is irrelevant
// because the rule only calls RecRef.IsEmpty after opening.

table 30102 "Shpfy Shop"
{
    fields { field(1; Code; Code[20]) { } }
    keys { key(PK; Code) { Clustered = true; } }
}

table 20101 "AMC Banking Setup"
{
    fields { field(1; "Primary Key"; Code[10]) { } }
    keys { key(PK; "Primary Key") { Clustered = true; } }
}

table 413 "IC Setup"
{
    fields { field(1; "Primary Key"; Code[10]) { } }
    keys { key(PK; "Primary Key") { Clustered = true; } }
}

table 1665 "Payroll Credit Transfer Entry"
{
    fields { field(1; "Entry No."; Integer) { } }
    keys { key(PK; "Entry No.") { Clustered = true; } }
}

table 8053 "Subscription Package"
{
    fields { field(1; "Code"; Code[20]) { } }
    keys { key(PK; Code) { Clustered = true; } }
}
