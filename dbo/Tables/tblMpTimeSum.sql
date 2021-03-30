CREATE TABLE [dbo].[tblMpTimeSum] (
    [OrderNo]               [dbo].[pTransID] NULL,
    [ReleaseNo]             VARCHAR (3)      NULL,
    [ReqID]                 VARCHAR (4)      NULL,
    [TransId]               INT              NOT NULL,
    [LeadTime]              INT              DEFAULT ((0)) NOT NULL,
    [RequiredDate]          DATETIME         NULL,
    [OperationID]           VARCHAR (10)     NULL,
    [OperSupervisor]        VARCHAR (20)     NULL,
    [WorkCenterID]          VARCHAR (10)     NULL,
    [LaborSetupTypeId]      VARCHAR (10)     NULL,
    [LaborTypeID]           VARCHAR (10)     NULL,
    [LaborSetupEst]         INT              DEFAULT ((0)) NOT NULL,
    [LaborEst]              INT              DEFAULT ((0)) NOT NULL,
    [MachineGroupID]        VARCHAR (10)     NULL,
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
    [WorkCenterCostGroupID] VARCHAR (6)      NULL,
    [MachineCostGroupID]    VARCHAR (6)      NULL,
    [LaborCostGroupID]      VARCHAR (6)      NULL,
    [LaborSetupCostGroupID] VARCHAR (6)      NULL,
    [Status]                TINYINT          DEFAULT ((0)) NOT NULL,
    [WSeqNo]                INT              DEFAULT ((9999)) NOT NULL,
    [MSeqNo]                INT              DEFAULT ((9999)) NOT NULL,
    [LSeqNo]                INT              DEFAULT ((9999)) NOT NULL,
    [Notes]                 TEXT             NULL,
    [ts]                    ROWVERSION       NULL,
    [CF]                    XML              NULL,
    [ScheduleId]            VARCHAR (10)     NULL,
    [HourlyRateLbrSetup]    [dbo].[pDecimal] CONSTRAINT [DF_tblMpTimeSum_HourlyRateLbrSetup] DEFAULT ((0)) NOT NULL,
    [OperatorCount]         TINYINT          CONSTRAINT [DF_tblMpTimeSum_OperatorCount] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblMpTimeSum] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpTimeSum';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpTimeSum';

