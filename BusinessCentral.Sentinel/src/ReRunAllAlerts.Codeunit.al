namespace STM.BusinessCentral.Sentinel;
using System.Reflection;
using System.DateTime;
using STM.BusinessCentral.Sentinel;
using System.Threading;

codeunit 71180286 ReRunAllAlerts
{
    Access = Internal;
    Permissions =
        tabledata AlertSESTM = R,
        tabledata "Job Queue Entry" = RI;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        AlertDispatcher: Codeunit AlertDispatcherSESTM;
    begin
        AlertDispatcher.FullRerun();
    end;
}