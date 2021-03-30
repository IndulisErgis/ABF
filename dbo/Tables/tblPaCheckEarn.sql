CREATE TABLE [dbo].[tblPaCheckEarn] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [CheckId]             INT             NOT NULL,
    [EarningCode]         [dbo].[pCode]   NULL,
    [LeaveCodeId]         [dbo].[pCode]   NULL,
    [StateTaxAuthorityId] INT             NULL,
    [SUIState]            NVARCHAR (2)    NULL,
    [LocalTaxAuthorityId] INT             NULL,
    [DepartmentId]        [dbo].[pDeptID] NULL,
    [LaborClass]          NVARCHAR (3)    NULL,
    [HoursWorked]         [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEarn_HoursWorked] DEFAULT ((0)) NOT NULL,
    [Pieces]              [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEarn_Pieces] DEFAULT ((0)) NOT NULL,
    [EarningCodeRate]     [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEarn_EarningCodeRate] DEFAULT ((0)) NOT NULL,
    [EarningAmount]       [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEarn_EarningAmount] DEFAULT ((0)) NOT NULL,
    [TransId]             INT             CONSTRAINT [DF_tblPaCheckEarn_TransId] DEFAULT ((0)) NOT NULL,
    [AdjEntryFlags]       BIT             CONSTRAINT [DF_tblPaCheckEarn_AdjEntryFlags] DEFAULT ((0)) NOT NULL,
    [DeptAllocId]         NVARCHAR (10)   NULL,
    [ProjectDetailId]     INT             NULL,
    [CustId]              [dbo].[pCustID] NULL,
    [ProjId]              NVARCHAR (10)   NULL,
    [PhaseId]             NVARCHAR (10)   NULL,
    [TaskId]              NVARCHAR (10)   NULL,
    [CF]                  XML             NULL,
    [ts]                  ROWVERSION      NULL,
    [TaxGroupId]          BIGINT          NULL,
    CONSTRAINT [PK_tblPaCheckEarn] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckEarn_CheckId]
    ON [dbo].[tblPaCheckEarn]([CheckId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckEarn';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckEarn';

