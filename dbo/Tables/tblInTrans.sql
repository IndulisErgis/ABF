CREATE TABLE [dbo].[tblInTrans] (
    [TransId]       INT              NOT NULL,
    [TransType]     TINYINT          NULL,
    [ItemId]        [dbo].[pItemID]  NULL,
    [LocId]         [dbo].[pLocID]   NULL,
    [TransDate]     DATETIME         CONSTRAINT [DF__tblInTran__Trans__22C3FC39] DEFAULT (getdate()) NULL,
    [Qty]           [dbo].[pDec]     CONSTRAINT [DF__tblInTrans__Qty__23B82072] DEFAULT (0) NULL,
    [Uom]           [dbo].[pUom]     NULL,
    [ConvFactor]    [dbo].[pDec]     CONSTRAINT [DF__tblInTran__ConvF__24AC44AB] DEFAULT (1) NULL,
    [CustLevelId]   VARCHAR (10)     NULL,
    [PriceId]       VARCHAR (10)     NULL,
    [SumYear]       SMALLINT         CONSTRAINT [DF__tblInTran__SumYe__25A068E4] DEFAULT (0) NULL,
    [SumPeriod]     SMALLINT         CONSTRAINT [DF__tblInTran__SumPe__26948D1D] DEFAULT (0) NULL,
    [GLPeriod]      SMALLINT         CONSTRAINT [DF__tblInTran__GLPer__2788B156] DEFAULT (0) NULL,
    [PriceUnit]     [dbo].[pDec]     CONSTRAINT [DF__tblInTran__Price__287CD58F] DEFAULT (0) NULL,
    [CostUnitTrans] [dbo].[pDec]     CONSTRAINT [DF__tblInTran__CostU__2970F9C8] DEFAULT (0) NULL,
    [CostUnitStd]   [dbo].[pDec]     CONSTRAINT [DF__tblInTran__CostU__2A651E01] DEFAULT (0) NULL,
    [CostUnitXfer]  [dbo].[pDec]     CONSTRAINT [DF__tblInTran__CostU__2B59423A] DEFAULT (0) NULL,
    [HistSeqNum]    INT              NULL,
    [GLAcctOffset]  [dbo].[pGlAcct]  NULL,
    [PromoId]       VARCHAR (10)     NULL,
    [Cmnt]          VARCHAR (35)     NULL,
    [QtySeqNum]     INT              CONSTRAINT [DF_tblInTrans_QtySeqNum] DEFAULT (0) NULL,
    [ts]            ROWVERSION       NULL,
    [BatchId]       [dbo].[pBatchID] DEFAULT ('######') NOT NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK__tblInTrans__35DCF99B] PRIMARY KEY CLUSTERED ([TransId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransType]
    ON [dbo].[tblInTrans]([TransType] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInTrans';

