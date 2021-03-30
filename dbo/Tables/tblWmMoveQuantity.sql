CREATE TABLE [dbo].[tblWmMoveQuantity] (
    [Id]          INT               IDENTITY (1, 1) NOT NULL,
    [ParentId]    INT               NULL,
    [MoveBy]      TINYINT           CONSTRAINT [DF_tblWmMoveQuantity_MoveBy] DEFAULT ((0)) NOT NULL,
    [MoveById]    [dbo].[pItemID]   NOT NULL,
    [LocID]       [dbo].[pLocID]    NOT NULL,
    [LotNum]      [dbo].[pLotNum]   NULL,
    [SerNum]      [dbo].[pSerNum]   NULL,
    [ExtLocAFrom] INT               NULL,
    [ExtLocBFrom] INT               NULL,
    [ExtLocATo]   INT               NULL,
    [ExtLocBTo]   INT               NULL,
    [Qty]         [dbo].[pDec]      NOT NULL,
    [UOM]         [dbo].[pUom]      NULL,
    [EntryDate]   DATETIME          CONSTRAINT [DF_tblWmMoveQuantity_EntryDate] DEFAULT (getdate()) NOT NULL,
    [TransDate]   DATETIME          CONSTRAINT [DF_tblWmMoveQuantity_TransDate] DEFAULT (getdate()) NOT NULL,
    [UID]         [dbo].[pUserID]   NOT NULL,
    [HostId]      [dbo].[pWrkStnID] NOT NULL,
    [CF]          XML               NULL,
    [ts]          ROWVERSION        NULL,
    CONSTRAINT [PK_tblWmMoveQuantity] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmMoveQuantity_ParentId]
    ON [dbo].[tblWmMoveQuantity]([ParentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmMoveQuantity_UserIdWrkStnId]
    ON [dbo].[tblWmMoveQuantity]([UID] ASC, [HostId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmMoveQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmMoveQuantity';

