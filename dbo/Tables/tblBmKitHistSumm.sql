CREATE TABLE [dbo].[tblBmKitHistSumm] (
    [HistSeqNum] INT          NOT NULL,
    [BmBomId]    INT          NULL,
    [ItemId]     VARCHAR (24) NOT NULL,
    [LocId]      VARCHAR (10) NOT NULL,
    [SumYear]    SMALLINT     DEFAULT ((0)) NOT NULL,
    [SumPeriod]  SMALLINT     DEFAULT ((0)) NOT NULL,
    [GLPeriod]   SMALLINT     DEFAULT ((0)) NOT NULL,
    [BatchId]    VARCHAR (10) NULL,
    [TransId]    VARCHAR (10) NULL,
    [SrceID]     VARCHAR (10) NULL,
    [Uom]        VARCHAR (5)  NOT NULL,
    [ConvFactor] [dbo].[pDec] DEFAULT ((1)) NOT NULL,
    [Qty]        [dbo].[pDec] DEFAULT ((0)) NULL,
    [Cost]       [dbo].[pDec] DEFAULT ((0)) NULL,
    [Price]      [dbo].[pDec] DEFAULT ((0)) NULL,
    [CustId]     VARCHAR (10) NULL,
    [TransDate]  DATETIME     NULL,
    [Counter]    INT          IDENTITY (1, 1) NOT NULL,
    [InvcNum]    VARCHAR (15) NULL,
    [ts]         ROWVERSION   NULL,
    [CF]         XML          NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmKitHistSumm';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmKitHistSumm';

