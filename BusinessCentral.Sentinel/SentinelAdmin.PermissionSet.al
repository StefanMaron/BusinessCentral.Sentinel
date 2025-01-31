namespace STM.BusinessCentral.Sentinel;

using STM.BusinessCentral.Sentinel;

permissionset 71180275 SentinelAdminSESTM
{
    Access = Internal;
    Assignable = true;
    Caption = 'Sentinel Admin', MaxLength = 30;
    Permissions = table AlertSESTM = X,
        tabledata AlertSESTM = RIMD,
        table IgnoredAlertsSESTM = X,
        tabledata IgnoredAlertsSESTM = RIMD,
        table SentinelRuleSetSESTM = X,
        tabledata SentinelRuleSetSESTM = RIMD,
        table SentinelSetup = X,
        tabledata SentinelSetup = RIMD,
        codeunit AlertDevScopeExtSESTM = X,
        codeunit AlertPteDownloadCodeSESTM = X,
        codeunit AlertSESTM = X,
        codeunit AnalysisNotScheduledSESTM = X,
        codeunit DemoDataExtInProdSESTM = X,
        codeunit EvaluationCompanyInProdSESTM = X,
        codeunit NonPostNoSeriesGapsSESTM = X,
        codeunit ReRunAllAlerts = X,
        codeunit SentinelTelemetryLoggerSESTM = X,
        codeunit TelemetryHelperSESTM = X,
        codeunit UnusedExtensionInstalledSESTM = X,
        codeunit UserWithSuperSESTM = X,
        page AlertListSESTM = X,
        page SentinelRuleSetSESTM = X,
        page SentinelSetup = X;
}