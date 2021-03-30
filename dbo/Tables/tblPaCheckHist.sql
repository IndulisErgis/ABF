CREATE TABLE [dbo].[tblPaCheckHist] (
    [PostRun]             [dbo].[pPostRun]  NOT NULL,
    [SequenceNumber]      INT               NULL,
    [EmployeeId]          [dbo].[pEmpID]    NULL,
    [GroupCode]           TINYINT           NOT NULL,
    [EmployeeName]        VARCHAR (36)      NULL,
    [DepartmentId]        [dbo].[pDeptID]   NULL,
    [SocialSecurityNo]    NVARCHAR (255)    NULL,
    [CheckNumber]         [dbo].[pCheckNum] NULL,
    [CheckDate]           DATETIME          NULL,
    [GrossPay]            [dbo].[pDec]      NOT NULL,
    [NetPay]              [dbo].[pDec]      NOT NULL,
    [WeeksWorked]         [dbo].[pDec]      NOT NULL,
    [HoursWorked]         [dbo].[pDec]      NOT NULL,
    [WeeksUnderLimit]     [dbo].[pDec]      NOT NULL,
    [FicaTips]            [dbo].[pDec]      NOT NULL,
    [TipsDeemedWages]     [dbo].[pDec]      NOT NULL,
    [VacHoursAccrued]     [dbo].[pDec]      NULL,
    [SickHoursAccrued]    [dbo].[pDec]      NULL,
    [UncollectedOasdi]    [dbo].[pDec]      NOT NULL,
    [UncollectedMedicare] [dbo].[pDec]      NOT NULL,
    [CollOnUncollOasdi]   [dbo].[pDec]      NOT NULL,
    [CollOnUncollMed]     [dbo].[pDec]      NOT NULL,
    [Voided]              BIT               NOT NULL,
    [VoidDate]            DATETIME          NULL,
    [VoidBankId]          [dbo].[pBankID]   NULL,
    [CheckRun]            DATETIME          NULL,
    [SelectedYn]          BIT               NOT NULL,
    [TipsReported]        [dbo].[pDec]      NOT NULL,
    [PeriodRunCode]       TINYINT           NOT NULL,
    [BankId]              [dbo].[pBankID]   NULL,
    [PaYear]              SMALLINT          NOT NULL,
    [PaMonth]             TINYINT           NOT NULL,
    [GlYear]              SMALLINT          NOT NULL,
    [GlPeriod]            SMALLINT          NOT NULL,
    [ts]                  ROWVERSION        NULL,
    [CF]                  XML               NULL,
    [Id]                  INT               NOT NULL,
    [VoucherNumber]       VARCHAR (50)      NULL,
    [_Type]               TINYINT           NULL,
    [_EmployeeType]       TINYINT           NULL,
    [GLAcctCash]          [dbo].[pGlAcct]   NULL,
    [Type]                TINYINT           NOT NULL,
    [EmployeeType]        TINYINT           NOT NULL,
    CONSTRAINT [PK_tblPaCheckHist] PRIMARY KEY CLUSTERED ([PostRun] ASC, [Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckHist_PaYearDepartmentId]
    ON [dbo].[tblPaCheckHist]([PaYear] ASC, [DepartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckHist_PaYearEmployeeId]
    ON [dbo].[tblPaCheckHist]([PaYear] ASC, [EmployeeId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlVoidBankId]
    ON [dbo].[tblPaCheckHist]([VoidBankId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlEmployeeId]
    ON [dbo].[tblPaCheckHist]([EmployeeId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlDepartmentId]
    ON [dbo].[tblPaCheckHist]([DepartmentId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlBankId]
    ON [dbo].[tblPaCheckHist]([BankId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaCheckHist] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaCheckHist] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaCheckHist] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaCheckHist] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHist';

