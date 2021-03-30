CREATE TABLE [dbo].[tblWmHistMoveQuantity] (
    [PostRun]       [dbo].[pPostRun]  NOT NULL,
    [ID]            INT               NOT NULL,
    [ParentID]      INT               NULL,
    [MoveBy]        TINYINT           NOT NULL,
    [MoveByID]      [dbo].[pItemID]   NOT NULL,
    [LocID]         [dbo].[pLocID]    NOT NULL,
    [LotNum]        [dbo].[pLotNum]   NULL,
    [SerNum]        [dbo].[pSerNum]   NULL,
    [ExtLocAFrom]   INT               NULL,
    [ExtLocBFrom]   INT               NULL,
    [ExtLocATo]     INT               NULL,
    [ExtLocBTo]     INT               NULL,
    [ExtLocAIDFrom] NVARCHAR (10)     NULL,
    [ExtLocBIDFrom] NVARCHAR (10)     NULL,
    [ExtLocAIDTo]   NVARCHAR (10)     NULL,
    [ExtLocBIDTo]   NVARCHAR (10)     NULL,
    [Qty]           [dbo].[pDecimal]  NOT NULL,
    [QtyBase]       [dbo].[pDecimal]  NOT NULL,
    [UOM]           [dbo].[pUom]      NULL,
    [UOMBase]       [dbo].[pUom]      NULL,
    [EntryDate]     DATETIME          NOT NULL,
    [TransDate]     DATETIME          NOT NULL,
    [UID]           [dbo].[pUserID]   NOT NULL,
    [HostID]        [dbo].[pWrkStnID] NOT NULL,
    [CF]            XML               NULL,
    CONSTRAINT [PK_tblWmHistMoveQuantity] PRIMARY KEY CLUSTERED ([PostRun] ASC, [ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmHistMoveQuantity_ParentID]
    ON [dbo].[tblWmHistMoveQuantity]([ParentID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistMoveQuantity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistMoveQuantity';

