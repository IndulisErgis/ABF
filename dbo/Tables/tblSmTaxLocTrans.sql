CREATE TABLE [dbo].[tblSmTaxLocTrans] (
    [EntryNum]      INT              IDENTITY (1, 1) NOT NULL,
    [TaxLocId]      [dbo].[pTaxLoc]  NOT NULL,
    [TaxClassCode]  TINYINT          DEFAULT ((0)) NOT NULL,
    [PostRun]       [dbo].[pPostRun] NULL,
    [SourceCode]    VARCHAR (2)      NULL,
    [LinkID]        VARCHAR (15)     NULL,
    [LinkIDSub]     VARCHAR (15)     NULL,
    [LinkIDSubLine] INT              DEFAULT ((0)) NULL,
    [TransDate]     DATETIME         NULL,
    [GLPeriod]      SMALLINT         DEFAULT ((0)) NULL,
    [FiscalYear]    SMALLINT         DEFAULT ((0)) NULL,
    [TaxSales]      [dbo].[pDec]     DEFAULT ((0)) NULL,
    [NonTaxSales]   [dbo].[pDec]     DEFAULT ((0)) NULL,
    [TaxCollect]    [dbo].[pDec]     DEFAULT ((0)) NULL,
    [TaxPurch]      [dbo].[pDec]     DEFAULT ((0)) NULL,
    [NonTaxPurch]   [dbo].[pDec]     DEFAULT ((0)) NULL,
    [TaxCalcSales]  [dbo].[pDec]     DEFAULT ((0)) NULL,
    [TaxCalcPurch]  [dbo].[pDec]     DEFAULT ((0)) NULL,
    [TaxPaid]       [dbo].[pDec]     DEFAULT ((0)) NULL,
    [TaxRefund]     [dbo].[pDec]     DEFAULT ((0)) NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK_tblSmTaxLocTrans] PRIMARY KEY CLUSTERED ([EntryNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmTaxLocTrans_LocCode]
    ON [dbo].[tblSmTaxLocTrans]([TaxLocId] ASC, [TaxClassCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxLocTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxLocTrans';

