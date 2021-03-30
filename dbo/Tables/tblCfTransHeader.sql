CREATE TABLE [dbo].[tblCfTransHeader] (
    [TransId]         BIGINT           NOT NULL,
    [CurrentDetailId] BIGINT           NULL,
    [ExchRate]        [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_ExchRate] DEFAULT ((1)) NOT NULL,
    [SourceType]      TINYINT          NOT NULL,
    [SourceTransId]   [dbo].[pTransID] NOT NULL,
    [SourceEntryNum]  BIGINT           NOT NULL,
    [ConfigId]        BIGINT           NOT NULL,
    [ConfigType]      TINYINT          NOT NULL,
    [CustId]          [dbo].[pCustID]  NULL,
    [TransDate]       DATETIME         CONSTRAINT [DF_tblCfTransHeader_TransDate] DEFAULT (getdate()) NOT NULL,
    [BasePrice]       [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_BasePrice] DEFAULT ((0)) NOT NULL,
    [BasePriceFgn]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_BasePriceFgn] DEFAULT ((0)) NOT NULL,
    [OptionsPrice]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_OptionsPrice] DEFAULT ((0)) NOT NULL,
    [OptionsPriceFgn] [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_OptionsPriceFgn] DEFAULT ((0)) NOT NULL,
    [Discount]        [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_Discount] DEFAULT ((0)) NOT NULL,
    [DiscountFgn]     [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_DiscountFgn] DEFAULT ((0)) NOT NULL,
    [TotalPrice]      [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_TotalPrice] DEFAULT ((0)) NOT NULL,
    [TotalPriceFgn]   [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_TotalPriceFgn] DEFAULT ((0)) NOT NULL,
    [TotalCost]       [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_TotalCost] DEFAULT ((0)) NOT NULL,
    [TotalCostFgn]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_TotalCostFgn] DEFAULT ((0)) NOT NULL,
    [GrossProfit]     [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_GrossProfit] DEFAULT ((0)) NOT NULL,
    [GrossProfitFgn]  [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_GrossProfitFgn] DEFAULT ((0)) NOT NULL,
    [DiscountPct]     [dbo].[pDecimal] CONSTRAINT [DF_tblCfTransHeader_DiscountPct] DEFAULT ((0)) NOT NULL,
    [NewItemId]       [dbo].[pItemID]  NULL,
    [NewBomId]        [dbo].[pItemID]  NULL,
    [NewEntryNum]     INT              NULL,
    [NewProdOrder]    [dbo].[pTransID] NULL,
    [PrintPOYN]       BIT              CONSTRAINT [DF_tblCfTransHeader_PrintPOYN] DEFAULT ((0)) NOT NULL,
    [CF]              XML              NULL,
    [ts]              ROWVERSION       NULL,
    [AllowConstraint] BIT              CONSTRAINT [DF_tblCfTransHeader_AllowConstraint] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblCfTransHeader] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCfTransHeader_SourceTypeSourceTransIdSourceEntryNum]
    ON [dbo].[tblCfTransHeader]([SourceType] ASC, [SourceTransId] ASC, [SourceEntryNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfTransHeader';

