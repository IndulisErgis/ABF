CREATE TABLE [dbo].[tblPcTransExt] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [TransId]        INT             NOT NULL,
    [LotNum]         [dbo].[pLotNum] NULL,
    [ExtLocA]        INT             NULL,
    [ExtLocB]        INT             NULL,
    [QtyNeed]        [dbo].[pDec]    CONSTRAINT [DF_tblPcTransExt_QtyNeed] DEFAULT ((0)) NOT NULL,
    [QtyFilled]      [dbo].[pDec]    CONSTRAINT [DF_tblPcTransExt_QtyFilled] DEFAULT ((0)) NOT NULL,
    [UnitCost]       [dbo].[pDec]    CONSTRAINT [DF_tblPcTransExt_UnitCost] DEFAULT ((0)) NOT NULL,
    [HistSeqNum]     INT             NULL,
    [QtySeqNum]      INT             NULL,
    [QtySeqNum_Cmtd] INT             NULL,
    [QtySeqNum_Ext]  INT             NULL,
    [Cmnt]           NVARCHAR (35)   NULL,
    [CF]             XML             NULL,
    [ts]             ROWVERSION      NULL,
    CONSTRAINT [PK_tblPcTransExt] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransId]
    ON [dbo].[tblPcTransExt]([TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTransExt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTransExt';

