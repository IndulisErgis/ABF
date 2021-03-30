CREATE TABLE [dbo].[tblMrLabor] (
    [LaborTypeId]    VARCHAR (10)         NOT NULL,
    [Descr]          [dbo].[pDescription] NULL,
    [HourlyRate]     [dbo].[pDec]         CONSTRAINT [DF__tblMrLabo__Hourl__327A75BE] DEFAULT (0) NOT NULL,
    [ShopCalId]      VARCHAR (10)         NULL,
    [BillRate]       [dbo].[pDec]         CONSTRAINT [DF__tblMrLabo__BillR__336E99F7] DEFAULT (0) NOT NULL,
    [BillMethod]     TINYINT              CONSTRAINT [DF__tblMrLabo__BillM__3462BE30] DEFAULT (0) NOT NULL,
    [GLAcct1]        [dbo].[pGlAcct]      NULL,
    [PerPieceCost]   [dbo].[pDec]         CONSTRAINT [DF__tblMrLabo__PerPi__3556E269] DEFAULT (0) NOT NULL,
    [Notes]          TEXT                 NULL,
    [MGID]           VARCHAR (10)         NULL,
    [CostGroupID]    VARCHAR (6)          NULL,
    [LaborUserDef01] VARCHAR (50)         NULL,
    [LaborUserDef02] INT                  CONSTRAINT [DF__tblMrLabo__UserD__364B06A2] DEFAULT (0) NULL,
    [ts]             ROWVERSION           NULL,
    [CF]             XML                  NULL,
    [ScheduleId]     VARCHAR (10)         NULL,
    CONSTRAINT [PK__tblMrLabor__5872D418] PRIMARY KEY CLUSTERED ([LaborTypeId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlLaborCostGroupID]
    ON [dbo].[tblMrLabor]([CostGroupID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrLabor] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrLabor] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrLabor] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrLabor] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrLabor';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrLabor';

