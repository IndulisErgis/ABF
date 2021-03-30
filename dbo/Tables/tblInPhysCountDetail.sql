CREATE TABLE [dbo].[tblInPhysCountDetail] (
    [DtlSeqNum]  INT             IDENTITY (1, 1) NOT NULL,
    [SeqNum]     INT             NOT NULL,
    [SerNum]     [dbo].[pSerNum] NULL,
    [ExtLocAId]  VARCHAR (10)    NULL,
    [ExtLocBId]  VARCHAR (10)    NULL,
    [QtyFrozen]  [dbo].[pDec]    CONSTRAINT [DF_tblInPhysCountDetail_QtyFrozen] DEFAULT ((0)) NULL,
    [QtyCounted] [dbo].[pDec]    CONSTRAINT [DF_tblInPhysCountDetail_QtyCounted] DEFAULT ((0)) NULL,
    [CountedUom] [dbo].[pUom]    NOT NULL,
    [CostFrozen] [dbo].[pDec]    CONSTRAINT [DF_tblInPhysCountDetail_CostFrozen] DEFAULT ((0)) NULL,
    [TagNum]     INT             NULL,
    [CF]         XML             NULL,
    [ts]         ROWVERSION      NULL,
    CONSTRAINT [PK_tblInPhysCountDetail] PRIMARY KEY CLUSTERED ([DtlSeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlExtLoc]
    ON [dbo].[tblInPhysCountDetail]([ExtLocAId] ASC, [ExtLocBId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlTagNum]
    ON [dbo].[tblInPhysCountDetail]([TagNum] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlSeqNum]
    ON [dbo].[tblInPhysCountDetail]([SeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInPhysCountDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInPhysCountDetail';

