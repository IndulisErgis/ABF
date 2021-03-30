CREATE TABLE [dbo].[tblCfConfigFieldActionLbr] (
    [Id]                  INT                  IDENTITY (1, 1) NOT NULL,
    [ActionId]            BIGINT               NOT NULL,
    [RtgType]             TINYINT              NOT NULL,
    [Descr]               [dbo].[pDescription] NULL,
    [SubContractorId]     [dbo].[pVendorID]    NULL,
    [SubUnitCost]         [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_SubUnitCost] DEFAULT ((0)) NOT NULL,
    [OperationType]       TINYINT              NOT NULL,
    [WorkCenterId]        NVARCHAR (10)        NULL,
    [LaborTypeId]         NVARCHAR (10)        NULL,
    [SetupLaborTypeId]    NVARCHAR (10)        NULL,
    [MachineGroupId]      NVARCHAR (10)        NULL,
    [OverlapYn]           BIT                  CONSTRAINT [DF_tblCfConfigFieldActionLbr_OverlapYn] DEFAULT ((0)) NOT NULL,
    [Media]               NVARCHAR (10)        NULL,
    [QueueTime]           [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_QueueTime] DEFAULT ((0)) NOT NULL,
    [QueueTimeIn]         SMALLINT             CONSTRAINT [DF_tblCfConfigFieldActionLbr_QueueTimeIn] DEFAULT ((1)) NOT NULL,
    [MachSetup]           [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_MachSetup] DEFAULT ((0)) NOT NULL,
    [MachSetupIn]         SMALLINT             CONSTRAINT [DF_tblCfConfigFieldActionLbr_MachSetupIn] DEFAULT ((1)) NOT NULL,
    [MachSetupFormula]    NVARCHAR (300)       NULL,
    [LaborSetup]          [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_LaborSetup] DEFAULT ((0)) NOT NULL,
    [LaborSetupIn]        SMALLINT             CONSTRAINT [DF_tblCfConfigFieldActionLbr_LaborSetupIn] DEFAULT ((1)) NOT NULL,
    [LaborSetupFormula]   NVARCHAR (300)       NULL,
    [MachRunTime]         [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_MachRunTime] DEFAULT ((0)) NOT NULL,
    [MachRunTimeIn]       SMALLINT             CONSTRAINT [DF_tblCfConfigFieldActionLbr_MachRunTimeIn] DEFAULT ((1)) NOT NULL,
    [MachRunTimeFormula]  NVARCHAR (300)       NULL,
    [LaborRunTime]        [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_LaborRunTime] DEFAULT ((0)) NOT NULL,
    [LaborRunTimeIn]      SMALLINT             CONSTRAINT [DF_tblCfConfigFieldActionLbr_LaborRunTimeIn] DEFAULT ((1)) NOT NULL,
    [LaborRunTimeFormula] NVARCHAR (300)       NULL,
    [WaitTime]            [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_WaitTime] DEFAULT ((0)) NOT NULL,
    [WaitTimeIn]          SMALLINT             CONSTRAINT [DF_tblCfConfigFieldActionLbr_WaitTimeIn] DEFAULT ((1)) NOT NULL,
    [MoveTime]            [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_MoveTime] DEFAULT ((0)) NOT NULL,
    [MoveTimeIn]          SMALLINT             CONSTRAINT [DF_tblCfConfigFieldActionLbr_MoveTimeIn] DEFAULT ((1)) NOT NULL,
    [FieldPrice]          [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_FieldPrice] DEFAULT ((0)) NOT NULL,
    [PriceFormula]        NVARCHAR (300)       NULL,
    [CostGroupId]         NVARCHAR (6)         NULL,
    [MaxQuantity]         [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_MaxQuantity] DEFAULT ((0)) NOT NULL,
    [YieldPct]            [dbo].[pDecimal]     CONSTRAINT [DF_tblCfConfigFieldActionLbr_YieldPct] DEFAULT ((0)) NOT NULL,
    [Notes]               NVARCHAR (MAX)       NULL,
    [LeadTime]            INT                  NULL,
    [CF]                  XML                  NULL,
    [ts]                  ROWVERSION           NULL,
    CONSTRAINT [PK_tblCfConfigFieldActionLbr] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCfConfigFieldActionLbr_ActionId]
    ON [dbo].[tblCfConfigFieldActionLbr]([ActionId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldActionLbr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigFieldActionLbr';

