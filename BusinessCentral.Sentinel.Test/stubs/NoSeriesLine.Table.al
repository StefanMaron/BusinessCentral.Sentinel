// Stub for Microsoft.Foundation.NoSeries."No. Series Line"
namespace Microsoft.Foundation.NoSeries;

table 309 "No. Series Line"
{
    fields
    {
        field(1; "Series Code"; Code[20]) { }
        field(2; "Line No."; Integer) { }
        field(10; Implementation; Enum "No. Series Implementation") { }
    }

    keys
    {
        key(PK; "Series Code", "Line No.") { Clustered = true; }
    }
}

// The Implementation field expects an extensible enum that implements the
// "No. Series - Single" interface. We stub a minimal enum here so rule code
// that reads NoSeriesLine.Implementation compiles under al-runner.
enum 309 "No. Series Implementation" implements "No. Series - Single"
{
    Extensible = true;

    value(0; Normal)
    {
        Implementation = "No. Series - Single" = "No. Series - Default Impl.";
    }
}

codeunit 396 "No. Series - Default Impl." implements "No. Series - Single"
{
    procedure MayProduceGaps(): Boolean
    begin
        exit(false);
    end;
}
