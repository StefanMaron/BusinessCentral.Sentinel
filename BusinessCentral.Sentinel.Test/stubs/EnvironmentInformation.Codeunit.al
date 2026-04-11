// Stub for System.Environment."Environment Information"
namespace System.Environment;

codeunit 457 "Environment Information"
{
    // Returns false so TelemetryHelperSESTM.LogUsage's `if not IsSaaS exit`
    // short-circuits. Cannot flip to true until upstream ships `Enum.Names()`
    // — the LogUsage body calls `Alert.Names().Get(Alert.AsInteger())` which
    // currently throws `NCLOptionMetadata.GetNames() not supported`.
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
