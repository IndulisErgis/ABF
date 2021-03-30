CREATE TABLE [dbo].[tblPcTransSer] (
    [Id]         INT             IDENTITY (1, 1) NOT NULL,
    [TransId]    INT             NOT NULL,
    [SerNum]     [dbo].[pSerNum] NOT NULL,
    [LotNum]     [dbo].[pLotNum] NULL,
    [ExtLocA]    INT             NULL,
    [ExtLocB]    INT             NULL,
    [UnitCost]   [dbo].[pDec]    NOT NULL,
    [Cmnt]       NVARCHAR (35)   NULL,
    [HistSeqNum] INT             NULL,
    [CF]         XML             NULL,
    [ts]         ROWVERSION      NULL,
    CONSTRAINT [PK_tblPcTransSer] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransId]
    ON [dbo].[tblPcTransSer]([TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTransSer';

