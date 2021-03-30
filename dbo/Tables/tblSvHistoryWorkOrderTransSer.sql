CREATE TABLE [dbo].[tblSvHistoryWorkOrderTransSer] (
    [ID]          INT             IDENTITY (1, 1) NOT NULL,
    [TransID]     BIGINT          NOT NULL,
    [SerNum]      [dbo].[pSerNum] NOT NULL,
    [LotNum]      [dbo].[pLotNum] NULL,
    [ExtLocA]     INT             NULL,
    [ExtLocB]     INT             NULL,
    [UnitCost]    [dbo].[pDec]    NOT NULL,
    [UnitCostACV] [dbo].[pDec]    NOT NULL,
    [UnitPrice]   [dbo].[pDec]    NOT NULL,
    [HistSeqNum]  INT             NULL,
    [Cmnt]        NVARCHAR (35)   NULL,
    [CF]          XML             NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderTransSer';

