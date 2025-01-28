namespace STM.BusinessCentral.Sentinel;

enum 71180275 "AlertCodeSESTM" implements IAuditAlertSESTM
{
    Access = Internal;
    DefaultImplementation = IAuditAlertSESTM = AlertSESTM;
    Extensible = false;
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
    /// Evaluation Company detected
    /// </summary>
    value(3; "SE-000003")
    {
        Caption = 'SE-000003';
        Implementation = IAuditAlertSESTM = EvaluationCompanyInProdSESTM;
    }
    /// <summary>
    /// Demo Data Extensions should get uninstalled
    /// </summary>
    value(4; "SE-000004")
    {
        Caption = 'SE-000004';
        Implementation = IAuditAlertSESTM = DemoDataExtInProdSESTM;
    }
    /// <summary>
    /// Inform about users with Super permissions
    /// </summary>
    value(5; "SE-000005")
    {
        Caption = 'SE-000005';
        Implementation = IAuditAlertSESTM = UserWithSuperSESTM;
    }
    /// <summary>
    /// Consider configuring non-posting number series to allow gaps to increase performance
    /// </summary>
    value(6; "SE-000006")
    {
        Caption = 'SE-000006';
        Implementation = IAuditAlertSESTM = NonPostNoSeriesGapsSESTM;
    }
    /// <summary>
    /// Warns if and Extension is installed and but unused
    /// </summary>
    value(7; "SE-000007")
    {
        Caption = 'SE-000007';
        Implementation = IAuditAlertSESTM = UnusedExtensionInstalledSESTM;
    }
    /// <summary>
    /// Informs that the Alert analysis is not scheduled
    /// </summary>
    value(8; "SE-000008")
    {
        Caption = 'SE-000008';
        Implementation = IAuditAlertSESTM = AnalysisNotScheduledSESTM;
    }
}