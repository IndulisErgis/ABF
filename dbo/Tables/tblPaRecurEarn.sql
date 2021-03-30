CREATE TABLE [dbo].[tblPaRecurEarn] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [EmployeeId]          [dbo].[pEmpID]  NULL,
    [EarningCode]         [dbo].[pCode]   NULL,
    [LeaveCodeId]         [dbo].[pCode]   NULL,
    [DepartmentId]        [dbo].[pDeptID] NULL,
    [StateTaxAuthorityId] INT             NULL,
    [LocalTaxAuthorityId] INT             NULL,
    [LaborClass]          NVARCHAR (3)    NULL,
    [Rate]                [dbo].[pDec]    CONSTRAINT [DF_tblPaRecurEarn_Rate] DEFAULT ((0)) NOT NULL,
    [Pieces]              [dbo].[pDec]    CONSTRAINT [DF_tblPaRecurEarn_Pieces] DEFAULT ((0)) NOT NULL,
    [Hours]               [dbo].[pDec]    CONSTRAINT [DF_tblPaRecurEarn_Hours] DEFAULT ((0)) NOT NULL,
    [Amount]              [dbo].[pDec]    CONSTRAINT [DF_tblPaRecurEarn_Amount] DEFAULT ((0)) NOT NULL,
    [TransDate]           DATETIME        NULL,
    [SUIState]            NVARCHAR (2)    NULL,
    [SeqNo]               NVARCHAR (3)    NULL,
    [CustId]              [dbo].[pCustID] NULL,
    [ProjId]              NVARCHAR (10)   NULL,
    [PhaseId]             NVARCHAR (10)   NULL,
    [TaskId]              NVARCHAR (10)   NULL,
    [RunCode]             NVARCHAR (2)    NULL,
    [CutoffDate]          DATETIME        NULL,
    [CF]                  XML             NULL,
    [ts]                  ROWVERSION      NULL,
    [TaxGroupId]          BIGINT          NULL,
    CONSTRAINT [PK_tblPaRecurEarn] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaRecurEarn_RunCode]
    ON [dbo].[tblPaRecurEarn]([RunCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaRecurEarn_EmployeeId]
    ON [dbo].[tblPaRecurEarn]([EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaRecurEarn';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaRecurEarn';

