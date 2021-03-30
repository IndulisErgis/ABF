CREATE TABLE [dbo].[tblCfConfigFieldActionSo] (
    [Id]              INT              IDENTITY (1, 1) NOT NULL,
    [ActionId]        BIGINT           NOT NULL,
    [LocId]           [dbo].[pLocID]   NOT NULL,
    [Uom]             [dbo].[pUom]     NOT NULL,
    [Qty]             [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldActionSo_Qty] DEFAULT ((0)) NOT NULL,
    [UnitCost]        [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldActionSo_UnitCost] DEFAULT ((0)) NOT NULL,
    [OverridePriceYn] BIT              CONSTRAINT [DF_tblCfConfigFieldActionSo_OverridePriceYn] DEFAULT ((0)) NOT NULL,
    [FieldPrice]      [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldActionSo_FieldPrice] DEFAULT ((0)) NOT NULL,
    [FieldPriceYn]    BIT              CONSTRAINT [DF_tblCfConfigFieldActionSo_FieldPriceYn] DEFAULT ((0)) NOT NULL,
    [PriceFormula]    NVARCHAR (300)   NULL,
    [Notes]           NVARCHAR (MAX)   NULL,
    [CF]              XML              NULL,
    [ts]              ROWVERSION       NULL,
    CONSTRAINT [PK_tblCfConfigFieldActionSo] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCfConfigFieldActionSo_ActionId]
    ON [dbo].[tblCfConfigFieldActionSo]([ActionId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldActionSo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldActionSo';

