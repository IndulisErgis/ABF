CREATE TABLE [dbo].[tblInItemUom] (
    [ItemId]      [dbo].[pItemID] NOT NULL,
    [Uom]         [dbo].[pUom]    NOT NULL,
    [ConvFactor]  [dbo].[pDec]    CONSTRAINT [DF__tblInItem__ConvF__24E14ED5] DEFAULT (1) NULL,
    [PenaltyType] TINYINT         CONSTRAINT [DF__tblInItem__Penal__25D5730E] DEFAULT (0) NULL,
    [PenaltyAmt]  [dbo].[pDec]    CONSTRAINT [DF__tblInItem__Penal__26C99747] DEFAULT (0) NULL,
    [UPCcode]     VARCHAR (24)    NULL,
    [ts]          ROWVERSION      NULL,
    [MinSaleQty]  [dbo].[pDec]    DEFAULT ((0)) NULL,
    [Weight]      [dbo].[pDec]    DEFAULT ((0)) NULL,
    [CF]          XML             NULL,
    CONSTRAINT [PK__tblInItemUom__21D600EE] PRIMARY KEY CLUSTERED ([ItemId] ASC, [Uom] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [CK_tblInItemUom] CHECK ([ConvFactor] <> 0)
);


GO
CREATE NONCLUSTERED INDEX [sqlConvFactor]
    ON [dbo].[tblInItemUom]([ConvFactor] ASC) WITH (FILLFACTOR = 80);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemUom] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemUom';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemUom';

