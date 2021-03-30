CREATE TABLE [dbo].[ALP_tblInGLAcct] (
    [AlpGLAcctCode]       [dbo].[pGLAcctCode] NOT NULL,
    [AlpGLAcctSalesLease] [dbo].[pGlAcct]     NULL,
    [AlpGLAcctCogsLease]  [dbo].[pGlAcct]     NULL,
    [Alpts]               ROWVERSION          NULL,
    CONSTRAINT [PK__ALP_tblInGLAcct__0DCF0841] PRIMARY KEY CLUSTERED ([AlpGLAcctCode] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = N'11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALP_tblInGLAcct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = N'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ALP_tblInGLAcct';

