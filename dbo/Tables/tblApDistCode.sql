CREATE TABLE [dbo].[tblApDistCode] (
    [DistCode]       [dbo].[pDistCode] NOT NULL,
    [Desc]           VARCHAR (25)      NULL,
    [PayablesGLAcct] [dbo].[pGlAcct]   NULL,
    [SalesTaxGLAcct] [dbo].[pGlAcct]   NULL,
    [FreightGLAcct]  [dbo].[pGlAcct]   NULL,
    [MiscGLAcct]     [dbo].[pGlAcct]   NULL,
    [ts]             ROWVERSION        NULL,
    [CF]             XML               NULL,
    [AccrualGLAcct]  [dbo].[pGlAcct]   NULL,
    [DepositGLAcct]  [dbo].[pGlAcct]   NULL,
    CONSTRAINT [PK__tblApDistCode__7DCDAAA2] PRIMARY KEY CLUSTERED ([DistCode] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApDistCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApDistCode';

