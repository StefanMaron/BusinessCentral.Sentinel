namespace STM.BusinessCentral.Sentinel;

enum 71180279 TelemetryLogging
{
    Access = Internal;
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    value(1; Daily)
    {
        Caption = 'Daily';
    }
    value(2; OnRuleLogging)
    {
        Caption = 'On Rule Logging';
    }
    value(3; Off)
    {
        Caption = 'Off';
    }
}