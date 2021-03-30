CREATE TABLE [dbo].[tblSmItem] (
    [ItemCode]    [dbo].[pItemID] NOT NULL,
    [Desc]        VARCHAR (35)    NULL,
    [GLAcctExp]   [dbo].[pGlAcct] NULL,
    [GLAcctSales] [dbo].[pGlAcct] NULL,
    [GLAcctCogs]  [dbo].[pGlAcct] NULL,
    [GLAcctInv]   [dbo].[pGlAcct] NULL,
    [TaxClass]    TINYINT         CONSTRAINT [DF__tblSmItem__TaxCl__502AD436] DEFAULT (0) NOT NULL,
    [Units]       [dbo].[pUom]    NULL,
    [UnitCost]    [dbo].[pDec]    CONSTRAINT [DF__tblSmItem__UnitC__511EF86F] DEFAULT (0) NULL,
    [UnitPrice]   [dbo].[pDec]    CONSTRAINT [DF__tblSmItem__UnitP__52131CA8] DEFAULT (0) NULL,
    [AddnlDesc]   TEXT            NULL,
    [ts]          ROWVERSION      NULL,
    [CF]          XML             NULL,
    CONSTRAINT [PK__tblSmItem__1352D76D] PRIMARY KEY CLUSTERED ([ItemCode] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmItem';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmItem';

