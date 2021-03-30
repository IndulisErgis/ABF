CREATE TABLE [dbo].[tblArDistCode] (
    [DistCode]                       [dbo].[pDistCode] NOT NULL,
    [Desc]                           VARCHAR (25)      NULL,
    [GLAcctReceivables]              [dbo].[pGlAcct]   NULL,
    [GLAcctSalesTax]                 [dbo].[pGlAcct]   NULL,
    [GLAcctFreight]                  [dbo].[pGlAcct]   NULL,
    [GLAcctMisc]                     [dbo].[pGlAcct]   NULL,
    [ts]                             ROWVERSION        NULL,
    [CF]                             XML               NULL,
    [GLAcctDepositReceivables]       [dbo].[pGlAcct]   NULL,
    [GLAcctDepositReceivablesContra] [dbo].[pGlAcct]   NULL,
    CONSTRAINT [PK__tblArDistCode__27C3E46E] PRIMARY KEY CLUSTERED ([DistCode] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArDistCode] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArDistCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArDistCode';

