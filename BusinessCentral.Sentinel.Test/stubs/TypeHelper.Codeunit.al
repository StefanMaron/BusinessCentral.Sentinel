// Stub for System.Reflection."Type Helper"
namespace System.Reflection;

codeunit 10 "Type Helper"
{
    procedure GetUtcDateTime(): DateTime
    begin
        exit(CurrentDateTime);
    end;

    procedure CRLFSeparator(): Text[2]
    begin
        exit('');
    end;
}
