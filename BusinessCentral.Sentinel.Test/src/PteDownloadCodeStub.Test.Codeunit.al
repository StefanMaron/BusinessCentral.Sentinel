namespace STM.BusinessCentral.Sentinel.Test;

using STM.BusinessCentral.Sentinel;

codeunit 71180511 PteDownloadCodeStubSESTM
{
    EventSubscriberInstance = Manual;
    Access = Internal;

    // A real server happily returns the source of any package, so SE-000001 cannot
    // be provoked with seeded rows. Bind this instance to report "no download".
    [EventSubscriber(ObjectType::Codeunit, Codeunit::AlertPteDownloadCodeSESTM, 'OnBeforeCanDownloadSourceCode', '', false, false)]
    local procedure DenyDownload(PackageId: Guid; var CanDownload: Boolean; var IsHandled: Boolean)
    begin
        CanDownload := false;
        IsHandled := true;
    end;
}
