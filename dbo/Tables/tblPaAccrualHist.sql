CREATE TABLE [dbo].[tblPaAccrualHist] (
    [Id]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [PostRun]       [dbo].[pPostRun] NOT NULL,
    [TransId]       INT              NULL,
    [EmployeeId]    [dbo].[pEmpID]   NULL,
    [DepartmentId]  [dbo].[pDeptID]  NULL,
    [EarningCode]   [dbo].[pCode]    NULL,
    [EntryDate]     DATETIME         NOT NULL,
    [TransDate]     DATETIME         NOT NULL,
    [PaYear]        SMALLINT         NOT NULL,
    [PaMonth]       TINYINT          NOT NULL,
    [FiscalYear]    SMALLINT         NOT NULL,
    [FiscalPeriod]  SMALLINT         NOT NULL,
    [GLAcctAccrual] [dbo].[pGlAcct]  NULL,
    [GLAcctExpense] [dbo].[pGlAcct]  NULL,
    [Amount]        [dbo].[pDecimal] NOT NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblPaAccrualHist] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaAccrualHist_PaYearDepartmentId]
    ON [dbo].[tblPaAccrualHist]([PaYear] ASC, [DepartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaAccrualHist_PaYearEmployeeId]
    ON [dbo].[tblPaAccrualHist]([PaYear] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaAccrualHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaAccrualHist';

