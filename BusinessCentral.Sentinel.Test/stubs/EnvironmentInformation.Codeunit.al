// Stub for System.Environment."Environment Information"
namespace System.Environment;

codeunit 457 "Environment Information"
{
    procedure IsSaaS(): Boolean
    begin
        exit(false);
    end;

    procedure IsProduction(): Boolean
    begin
        exit(false);
    end;

    procedure IsSandbox(): Boolean
    begin
        exit(true);
    end;
}
