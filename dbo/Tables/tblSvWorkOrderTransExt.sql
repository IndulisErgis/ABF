CREATE TABLE [dbo].[tblSvWorkOrderTransExt] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [TransID]        BIGINT          NOT NULL,
    [LotNum]         [dbo].[pLotNum] NULL,
    [ExtLocA]        INT             NULL,
    [ExtLocB]        INT             NULL,
    [QtyEstimated]   [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [QtyUsed]        [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [UnitCost]       [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [HistSeqNum]     INT             NULL,
    [QtySeqNum_Cmtd] INT             NULL,
    [QtySeqNum_Ext]  INT             NULL,
    [QtySeqNum]      INT             NULL,
    [Cmnt]           NVARCHAR (35)   NULL,
    [CF]             XML             NULL,
    [ts]             ROWVERSION      NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderTransExt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderTransExt';

