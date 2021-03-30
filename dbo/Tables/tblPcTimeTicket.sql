CREATE TABLE [dbo].[tblPcTimeTicket] (
    [Id]              INT                  IDENTITY (1, 1) NOT NULL,
    [BatchId]         [dbo].[pBatchID]     NOT NULL,
    [EmployeeId]      [dbo].[pEmpID]       NOT NULL,
    [TransDate]       DATETIME             NOT NULL,
    [FiscalYear]      SMALLINT             NOT NULL,
    [FiscalPeriod]    SMALLINT             NOT NULL,
    [ProjectDetailId] INT                  NOT NULL,
    [ActivityId]      INT                  NOT NULL,
    [Qty]             [dbo].[pDec]         CONSTRAINT [DF_tblPcTimeTicket_Qty] DEFAULT ((1)) NOT NULL,
    [UnitCost]        [dbo].[pDec]         CONSTRAINT [DF_tblPcTimeTicket_UnitCost] DEFAULT ((0)) NOT NULL,
    [Description]     [dbo].[pDescription] NULL,
    [AddnlDesc]       NVARCHAR (MAX)       NULL,
    [RateId]          NVARCHAR (10)        NOT NULL,
    [BillingRate]     [dbo].[pDec]         CONSTRAINT [DF_tblPcTimeTicket_BillingRate] DEFAULT ((0)) NOT NULL,
    [Pieces]          [dbo].[pDec]         CONSTRAINT [DF_tblPcTimeTicket_Pieces] DEFAULT ((0)) NOT NULL,
    [StateCode]       NVARCHAR (2)         NULL,
    [LocalCode]       NVARCHAR (4)         NULL,
    [DepartmentId]    NVARCHAR (10)        NULL,
    [LaborClass]      NVARCHAR (25)        NULL,
    [EarnCode]        NVARCHAR (3)         NULL,
    [SUIState]        NVARCHAR (2)         NULL,
    [SeqNo]           NVARCHAR (8)         NULL,
    [CF]              XML                  NULL,
    [ts]              ROWVERSION           NULL,
    CONSTRAINT [PK_tblPcTimeTicket] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlBatchId]
    ON [dbo].[tblPcTimeTicket]([BatchId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTimeTicket';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcTimeTicket';

