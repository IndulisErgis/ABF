CREATE TABLE [dbo].[tblArSalesAcct] (
    [AcctCode]    [dbo].[pGLAcctCode] NOT NULL,
    [Desc]        VARCHAR (35)        NULL,
    [GlAcctSales] [dbo].[pGlAcct]     NULL,
    [GlAcctCOGS]  [dbo].[pGlAcct]     NULL,
    [ts]          ROWVERSION          NULL,
    [CF]          XML                 NULL,
    CONSTRAINT [PK__tblArSalesAcct__38EE7070] PRIMARY KEY CLUSTERED ([AcctCode] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArSalesAcct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArSalesAcct';

