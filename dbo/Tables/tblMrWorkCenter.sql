CREATE TABLE [dbo].[tblMrWorkCenter] (
    [WorkCenterId]     VARCHAR (10)         NOT NULL,
    [Descr]            [dbo].[pDescription] NULL,
    [ShopCalId]        VARCHAR (10)         NULL,
    [GLAcct1]          [dbo].[pGlAcct]      NULL,
    [Super]            VARCHAR (30)         NULL,
    [BillRate]         [dbo].[pDec]         CONSTRAINT [DF__tblMrWork__BillR__23F74C3D] DEFAULT (0) NOT NULL,
    [BillMethod]       TINYINT              CONSTRAINT [DF__tblMrWork__BillM__24EB7076] DEFAULT (0) NOT NULL,
    [OverheadLaborPct] [dbo].[pDec]         CONSTRAINT [DF__tblMrWork__Overh__25DF94AF] DEFAULT (0) NOT NULL,
    [OverheadFlatAmt]  [dbo].[pDec]         CONSTRAINT [DF__tblMrWork__Overh__26D3B8E8] DEFAULT (0) NOT NULL,
    [OverheadPerPiece] [dbo].[pDec]         CONSTRAINT [DF__tblMrWork__Overh__27C7DD21] DEFAULT (0) NOT NULL,
    [OverheadMachPct]  [dbo].[pDec]         CONSTRAINT [DF__tblMrWork__Overh__28BC015A] DEFAULT (0) NOT NULL,
    [MGID]             VARCHAR (10)         NULL,
    [Notes]            TEXT                 NULL,
    [CostGroupID]      VARCHAR (6)          NULL,
    [WCUserDef01]      VARCHAR (50)         NULL,
    [WCUserDef02]      INT                  CONSTRAINT [DF__tblMrWork__UserD__29B02593] DEFAULT (0) NULL,
    [ts]               ROWVERSION           NULL,
    [CF]               XML                  NULL,
    [ScheduleId]       VARCHAR (10)         NULL,
    CONSTRAINT [PK__tblMrWorkCenter__5655817C] PRIMARY KEY CLUSTERED ([WorkCenterId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlWCCostGroupID]
    ON [dbo].[tblMrWorkCenter]([CostGroupID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrWorkCenter] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrWorkCenter] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrWorkCenter] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrWorkCenter] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrWorkCenter';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrWorkCenter';

