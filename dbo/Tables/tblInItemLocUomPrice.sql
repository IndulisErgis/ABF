CREATE TABLE [dbo].[tblInItemLocUomPrice] (
    [ItemId]    [dbo].[pItemID] NOT NULL,
    [LocId]     [dbo].[pLocID]  NOT NULL,
    [Uom]       [dbo].[pUom]    NOT NULL,
    [BrkId]     VARCHAR (10)    NULL,
    [PriceAvg]  [dbo].[pDec]    CONSTRAINT [DF__tblInItem__Price__0D09C544] DEFAULT (0) NULL,
    [PriceMin]  [dbo].[pDec]    CONSTRAINT [DF__tblInItem__Price__0DFDE97D] DEFAULT (0) NULL,
    [PriceList] [dbo].[pDec]    CONSTRAINT [DF__tblInItem__Price__0EF20DB6] DEFAULT (0) NULL,
    [PriceBase] [dbo].[pDec]    CONSTRAINT [DF__tblInItem__Price__0FE631EF] DEFAULT (0) NULL,
    [ts]        ROWVERSION      NULL,
    [CF]        XML             NULL,
    CONSTRAINT [PK__tblInItemLocUomP__1D114BD1] PRIMARY KEY CLUSTERED ([ItemId] ASC, [LocId] ASC, [Uom] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemLocUomPrice] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLocUomPrice';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLocUomPrice';

