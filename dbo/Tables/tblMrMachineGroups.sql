CREATE TABLE [dbo].[tblMrMachineGroups] (
    [MachineGroupId] VARCHAR (10)         NOT NULL,
    [Descr]          [dbo].[pDescription] NULL,
    [MaintCycle]     SMALLINT             CONSTRAINT [DF__tblMrMach__Maint__3B0FBBBF] DEFAULT (0) NOT NULL,
    [MaintDate]      DATETIME             NULL,
    [QtyAvail]       SMALLINT             CONSTRAINT [DF__tblMrMach__QtyAv__3C03DFF8] DEFAULT (0) NOT NULL,
    [HrlyCostFactor] [dbo].[pDec]         CONSTRAINT [DF__tblMrMach__HrlyC__3CF80431] DEFAULT (0) NOT NULL,
    [SetupTime]      [dbo].[pDec]         CONSTRAINT [DF__tblMrMach__Setup__3DEC286A] DEFAULT (0) NOT NULL,
    [ShopCalId]      VARCHAR (10)         NULL,
    [Notes]          TEXT                 NULL,
    [GLAcct1]        [dbo].[pGlAcct]      NULL,
    [MGID]           VARCHAR (10)         NULL,
    [CostGroupID]    VARCHAR (6)          NULL,
    [MachUserDef01]  VARCHAR (50)         NULL,
    [MachUserDef02]  INT                  CONSTRAINT [DF__tblMrMach__UserD__3EE04CA3] DEFAULT (0) NULL,
    [ts]             ROWVERSION           NULL,
    [PurchaseDate]   DATETIME             NULL,
    [CF]             XML                  NULL,
    [ScheduleId]     VARCHAR (10)         NULL,
    CONSTRAINT [PK__tblMrMachineGrou__674BCEAB] PRIMARY KEY CLUSTERED ([MachineGroupId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlMachCostGroupID]
    ON [dbo].[tblMrMachineGroups]([CostGroupID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrMachineGroups] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrMachineGroups] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrMachineGroups] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrMachineGroups] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrMachineGroups';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrMachineGroups';

