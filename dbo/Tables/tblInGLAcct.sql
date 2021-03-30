CREATE TABLE [dbo].[tblInGLAcct] (
    [GLAcctCode]          [dbo].[pGLAcctCode] NOT NULL,
    [Descr]               VARCHAR (35)        NULL,
    [GLAcctSales]         [dbo].[pGlAcct]     NULL,
    [GLAcctCogs]          [dbo].[pGlAcct]     NULL,
    [GLAcctInv]           [dbo].[pGlAcct]     NULL,
    [GLAcctWip]           [dbo].[pGlAcct]     NULL,
    [GLAcctInvAdj]        [dbo].[pGlAcct]     NULL,
    [GLAcctCogsAdj]       [dbo].[pGlAcct]     NULL,
    [GLAcctPurchPriceVar] [dbo].[pGlAcct]     NULL,
    [GLAcctStandCostVar]  [dbo].[pGlAcct]     NULL,
    [GLAcctPhyCountAdj]   [dbo].[pGlAcct]     NULL,
    [GLAcctXferCost]      [dbo].[pGlAcct]     NULL,
    [ts]                  ROWVERSION          NULL,
    [GLAcctInTransit]     [dbo].[pGlAcct]     NULL,
    [CF]                  XML                 NULL,
    [GLAcctAccrual]       [dbo].[pGlAcct]     NULL,
    CONSTRAINT [PK__tblInGLAcct__0DCF0841] PRIMARY KEY CLUSTERED ([GLAcctCode] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInGLAcct] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInGLAcct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInGLAcct';

