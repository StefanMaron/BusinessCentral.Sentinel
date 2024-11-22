namespace STM.BusinessCentral.Sentinel;

enum 71180275 "AlertCodeSESTM" implements IAuditAlertSESTM
{
    Access = Public;
    DefaultImplementation = IAuditAlertSESTM = AlertSESTM;
    Extensible = true;
    UnknownValueImplementation = IAuditAlertSESTM = AlertSESTM;

    value(0; " ")
    {
        Caption = ' ', Locked = true;
    }
    /// <summary>
    /// Warns if Per Tenant Extension do not allow Download Code
    /// </summary>
    value(1; "SE-000001")
    {
        Caption = 'SE-000001';
        Implementation = IAuditAlertSESTM = AlertPteDownloadCodeSESTM;
    }
    /// <summary>
    /// Warns if Extension in DEV Scope are installed
    /// </summary>
    value(2; "SE-000002")
    {
        Caption = 'SE-000002';
        Implementation = IAuditAlertSESTM = AlertDevScopeExtSESTM;
    }
    /// <summary>
    /// Evaluation Company detected in Production
    /// </summary>
    value(3; "SE-000003")
    {
        Caption = 'SE-000003';
        Implementation = IAuditAlertSESTM = EvaluationCompanyInProdSESTM;
    }
    /// <summary>
    /// Demo Data Extensions should get uninstalled from production
    /// </summary>
    value(4; "SE-000004")
    {
        Caption = 'SE-000004';
        Implementation = IAuditAlertSESTM = DemoDataExtInProdSESTM;
    }
}