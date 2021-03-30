CREATE TABLE [dbo].[tblSvHistoryWorkOrderTransExt] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [TransID]        BIGINT          NOT NULL,
    [LotNum]         [dbo].[pLotNum] NULL,
    [ExtLocA]        INT             NULL,
    [ExtLocB]        INT             NULL,
    [QtyEstimated]   [dbo].[pDec]    NOT NULL,
    [QtyUsed]        [dbo].[pDec]    NOT NULL,
    [UnitCost]       [dbo].[pDec]    NOT NULL,
    [HistSeqNum]     INT             NULL,
    [QtySeqNum_Cmtd] INT             NULL,
    [QtySeqNum_Ext]  INT             NULL,
    [QtySeqNum]      INT             NULL,
    [Cmnt]           NVARCHAR (35)   NULL,
    [CF]             XML             NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderTransExt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderTransExt';

