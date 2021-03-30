CREATE TABLE [dbo].[tblInHistTrans] (
    [ID]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [PostRun]      [dbo].[pPostRun] NOT NULL,
    [TransID]      INT              NOT NULL,
    [TransType]    TINYINT          NOT NULL,
    [BatchID]      [dbo].[pBatchID] NOT NULL,
    [ItemID]       [dbo].[pItemID]  NOT NULL,
    [LocID]        [dbo].[pLocID]   NOT NULL,
    [TransDate]    DATETIME         NOT NULL,
    [Qty]          [dbo].[pDecimal] NOT NULL,
    [QtyBase]      [dbo].[pDecimal] NOT NULL,
    [Uom]          [dbo].[pUom]     NOT NULL,
    [UomBase]      [dbo].[pUom]     NOT NULL,
    [FiscalYear]   SMALLINT         NOT NULL,
    [FiscalPeriod] SMALLINT         NOT NULL,
    [PriceUnit]    [dbo].[pDecimal] NOT NULL,
    [CostUnit]     [dbo].[pDecimal] NOT NULL,
    [PriceExt]     [dbo].[pDecimal] NOT NULL,
    [CostExt]      [dbo].[pDecimal] NOT NULL,
    [GLAcct]       [dbo].[pGlAcct]  NULL,
    [GLAcctOffset] [dbo].[pGlAcct]  NULL,
    [GLAcctSales]  [dbo].[pGlAcct]  NULL,
    [GLAcctCogs]   [dbo].[pGlAcct]  NULL,
    [HistSeqNum]   INT              NULL,
    [QtySeqNum]    INT              NULL,
    [Cmnt]         NVARCHAR (35)    NULL,
    [CF]           XML              NULL,
    CONSTRAINT [PK_tblInHistTrans] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblInHistTrans_PostRunTransID]
    ON [dbo].[tblInHistTrans]([PostRun] ASC, [TransID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistTrans';

