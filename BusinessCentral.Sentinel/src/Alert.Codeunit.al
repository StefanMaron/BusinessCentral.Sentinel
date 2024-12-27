namespace STM.BusinessCentral.Sentinel;

codeunit 71180275 AlertSESTM implements IAuditAlertSESTM
{
    Access = Internal;

    procedure RunAlert()
    begin

    end;

    procedure CreateAlerts()
    begin

    end;

    procedure ShowMoreDetails(var Alert: Record AlertSESTM)
    begin

    end;

    procedure ShowRelatedInformation(var Alert: Record AlertSESTM)
    begin

    end;

    procedure AutoFix(var Alert: Record AlertSESTM)
    begin

    end;

    procedure AddCustomTelemetryDimensions(var Alert: Record AlertSESTM; var CustomDimensions: Dictionary of [Text, Text])
    begin

    end;

    procedure GetTelemetryDescription(var Alert: Record AlertSESTM): Text
    begin

    end;
}