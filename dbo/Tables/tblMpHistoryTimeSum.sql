CREATE TABLE [dbo].[tblMpHistoryTimeSum] (
    [PostRun]               [dbo].[pPostRun] NOT NULL,
    [TransId]               INT              NOT NULL,
    [OrderNo]               [dbo].[pTransID] NULL,
    [ReleaseNo]             VARCHAR (3)      NULL,
    [ReqID]                 VARCHAR (4)      NULL,
    [LeadTime]              INT              DEFAULT ((0)) NOT NULL,
    [RequiredDate]          DATETIME         NULL,
    [OperationId]           VARCHAR (10)     NULL,
    [OperSupervisor]        VARCHAR (20)     NULL,
    [WorkCenterId]          VARCHAR (10)     NULL,
    [LaborSetupTypeId]      VARCHAR (10)     NULL,
    [LaborTypeId]           VARCHAR (10)     NULL,
    [LaborSetupEst]         INT              DEFAULT ((0)) NOT NULL,
    [LaborEst]              INT              DEFAULT ((0)) NOT NULL,
    [MachineGroupId]        VARCHAR (10)     NULL,
    [LaborPctOvhd]          [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [FlatAmtOvhd]           [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PerPieceOvhd]          [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [MachPctOvhd]           [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [HourlyCostFactorMach]  [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PerPieceCostLbr]       [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [HourlyRateLbr]         [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [MachineSetupEst]       INT              DEFAULT ((0)) NOT NULL,
    [MachineRunEst]         INT              DEFAULT ((0)) NOT NULL,
    [QtyProducedEst]        [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [QtyScrappedEst]        [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [QueueTimeEst]          INT              DEFAULT ((0)) NOT NULL,
    [WaitTimeEst]           INT              DEFAULT ((0)) NOT NULL,
    [MoveTimeEst]           INT              DEFAULT ((0)) NOT NULL,
    [OverlapFactor]         [dbo].[pDec]     DEFAULT ((0)) NULL,
    [OverlapYn]             BIT              DEFAULT ((0)) NOT NULL,
    [WorkCenterCostGroupId] VARCHAR (6)      NULL,
    [MachineCostGroupId]    VARCHAR (6)      NULL,
    [LaborCostGroupId]      VARCHAR (6)      NULL,
    [LaborSetupCostGroupId] VARCHAR (6)      NULL,
    [Status]                TINYINT          DEFAULT ((0)) NOT NULL,
    [WSeqNo]                INT              DEFAULT ((9999)) NOT NULL,
    [MSeqNo]                INT              DEFAULT ((9999)) NOT NULL,
    [LSeqNo]                INT              DEFAULT ((9999)) NOT NULL,
    [Notes]                 TEXT             NULL,
    [ts]                    ROWVERSION       NULL,
    [CF]                    XML              NULL,
    [ScheduleId]            VARCHAR (10)     NULL,
    [HourlyRateLbrSetup]    [dbo].[pDecimal] CONSTRAINT [DF_tblMpHistoryTimeSum_HourlyRateLbrSetup] DEFAULT ((0)) NOT NULL,
    [OperatorCount]         TINYINT          CONSTRAINT [DF_tblMpHistoryTimeSum_OperatorCount] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblMpHistoryTimeSum] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryTimeSum';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryTimeSum';

