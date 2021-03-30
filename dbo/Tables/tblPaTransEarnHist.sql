CREATE TABLE [dbo].[tblPaTransEarnHist] (
    [PostRun]      [dbo].[pPostRun]  NOT NULL,
    [TransID]      INT               NULL,
    [EmployeeId]   [dbo].[pEmpID]    NULL,
    [EarningCode]  VARCHAR (3)       NULL,
    [DepartmentId] [dbo].[pDeptID]   NULL,
    [StateCode]    VARCHAR (2)       NULL,
    [LocalCode]    VARCHAR (4)       NULL,
    [LaborClass]   VARCHAR (3)       NULL,
    [Rate]         [dbo].[pDec]      NOT NULL,
    [Pieces]       [dbo].[pDec]      NOT NULL,
    [Hours]        [dbo].[pDec]      NOT NULL,
    [Amount]       [dbo].[pDec]      NOT NULL,
    [TransDate]    DATETIME          NULL,
    [SUIState]     VARCHAR (2)       NULL,
    [SeqNo]        VARCHAR (3)       NULL,
    [CustId]       [dbo].[pCustID]   NULL,
    [ProjId]       VARCHAR (10)      NULL,
    [PhaseId]      VARCHAR (10)      NULL,
    [TaskId]       VARCHAR (10)      NULL,
    [PaMonth]      TINYINT           NOT NULL,
    [CheckNumber]  [dbo].[pCheckNum] NULL,
    [Voided]       BIT               NOT NULL,
    [ts]           ROWVERSION        NULL,
    [DeptAllocId]  VARCHAR (10)      NULL,
    [CF]           XML               NULL,
    [Id]           INT               NOT NULL,
    [PaYear]       SMALLINT          NOT NULL,
    [LeaveCodeId]  [dbo].[pCode]     NULL,
    [CheckId]      INT               NULL,
    [TaxGroup]     [dbo].[pTaxLoc]   NULL,
    CONSTRAINT [PK_tblPaTransEarnHist] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransEarnHist_CheckId]
    ON [dbo].[tblPaTransEarnHist]([CheckId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransEarnHist_PaYearPaMonthEmployeeId]
    ON [dbo].[tblPaTransEarnHist]([PaYear] ASC, [PaMonth] ASC, [EmployeeId] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaTransEarnHist] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaTransEarnHist] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaTransEarnHist] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaTransEarnHist] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransEarnHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransEarnHist';

