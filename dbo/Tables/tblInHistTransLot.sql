CREATE TABLE [dbo].[tblInHistTransLot] (
    [HeaderID]   BIGINT           NOT NULL,
    [SeqNum]     INT              NOT NULL,
    [LotNum]     [dbo].[pLotNum]  NOT NULL,
    [Qty]        [dbo].[pDecimal] NOT NULL,
    [QtyBase]    [dbo].[pDecimal] NOT NULL,
    [CostUnit]   [dbo].[pDecimal] NOT NULL,
    [CostExt]    [dbo].[pDecimal] NOT NULL,
    [HistSeqNum] INT              NOT NULL,
    [QtySeqNum]  INT              NOT NULL,
    [Cmnt]       NVARCHAR (35)    NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK_tblInHistTransLot] PRIMARY KEY CLUSTERED ([HeaderID] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistTransLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistTransLot';

