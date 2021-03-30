CREATE TABLE [dbo].[tblCfTransDetailExt] (
    [SeqNum]         INT              IDENTITY (1, 1) NOT NULL,
    [DetailId]       BIGINT           NOT NULL,
    [ValueId]        BIGINT           NULL,
    [Answer]         NVARCHAR (50)    NULL,
    [FieldPriceYn]   BIT              CONSTRAINT [DF_tblCfTransDetailExt_FieldPriceYn] DEFAULT ((0)) NOT NULL,
    [FieldPrice]     [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransDetailExt_FieldPrice] DEFAULT ((0)) NOT NULL,
    [ItemId]         [dbo].[pItemID]  NULL,
    [LocId]          [dbo].[pLocID]   NULL,
    [Uom]            [dbo].[pUom]     NULL,
    [FormulaYn]      BIT              CONSTRAINT [DF_tblCfTransDetailExt_FormulaYn] DEFAULT ((0)) NOT NULL,
    [QtyFormula]     NVARCHAR (300)   NULL,
    [Quantity]       [dbo].[pDecimal] NULL,
    [UnitPrice]      [dbo].[pDecimal] NULL,
    [UnitPriceFgn]   [dbo].[pDecimal] NULL,
    [ExtPrice]       [dbo].[pDecimal] NULL,
    [ExtPriceFgn]    [dbo].[pDecimal] NULL,
    [UnitCost]       [dbo].[pDecimal] NULL,
    [UnitCostFgn]    [dbo].[pDecimal] NULL,
    [AdjUnitCost]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransDetailExt_AdjUnitCost] DEFAULT ((0)) NOT NULL,
    [AdjUnitCostFgn] [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransDetailExt_AdjUnitCostFgn] DEFAULT ((0)) NOT NULL,
    [ExtCost]        [dbo].[pDecimal] NULL,
    [ExtCostFgn]     [dbo].[pDecimal] NULL,
    [SelectedYn]     BIT              CONSTRAINT [DF_tblCfTransDetailExt_SelectedYn] DEFAULT ((0)) NOT NULL,
    [Notes]          NVARCHAR (MAX)   NULL,
    [CF]             XML              NULL,
    [ts]             ROWVERSION       NULL,
    CONSTRAINT [PK_tblCfTransDetailExt] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransDetailExt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransDetailExt';

