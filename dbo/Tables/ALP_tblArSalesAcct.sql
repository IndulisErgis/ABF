CREATE TABLE [dbo].[ALP_tblArSalesAcct] (
    [AlpAcctCode]         [dbo].[pGLAcctCode] NOT NULL,
    [AlpGLAcctCOGSContra] NVARCHAR (40)       NULL,
    [Alpts]               ROWVERSION          NULL,
    CONSTRAINT [PK_ALP_tblArSalesAcct] PRIMARY KEY CLUSTERED ([AlpAcctCode] ASC)
);

