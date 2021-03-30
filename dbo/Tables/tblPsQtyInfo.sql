CREATE TABLE [dbo].[tblPsQtyInfo] (
    [Id]         BIGINT          IDENTITY (1, 1) NOT NULL,
    [ItemId]     [dbo].[pItemID] NOT NULL,
    [LocId]      [dbo].[pLocID]  NOT NULL,
    [LotNum]     [dbo].[pLotNum] NULL,
    [ExtLocA]    INT             NULL,
    [ExtLocB]    INT             NULL,
    [QtyOnHand]  [dbo].[pDec]    NOT NULL,
    [QtyCmtd]    [dbo].[pDec]    NOT NULL,
    [QtyOnOrder] [dbo].[pDec]    NOT NULL,
    [CF]         XML             NULL,
    CONSTRAINT [PK_tblPsQtyInfo] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsQtyInfo_ItemIdLocId]
    ON [dbo].[tblPsQtyInfo]([ItemId] ASC, [LocId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsQtyInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsQtyInfo';

