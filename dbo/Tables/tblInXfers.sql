CREATE TABLE [dbo].[tblInXfers] (
    [TransId]        INT                 NOT NULL,
    [ItemIdFrom]     [dbo].[pItemID]     NULL,
    [ItemIdTo]       [dbo].[pItemID]     NULL,
    [LocIdFrom]      [dbo].[pLocID]      NULL,
    [LocIdTo]        [dbo].[pLocID]      NULL,
    [XferDate]       DATETIME            CONSTRAINT [DF__tblInXfer__XferD__4330CBCB] DEFAULT (getdate()) NULL,
    [SumYear]        SMALLINT            CONSTRAINT [DF__tblInXfer__SumYe__4424F004] DEFAULT (0) NULL,
    [SumPeriod]      SMALLINT            CONSTRAINT [DF__tblInXfer__SumPe__4519143D] DEFAULT (0) NULL,
    [GLPeriod]       SMALLINT            CONSTRAINT [DF__tblInXfer__GLPer__460D3876] DEFAULT (0) NULL,
    [Qty]            [dbo].[pDec]        CONSTRAINT [DF__tblInXfers__Qty__47015CAF] DEFAULT (0) NULL,
    [HistSeqNumFrom] INT                 CONSTRAINT [DF__tblInXfer__HistS__47F580E8] DEFAULT (0) NULL,
    [HistSeqNumTo]   INT                 CONSTRAINT [DF__tblInXfer__HistS__48E9A521] DEFAULT (0) NULL,
    [Uom]            [dbo].[pUom]        NULL,
    [ConvFactor]     [dbo].[pDec]        CONSTRAINT [DF__tblInXfer__ConvF__49DDC95A] DEFAULT (1) NULL,
    [CostUnit]       [dbo].[pDec]        CONSTRAINT [DF__tblInXfer__CostU__4AD1ED93] DEFAULT (0) NULL,
    [CostUnitXfer]   [dbo].[pDec]        CONSTRAINT [DF__tblInXfer__CostU__4BC611CC] DEFAULT (0) NULL,
    [GLAcctCodeFrom] [dbo].[pGLAcctCode] NULL,
    [GLAcctCodeTo]   [dbo].[pGLAcctCode] NULL,
    [Cmnt]           VARCHAR (35)        NULL,
    [zzCostUnitStd]  [dbo].[pDec]        CONSTRAINT [DF__tblInXfer__zzCos__4CBA3605] DEFAULT (0) NULL,
    [BaseQtyBefore]  [dbo].[pDec]        CONSTRAINT [DF_tblInXfers_BaseQtyBefore] DEFAULT (0) NULL,
    [BaseQtyAfter]   [dbo].[pDec]        CONSTRAINT [DF_tblInXfers_BaseQtyAfter] DEFAULT (0) NULL,
    [QtySeqNumFrom]  INT                 CONSTRAINT [DF_tblInXfers_QtySeqNumFrom] DEFAULT (0) NULL,
    [QtySeqNumTo]    INT                 CONSTRAINT [DF_tblInXfers_QtySeqNumTo] DEFAULT (0) NULL,
    [ts]             ROWVERSION          NULL,
    [BatchId]        [dbo].[pBatchID]    DEFAULT ('######') NOT NULL,
    [CF]             XML                 NULL,
    CONSTRAINT [PK__tblInXfers__423CA792] PRIMARY KEY CLUSTERED ([TransId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInXfers';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInXfers';

