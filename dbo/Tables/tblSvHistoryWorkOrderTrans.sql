CREATE TABLE [dbo].[tblSvHistoryWorkOrderTrans] (
    [ID]                    BIGINT               NOT NULL,
    [DispatchID]            BIGINT               NULL,
    [WorkOrderID]           BIGINT               NOT NULL,
    [TransType]             TINYINT              NOT NULL,
    [ResourceID]            NVARCHAR (24)        NULL,
    [LaborCode]             NVARCHAR (10)        NULL,
    [Description]           [dbo].[pDescription] NULL,
    [LocID]                 [dbo].[pLocID]       NULL,
    [EntryDate]             DATETIME             NOT NULL,
    [TransDate]             DATETIME             NOT NULL,
    [FiscalYear]            SMALLINT             NOT NULL,
    [FiscalPeriod]          SMALLINT             NOT NULL,
    [AdditionalDescription] NVARCHAR (MAX)       NULL,
    [QtyEstimated]          [dbo].[pDec]         NOT NULL,
    [QtyUsed]               [dbo].[pDec]         NOT NULL,
    [Unit]                  NVARCHAR (5)         NULL,
    [UnitCost]              [dbo].[pDec]         NOT NULL,
    [UnitPrice]             [dbo].[pDec]         NOT NULL,
    [CostExt]               [dbo].[pDec]         NOT NULL,
    [PriceExt]              [dbo].[pDec]         NOT NULL,
    [TaxClass]              TINYINT              NOT NULL,
    [GLAcctCredit]          [dbo].[pGlAcct]      NULL,
    [GLAcctDebit]           [dbo].[pGlAcct]      NULL,
    [GLAcctSales]           [dbo].[pGlAcct]      NULL,
    [HistSeqNum]            INT                  NULL,
    [QtySeqNum_Cmtd]        INT                  NULL,
    [QtySeqNum]             INT                  NULL,
    [LinkSeqNum]            INT                  NULL,
    [EntryNum]              INT                  NULL,
    [CF]                    XML                  NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderTrans';

