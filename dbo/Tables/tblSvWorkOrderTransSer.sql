CREATE TABLE [dbo].[tblSvWorkOrderTransSer] (
    [ID]          INT             IDENTITY (1, 1) NOT NULL,
    [TransID]     BIGINT          NOT NULL,
    [SerNum]      [dbo].[pSerNum] NOT NULL,
    [LotNum]      [dbo].[pLotNum] NULL,
    [ExtLocA]     INT             NULL,
    [ExtLocB]     INT             NULL,
    [UnitCost]    [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [UnitCostACV] [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [UnitPrice]   [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [HistSeqNum]  INT             NULL,
    [Cmnt]        NVARCHAR (35)   NULL,
    [CF]          XML             NULL,
    [ts]          ROWVERSION      NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderTransSer';

