CREATE TABLE [dbo].[tblCfConfigFieldActionMtl] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [ActionId]        BIGINT           NOT NULL,
    [CompRevisionNo]  NVARCHAR (3)     NULL,
    [LocId]           [dbo].[pLocID]   NOT NULL,
    [Uom]             [dbo].[pUom]     NOT NULL,
    [UsageType]       TINYINT          NOT NULL,
    [DetailType]      TINYINT          NOT NULL,
    [OverridePriceYn] BIT              CONSTRAINT [DF_tblCfConfigFieldActionMtl_OverridePriceYn] DEFAULT ((0)) NOT NULL,
    [FieldPrice]      [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldActionMtl_FieldPrice] DEFAULT ((0)) NOT NULL,
    [FieldPriceYn]    BIT              CONSTRAINT [DF_tblCfConfigFieldActionMtl_FieldPriceYn] DEFAULT ((0)) NOT NULL,
    [PriceFormula]    NVARCHAR (300)   NULL,
    [QtyFormula]      NVARCHAR (300)   NULL,
    [Qty]             [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldActionMtl_Qty] DEFAULT ((0)) NOT NULL,
    [ScrapPct]        [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldActionMtl_ScrapPct] DEFAULT ((0)) NOT NULL,
    [UnitCost]        [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldActionMtl_UnitCost] DEFAULT ((0)) NOT NULL,
    [CostGroupId]     NVARCHAR (6)     NULL,
    [MGID]            NVARCHAR (10)    NULL,
    [Notes]           NVARCHAR (MAX)   NULL,
    [CF]              XML              NULL,
    [ts]              ROWVERSION       NULL,
    CONSTRAINT [PK_tblCfConfigFieldActionMtl] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCfConfigFieldActionMtl_ActionId]
    ON [dbo].[tblCfConfigFieldActionMtl]([ActionId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldActionMtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldActionMtl';

