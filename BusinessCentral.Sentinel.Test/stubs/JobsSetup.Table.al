// Stub for Microsoft.Projects.Project.Setup."Jobs Setup"
namespace Microsoft.Projects.Project.Setup;

table 315 "Jobs Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10]) { }
        field(10; "Job Nos."; Code[20]) { }
        field(20; "Price List Nos."; Code[20]) { }
    }

    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
}
