CREATE TABLE [dbo].[tblPsTransDetail] (
    [ID]         BIGINT               NOT NULL,
    [HeaderID]   BIGINT               NOT NULL,
    [ParentID]   BIGINT               NULL,
    [EntryNum]   INT                  NOT NULL,
    [LineSeq]    INT                  NOT NULL,
    [LineType]   SMALLINT             NOT NULL,
    [ItemID]     [dbo].[pItemID]      NULL,
    [LocID]      [dbo].[pLocID]       NULL,
    [LotNum]     [dbo].[pLotNum]      NULL,
    [SerNum]     [dbo].[pSerNum]      NULL,
    [Descr]      [dbo].[pDescription] NULL,
    [TaxClass]   TINYINT              NOT NULL,
    [Qty]        [dbo].[pDecimal]     NOT NULL,
    [Unit]       [dbo].[pUom]         NULL,
    [ExtPrice]   [dbo].[pDecimal]     NOT NULL,
    [TaxAmount]  [dbo].[pDecimal]     NOT NULL,
    [PromoID]    NVARCHAR (10)        NULL,
    [SalesRepID] [dbo].[pSalesRep]    NULL,
    [Notes]      NVARCHAR (MAX)       NULL,
    [CF]         XML                  NULL,
    [ts]         ROWVERSION           NULL,
    [SynchID]    BIGINT               NULL,
    [ResCode]    NVARCHAR (10)        NULL,
    CONSTRAINT [PK_tblPsTransDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsTransDetail_SynchID]
    ON [dbo].[tblPsTransDetail]([SynchID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsTransDetail_ParentID]
    ON [dbo].[tblPsTransDetail]([ParentID] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsTransDetail_HeaderIDEntryNum]
    ON [dbo].[tblPsTransDetail]([HeaderID] ASC, [EntryNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransDetail';

