CREATE TABLE [dbo].[tblPaTransEarn] (
    [Id]                  INT              IDENTITY (1, 1) NOT NULL,
    [PaYear]              SMALLINT         NOT NULL,
    [EmployeeId]          [dbo].[pEmpID]   NULL,
    [EarningCode]         [dbo].[pCode]    NULL,
    [LeaveCodeId]         [dbo].[pCode]    NULL,
    [DepartmentId]        [dbo].[pDeptID]  NULL,
    [StateTaxAuthorityId] INT              NULL,
    [LocalTaxAuthorityId] INT              NULL,
    [LaborClass]          NVARCHAR (3)     NULL,
    [Rate]                [dbo].[pDec]     CONSTRAINT [DF_tblPaTransEarn_Rate] DEFAULT ((0)) NOT NULL,
    [Pieces]              [dbo].[pDec]     CONSTRAINT [DF_tblPaTransEarn_Pieces] DEFAULT ((0)) NOT NULL,
    [Hours]               [dbo].[pDec]     CONSTRAINT [DF_tblPaTransEarn_Hours] DEFAULT ((0)) NOT NULL,
    [Amount]              [dbo].[pDec]     CONSTRAINT [DF_tblPaTransEarn_Amount] DEFAULT ((0)) NOT NULL,
    [TransDate]           DATETIME         NOT NULL,
    [SUIState]            NVARCHAR (2)     NULL,
    [SeqNo]               NVARCHAR (3)     NULL,
    [DeptAllocId]         NVARCHAR (10)    NULL,
    [ProjectDetailId]     INT              NULL,
    [CustId]              [dbo].[pCustID]  NULL,
    [ProjId]              NVARCHAR (10)    NULL,
    [PhaseId]             NVARCHAR (10)    NULL,
    [TaskId]              NVARCHAR (10)    NULL,
    [PostedYn]            BIT              CONSTRAINT [DF_tblPaTransEarn_PostedYn] DEFAULT ((0)) NOT NULL,
    [PostRun]             [dbo].[pPostRun] NULL,
    [CF]                  XML              NULL,
    [ts]                  ROWVERSION       NULL,
    [TaxGroupId]          BIGINT           NULL,
    CONSTRAINT [PK_tblPaTransEarn] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransEarn_PaYearEmployeeId]
    ON [dbo].[tblPaTransEarn]([PaYear] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransEarn';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransEarn';

