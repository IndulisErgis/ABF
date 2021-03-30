CREATE TABLE [dbo].[tblPcTrans] (
    [Id]              INT                  NOT NULL,
    [ProjectDetailId] INT                  NOT NULL,
    [ActivityId]      INT                  NOT NULL,
    [TransType]       TINYINT              CONSTRAINT [DF_tblPcTrans_TransType] DEFAULT ((0)) NOT NULL,
    [BatchId]         [dbo].[pBatchID]     NOT NULL,
    [TransDate]       DATETIME             NOT NULL,
    [FiscalYear]      SMALLINT             NOT NULL,
    [FiscalPeriod]    SMALLINT             NOT NULL,
    [ItemId]          [dbo].[pItemID]      NULL,
    [LocId]           [dbo].[pLocID]       NULL,
    [Description]     [dbo].[pDescription] NULL,
    [AddnlDesc]       NVARCHAR (MAX)       NULL,
    [QtyNeed]         [dbo].[pDec]         CONSTRAINT [DF_tblPcTrans_QtyNeed] DEFAULT ((1)) NOT NULL,
    [QtyFilled]       [dbo].[pDec]         CONSTRAINT [DF_tblPcTrans_QtyFilled] DEFAULT ((0)) NOT NULL,
    [Uom]             [dbo].[pUom]         NULL,
    [UnitCost]        [dbo].[pDec]         CONSTRAINT [DF_tblPcTrans_UnitCost] DEFAULT ((0)) NOT NULL,
    [HistSeqNum]      INT                  NULL,
    [QtySeqNum]       INT                  NULL,
    [QtySeqNum_Cmtd]  INT                  NULL,
    [LinkSeqNum]      INT                  NULL,
    [Markup]          [dbo].[pDec]         CONSTRAINT [DF_tblPcTrans_Markup] DEFAULT ((0)) NOT NULL,
    [GLAcct]          [dbo].[pGlAcct]      NOT NULL,
    [TaxClass]        TINYINT              NOT NULL,
    [CF]              XML                  NULL,
    [ts]              ROWVERSION           NULL,
    CONSTRAINT [PK_tblPcTrans] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlBatchId]
    ON [dbo].[tblPcTrans]([BatchId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTrans';

