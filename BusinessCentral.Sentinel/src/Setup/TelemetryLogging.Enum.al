namespace STM.BusinessCentral.Sentinel;

enum 71180279 TelemetryLogging
{
    Access = Internal;
    Extensible = true;


    value(1; Daily)
    {
        Caption = 'Daily';
    }
    value(2; OnRuleLogging)
    {
        Caption = 'On Rule Logging';
    }
}