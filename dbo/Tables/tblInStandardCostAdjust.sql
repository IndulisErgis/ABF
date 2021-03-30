CREATE TABLE [dbo].[tblInStandardCostAdjust] (
    [TransId]      INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]       [dbo].[pItemID] NOT NULL,
    [LocId]        [dbo].[pLocID]  NOT NULL,
    [UnitCost]     [dbo].[pDec]    CONSTRAINT [DF_tblInStandardCostAdjust_UnitCost] DEFAULT ((0)) NOT NULL,
    [EntryDate]    DATETIME        CONSTRAINT [DF_tblInStandardCostAdjust_EntryDate] DEFAULT (getdate()) NOT NULL,
    [TransDate]    DATETIME        CONSTRAINT [DF_tblInStandardCostAdjust_TransDate] DEFAULT (getdate()) NOT NULL,
    [GLAccount]    [dbo].[pGlAcct] NULL,
    [FiscalPeriod] SMALLINT        NOT NULL,
    [FiscalYear]   SMALLINT        NOT NULL,
    [CF]           XML             NULL,
    [ts]           ROWVERSION      NULL,
    CONSTRAINT [PK_tblInStandardCostAdjust] PRIMARY KEY NONCLUSTERED ([TransId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblInStandardCostAdjust_ItemIdLocId]
    ON [dbo].[tblInStandardCostAdjust]([ItemId] ASC, [LocId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInStandardCostAdjust';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInStandardCostAdjust';

