CREATE TABLE [dbo].[tblPaCheckHistEarn] (
    [PostRun]        [dbo].[pPostRun] NOT NULL,
    [SequenceNumber] INT              NULL,
    [InternalNumber] INT              NULL,
    [EarningCode]    VARCHAR (3)      NULL,
    [StateCode]      VARCHAR (2)      NULL,
    [SUIState]       VARCHAR (2)      NULL,
    [LocalCode]      VARCHAR (4)      NULL,
    [DepartmentId]   [dbo].[pDeptID]  NULL,
    [LaborClass]     VARCHAR (3)      NULL,
    [HoursWorked]    [dbo].[pDec]     NOT NULL,
    [HourlyRate]     [dbo].[pDec]     NOT NULL,
    [EarningsAmount] [dbo].[pDec]     NOT NULL,
    [Pieces]         [dbo].[pDec]     NOT NULL,
    [CustId]         [dbo].[pCustID]  NULL,
    [ProjId]         VARCHAR (10)     NULL,
    [PhaseId]        VARCHAR (10)     NULL,
    [TaskId]         VARCHAR (10)     NULL,
    [ts]             ROWVERSION       NULL,
    [CF]             XML              NULL,
    [Id]             INT              NOT NULL,
    [CheckId]        INT              NOT NULL,
    [GLAcctDept]     [dbo].[pGlAcct]  NULL,
    [LeaveCodeId]    [dbo].[pCode]    NULL,
    [DeptAllocId]    VARCHAR (10)     NULL,
    [TaxGroup]       [dbo].[pTaxLoc]  NULL,
    CONSTRAINT [PK_tblPaCheckHistEarn] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckHistEarn_PostRunCheckid]
    ON [dbo].[tblPaCheckHistEarn]([PostRun] ASC, [CheckId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlStateCode]
    ON [dbo].[tblPaCheckHistEarn]([StateCode] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlLocalCode]
    ON [dbo].[tblPaCheckHistEarn]([LocalCode] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlEarningCode]
    ON [dbo].[tblPaCheckHistEarn]([EarningCode] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlDepartmentId]
    ON [dbo].[tblPaCheckHistEarn]([DepartmentId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaCheckHistEarn] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaCheckHistEarn] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaCheckHistEarn] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaCheckHistEarn] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistEarn';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistEarn';

