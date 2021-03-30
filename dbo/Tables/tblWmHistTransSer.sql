CREATE TABLE [dbo].[tblWmHistTransSer] (
    [HeaderID]   BIGINT           NOT NULL,
    [SeqNum]     INT              NOT NULL,
    [LotNum]     [dbo].[pLotNum]  NULL,
    [SerNum]     [dbo].[pSerNum]  NOT NULL,
    [ExtLocA]    INT              NULL,
    [ExtLocB]    INT              NULL,
    [ExtLocAID]  NVARCHAR (10)    NULL,
    [ExtLocBID]  NVARCHAR (10)    NULL,
    [CostUnit]   [dbo].[pDecimal] NOT NULL,
    [HistSeqNum] INT              NOT NULL,
    [Cmnt]       NVARCHAR (35)    NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK_tblWmHistTransSer] PRIMARY KEY CLUSTERED ([HeaderID] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistTransSer';

