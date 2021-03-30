CREATE TABLE [dbo].[tblInHistXfers] (
    [ID]             BIGINT           IDENTITY (1, 1) NOT NULL,
    [PostRun]        [dbo].[pPostRun] NOT NULL,
    [TransID]        INT              NOT NULL,
    [BatchID]        [dbo].[pBatchID] NOT NULL,
    [ItemID]         [dbo].[pItemID]  NOT NULL,
    [LocIDFrom]      [dbo].[pLocID]   NOT NULL,
    [LocIDTo]        [dbo].[pLocID]   NOT NULL,
    [XferDate]       DATETIME         NOT NULL,
    [FiscalYear]     SMALLINT         NOT NULL,
    [FiscalPeriod]   SMALLINT         NOT NULL,
    [Qty]            [dbo].[pDecimal] NOT NULL,
    [QtyBase]        [dbo].[pDecimal] NOT NULL,
    [Uom]            [dbo].[pUom]     NOT NULL,
    [UomBase]        [dbo].[pUom]     NOT NULL,
    [CostUnit]       [dbo].[pDecimal] NOT NULL,
    [CostExt]        [dbo].[pDecimal] NOT NULL,
    [CostXfer]       [dbo].[pDecimal] NOT NULL,
    [GLAcctInvFrom]  [dbo].[pGlAcct]  NOT NULL,
    [GLAcctInvTo]    [dbo].[pGlAcct]  NOT NULL,
    [GLAcctXferCost] [dbo].[pGlAcct]  NULL,
    [HistSeqNumFrom] INT              NULL,
    [HistSeqNumTo]   INT              NULL,
    [QtySeqNumFrom]  INT              NULL,
    [QtySeqNumTo]    INT              NULL,
    [Cmnt]           NVARCHAR (35)    NULL,
    [CF]             XML              NULL,
    CONSTRAINT [PK_tblInHistXfers] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblInHistXfers_PostRunTransID]
    ON [dbo].[tblInHistXfers]([PostRun] ASC, [TransID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistXfers';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistXfers';

