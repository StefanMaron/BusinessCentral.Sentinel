// Stub for System.Apps."Extension Management"
namespace System.Apps;

using System.Utilities;

codeunit 2504 "Extension Management"
{
    procedure GetExtensionSource(PackageId: Guid; var ExtensionSourceTempBlob: Codeunit "Temp Blob")
    begin
        Error('Source code not available');
    end;
}
