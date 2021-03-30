CREATE TABLE [dbo].[tblCfConfigFieldValue] (
    [ValueId]       BIGINT           NOT NULL,
    [FieldId]       BIGINT           NOT NULL,
    [ValueDescr]    NVARCHAR (50)    NOT NULL,
    [FieldPriceYn]  BIT              CONSTRAINT [DF_tblCfConfigFieldValue_FieldPriceYn] DEFAULT ((0)) NOT NULL,
    [FieldPrice]    [dbo].[pDecimal] CONSTRAINT [DF_tblCfConfigFieldValue_FieldPrice] DEFAULT ((0)) NOT NULL,
    [ItemId]        [dbo].[pItemID]  NULL,
    [LocId]         [dbo].[pLocID]   NULL,
    [Uom]           [dbo].[pUom]     NULL,
    [FormulaYn]     BIT              CONSTRAINT [DF_tblCfConfigFieldValue_FormulaYn] DEFAULT ((0)) NOT NULL,
    [QtyFormula]    NVARCHAR (300)   NULL,
    [Quantity]      [dbo].[pDecimal] NULL,
    [SmartIdValue]  NVARCHAR (24)    NULL,
    [LongDescr]     NVARCHAR (MAX)   NULL,
    [PictureId]     VARBINARY (MAX)  NULL,
    [ItemPictureYn] BIT              CONSTRAINT [DF_tblCfConfigFieldValue_ItemPictureYn] DEFAULT ((0)) NOT NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblCfConfigFieldValue] PRIMARY KEY CLUSTERED ([ValueId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldValue';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldValue';

