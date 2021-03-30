﻿CREATE TABLE [dbo].[tblMpTimeDtl] (
    [TransId]         INT              NOT NULL,
    [SeqNo]           INT              IDENTITY (1, 1) NOT NULL,
    [TransDate]       DATETIME         NULL,
    [MachineSetup]    [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [MachineSetupIn]  SMALLINT         DEFAULT ((1)) NOT NULL,
    [MachineRun]      [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [MachineRunIn]    SMALLINT         DEFAULT ((1)) NOT NULL,
    [LaborSetup]      [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [LaborSetupIn]    SMALLINT         DEFAULT ((1)) NOT NULL,
    [Labor]           [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [LaborIn]         SMALLINT         DEFAULT ((1)) NOT NULL,
    [EmployeeID]      [dbo].[pEmpID]   NULL,
    [QtyProduced]     [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [QtyScrapped]     [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [VarianceCode]    VARCHAR (10)     NULL,
    [BeginTime]       DATETIME         NULL,
    [EndTime]         DATETIME         NULL,
    [Hours]           INT              NULL,
    [Mins]            INT              NULL,
    [PostedPayrollYn] BIT              DEFAULT ((0)) NOT NULL,
    [GlPeriod]        SMALLINT         DEFAULT ((0)) NOT NULL,
    [FiscalYear]      SMALLINT         DEFAULT ((0)) NOT NULL,
    [SumHistPeriod]   SMALLINT         DEFAULT ((1)) NULL,
    [Notes]           TEXT             NULL,
    [tmpOrderNo]      [dbo].[pTransID] NULL,
    [tmpReleaseNo]    VARCHAR (3)      NULL,
    [tmpReqID]        VARCHAR (4)      NULL,
    [ts]              ROWVERSION       NULL,
    [CF]              XML              NULL,
    [EmployeePayRate] [dbo].[pDec]     NOT NULL,
    CONSTRAINT [PK_tblMpTimeDtl] PRIMARY KEY CLUSTERED ([SeqNo] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMpTimeDtl_TransId]
    ON [dbo].[tblMpTimeDtl]([TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpTimeDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpTimeDtl';

