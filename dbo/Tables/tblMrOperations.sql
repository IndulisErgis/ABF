CREATE TABLE [dbo].[tblMrOperations] (
    [OperationId]      VARCHAR (10)         NOT NULL,
    [Descr]            [dbo].[pDescription] NULL,
    [MachineGroupID]   VARCHAR (10)         NULL,
    [WorkCenterID]     VARCHAR (10)         NULL,
    [LaborTypeID]      VARCHAR (10)         NULL,
    [SetupLaborTypeID] VARCHAR (10)         NULL,
    [QueueTime]        [dbo].[pDec]         CONSTRAINT [DF__tblMrOper__Queue__43A501C0] DEFAULT (0) NOT NULL,
    [QueueTimeIn]      SMALLINT             NOT NULL,
    [MachSetup]        [dbo].[pDec]         CONSTRAINT [DF__tblMrOper__MachS__458D4A32] DEFAULT (0) NOT NULL,
    [MachSetupIn]      SMALLINT             NOT NULL,
    [LaborSetup]       [dbo].[pDec]         CONSTRAINT [DF__tblMrOper__Labor__477592A4] DEFAULT (0) NOT NULL,
    [LaborSetupIn]     SMALLINT             NOT NULL,
    [MachRunTime]      [dbo].[pDec]         CONSTRAINT [DF__tblMrOper__MachR__495DDB16] DEFAULT (0) NOT NULL,
    [MachRunTimeIn]    SMALLINT             NOT NULL,
    [LaborRunTime]     [dbo].[pDec]         CONSTRAINT [DF__tblMrOper__Labor__4B462388] DEFAULT (0) NOT NULL,
    [LaborRunTimeIn]   SMALLINT             NOT NULL,
    [WaitTime]         [dbo].[pDec]         CONSTRAINT [DF__tblMrOper__WaitT__4D2E6BFA] DEFAULT (0) NOT NULL,
    [WaitTimeIn]       SMALLINT             NOT NULL,
    [MoveTime]         [dbo].[pDec]         CONSTRAINT [DF__tblMrOper__MoveT__4F16B46C] DEFAULT (0) NOT NULL,
    [MoveTimeIn]       SMALLINT             NOT NULL,
    [ReqEmployees]     TINYINT              CONSTRAINT [DF__tblMrOper__ReqEm__50FEFCDE] DEFAULT (0) NOT NULL,
    [MGID]             VARCHAR (10)         NULL,
    [Notes]            TEXT                 NULL,
    [DfltTo]           BIT                  CONSTRAINT [DF__tblMrOper__DfltT__55C3B1FB] DEFAULT (0) NOT NULL,
    [OperUserDef01]    VARCHAR (50)         NULL,
    [OperUserDef02]    INT                  CONSTRAINT [DF__tblMrOper__UserD__56B7D634] DEFAULT (0) NULL,
    [ts]               ROWVERSION           NULL,
    [CF]               XML                  NULL,
    [Type]             TINYINT              NOT NULL,
    [MaxQuantity]      [dbo].[pDec]         CONSTRAINT [DF_tblMrOperations_MaxQuantity] DEFAULT ((0)) NOT NULL,
    [YieldPct]         [dbo].[pDec]         CONSTRAINT [DF_tblMrOperations_YieldPct] DEFAULT ((100)) NOT NULL,
    CONSTRAINT [PK__tblMrOperations__6934171D] PRIMARY KEY CLUSTERED ([OperationId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqltblMrOperationsLaborTypeId]
    ON [dbo].[tblMrOperations]([LaborTypeID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlMGID]
    ON [dbo].[tblMrOperations]([MGID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrOperations] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrOperations] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrOperations] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrOperations] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrOperations';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrOperations';

