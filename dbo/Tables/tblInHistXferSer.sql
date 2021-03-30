CREATE TABLE [dbo].[tblInHistXferSer] (
    [HeaderID]       BIGINT           NOT NULL,
    [SeqNum]         INT              NOT NULL,
    [LotNumFrom]     [dbo].[pLotNum]  NULL,
    [LotNumTo]       [dbo].[pLotNum]  NULL,
    [SerNum]         [dbo].[pSerNum]  NOT NULL,
    [CostUnit]       [dbo].[pDecimal] NOT NULL,
    [CostXfer]       [dbo].[pDecimal] NOT NULL,
    [HistSeqNumFrom] INT              NULL,
    [HistSeqNumTo]   INT              NULL,
    [Cmnt]           NVARCHAR (35)    NULL,
    [CF]             XML              NULL,
    CONSTRAINT [PK_tblInHistXferSer] PRIMARY KEY CLUSTERED ([HeaderID] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistXferSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistXferSer';

