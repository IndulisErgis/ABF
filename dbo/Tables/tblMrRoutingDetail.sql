CREATE TABLE [dbo].[tblMrRoutingDetail] (
    [RoutingId]        VARCHAR (10) NOT NULL,
    [SeqNo]            VARCHAR (3)  NULL,
    [Descr]            VARCHAR (30) NULL,
    [OperationID]      VARCHAR (10) NULL,
    [WorkCenterID]     VARCHAR (10) NULL,
    [LaborTypeID]      VARCHAR (10) NULL,
    [SetupLaborTypeID] VARCHAR (10) NULL,
    [OverlapFactor]    [dbo].[pDec] CONSTRAINT [DF__tblMrRout__Overl__5B7C8B51] DEFAULT (0) NULL,
    [OverlapYn]        BIT          CONSTRAINT [DF__tblMrRout__Overl__5C70AF8A] DEFAULT (0) NOT NULL,
    [Notes]            TEXT         NULL,
    [MGID]             VARCHAR (10) NULL,
    [QueueTime]        [dbo].[pDec] CONSTRAINT [DF__tblMrRout__Queue__5D64D3C3] DEFAULT (0) NULL,
    [QueueTimeIn]      SMALLINT     CONSTRAINT [DF__tblMrRout__Queue__5E58F7FC] DEFAULT (1) NULL,
    [MachSetup]        [dbo].[pDec] CONSTRAINT [DF__tblMrRout__MachS__5F4D1C35] DEFAULT (0) NULL,
    [MachSetupIn]      SMALLINT     CONSTRAINT [DF__tblMrRout__MachS__6041406E] DEFAULT (1) NULL,
    [LaborSetup]       [dbo].[pDec] CONSTRAINT [DF__tblMrRout__Labor__613564A7] DEFAULT (0) NULL,
    [LaborSetupIn]     SMALLINT     CONSTRAINT [DF__tblMrRout__Labor__622988E0] DEFAULT (1) NULL,
    [MachRunTime]      [dbo].[pDec] CONSTRAINT [DF__tblMrRout__MachR__631DAD19] DEFAULT (0) NULL,
    [MachRunTimeIn]    SMALLINT     CONSTRAINT [DF__tblMrRout__MachR__6411D152] DEFAULT (1) NULL,
    [LaborRunTime]     [dbo].[pDec] CONSTRAINT [DF__tblMrRout__Labor__6505F58B] DEFAULT (0) NULL,
    [LaborRunTimeIn]   SMALLINT     CONSTRAINT [DF__tblMrRout__Labor__65FA19C4] DEFAULT (1) NULL,
    [WaitTime]         [dbo].[pDec] CONSTRAINT [DF__tblMrRout__WaitT__66EE3DFD] DEFAULT (0) NULL,
    [WaitTimeIn]       SMALLINT     CONSTRAINT [DF__tblMrRout__WaitT__67E26236] DEFAULT (1) NULL,
    [MoveTime]         [dbo].[pDec] CONSTRAINT [DF__tblMrRout__MoveT__68D6866F] DEFAULT (0) NULL,
    [MoveTimeIn]       SMALLINT     CONSTRAINT [DF__tblMrRout__MoveT__69CAAAA8] DEFAULT (1) NULL,
    [ReqEmployees]     SMALLINT     CONSTRAINT [DF__tblMrRout__ReqEm__6ABECEE1] DEFAULT (0) NULL,
    [MachineRate]      [dbo].[pDec] CONSTRAINT [DF__tblMrRout__Machi__6BB2F31A] DEFAULT (0) NULL,
    [LaborRate]        [dbo].[pDec] CONSTRAINT [DF__tblMrRout__Labor__6CA71753] DEFAULT (0) NULL,
    [BillRate]         [dbo].[pDec] CONSTRAINT [DF__tblMrRout__BillR__6D9B3B8C] DEFAULT (0) NULL,
    [BillMethod]       TINYINT      CONSTRAINT [DF__tblMrRout__BillM__6E8F5FC5] DEFAULT (0) NULL,
    [RtgUserDef01]     VARCHAR (50) NULL,
    [RtgUserDef02]     INT          CONSTRAINT [DF__tblMrRout__UserD__6F8383FE] DEFAULT (0) NULL,
    [ts]               ROWVERSION   NULL,
    [MachineGroupID]   VARCHAR (10) NULL,
    [CF]               XML          NULL,
    [Id]               INT          NOT NULL,
    [Step]             INT          NOT NULL,
    CONSTRAINT [PK_tblMrRoutingDetail] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMrRoutingDetail_RoutingIdStep]
    ON [dbo].[tblMrRoutingDetail]([RoutingId] ASC, [Step] ASC);


GO
CREATE NONCLUSTERED INDEX [sqltblMrRoutingDetailWorkCenterId]
    ON [dbo].[tblMrRoutingDetail]([WorkCenterID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqltblMrRoutingDetailOperationId]
    ON [dbo].[tblMrRoutingDetail]([OperationID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqltblMrRoutingDetailLaborTypeId]
    ON [dbo].[tblMrRoutingDetail]([LaborTypeID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrRoutingDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrRoutingDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrRoutingDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrRoutingDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrRoutingDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrRoutingDetail';

