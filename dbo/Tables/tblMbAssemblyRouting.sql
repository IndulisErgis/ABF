CREATE TABLE [dbo].[tblMbAssemblyRouting] (
    [AssemblyId]       [dbo].[pItemID]      NULL,
    [RevisionNo]       VARCHAR (3)          NULL,
    [RtgType]          TINYINT              CONSTRAINT [DF__tblMbAsse__RtgTy__39C691CB] DEFAULT (1) NOT NULL,
    [RtgStep]          VARCHAR (3)          CONSTRAINT [DF__tblMbAsse__RtgSt__38D26D92] DEFAULT ('010') NULL,
    [Descr]            [dbo].[pDescription] NULL,
    [SubContractorID]  [dbo].[pVendorID]    NULL,
    [SubUnitCost]      [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__SubUn__3ABAB604] DEFAULT (0) NOT NULL,
    [OperationId]      VARCHAR (10)         NULL,
    [WorkCenterId]     VARCHAR (10)         NULL,
    [LaborTypeId]      VARCHAR (10)         NULL,
    [SetupLaborTypeId] VARCHAR (10)         NULL,
    [MachineGroupId]   VARCHAR (10)         NULL,
    [OverlapFactor]    [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__Overl__3BAEDA3D] DEFAULT (0) NULL,
    [OverlapYn]        BIT                  CONSTRAINT [DF__tblMbAsse__Overl__3CA2FE76] DEFAULT (0) NOT NULL,
    [Media]            VARCHAR (10)         NULL,
    [QueueTime]        [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__Queue__3D9722AF] DEFAULT (0) NOT NULL,
    [QueueTimeIn]      SMALLINT             CONSTRAINT [DF__tblMbAsse__Queue__3E8B46E8] DEFAULT (1) NOT NULL,
    [MachSetup]        [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__MachS__3F7F6B21] DEFAULT (0) NOT NULL,
    [MachSetupIn]      SMALLINT             CONSTRAINT [DF__tblMbAsse__MachS__40738F5A] DEFAULT (1) NOT NULL,
    [LaborSetup]       [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__Labor__4167B393] DEFAULT (0) NOT NULL,
    [LaborSetupIn]     SMALLINT             CONSTRAINT [DF__tblMbAsse__Labor__425BD7CC] DEFAULT (1) NOT NULL,
    [MachRunTime]      [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__MachR__434FFC05] DEFAULT (0) NOT NULL,
    [MachRunTimeIn]    SMALLINT             CONSTRAINT [DF__tblMbAsse__MachR__4444203E] DEFAULT (1) NOT NULL,
    [LaborRunTime]     [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__Labor__45384477] DEFAULT (0) NOT NULL,
    [LaborRunTimeIn]   SMALLINT             CONSTRAINT [DF__tblMbAsse__Labor__462C68B0] DEFAULT (1) NOT NULL,
    [WaitTime]         [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__WaitT__47208CE9] DEFAULT (0) NOT NULL,
    [WaitTimeIn]       SMALLINT             CONSTRAINT [DF__tblMbAsse__WaitT__4814B122] DEFAULT (1) NOT NULL,
    [MoveTime]         [dbo].[pDec]         CONSTRAINT [DF__tblMbAsse__MoveT__4908D55B] DEFAULT (0) NOT NULL,
    [MoveTimeIn]       SMALLINT             CONSTRAINT [DF__tblMbAsse__MoveT__49FCF994] DEFAULT (1) NOT NULL,
    [CostGroupId]      VARCHAR (6)          NULL,
    [Notes]            TEXT                 NULL,
    [ts]               ROWVERSION           NULL,
    [CF]               XML                  NULL,
    [OperationType]    TINYINT              NOT NULL,
    [MaxQuantity]      [dbo].[pDec]         CONSTRAINT [DF_tblMbAssemblyRouting_MaxQuantity] DEFAULT ((0)) NOT NULL,
    [YieldPct]         [dbo].[pDec]         CONSTRAINT [DF_tblMbAssemblyRouting_YieldPct] DEFAULT ((100)) NOT NULL,
    [HeaderId]         INT                  NOT NULL,
    [Id]               INT                  NOT NULL,
    [Step]             INT                  NOT NULL,
    [OperatorCount]    TINYINT              CONSTRAINT [DF_tblMbAssemblyRouting_OperatorCount] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblMbAssemblyRouting] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMbAssemblyRouting_HeaderIdRtgTypeStep]
    ON [dbo].[tblMbAssemblyRouting]([HeaderId] ASC, [RtgType] ASC, [Step] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMbAssemblyRouting] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMbAssemblyRouting] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMbAssemblyRouting] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMbAssemblyRouting] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbAssemblyRouting';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbAssemblyRouting';

