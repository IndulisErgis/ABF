CREATE TABLE [dbo].[tblPaDeductCode] (
    [Id]                 INT             NOT NULL,
    [DeductionCode]      [dbo].[pCode]   NOT NULL,
    [EmployerPaid]       BIT             NOT NULL,
    [Description]        NVARCHAR (15)   NULL,
    [GLLiabilityAccount] [dbo].[pGlAcct] NULL,
    [EmpExpenseAcct]     [dbo].[pGlAcct] NULL,
    [DeferredComp]       BIT             CONSTRAINT [DF_tblPaDeductCode_DeferredComp] DEFAULT ((0)) NOT NULL,
    [SequenceNumber]     NVARCHAR (3)    NULL,
    [FormulaId]          NVARCHAR (12)   NULL,
    [W2Box]              NVARCHAR (3)    NULL,
    [W2Code]             NVARCHAR (8)    NULL,
    [CalcOnGross]        BIT             CONSTRAINT [DF_tblPaDeductCode_CalcOnGross] DEFAULT ((1)) NOT NULL,
    [CF]                 XML             NULL,
    [ts]                 ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaDeductCode] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaDeductCode_DeductionCodeEmployerPaid]
    ON [dbo].[tblPaDeductCode]([DeductionCode] ASC, [EmployerPaid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaDeductCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaDeductCode';

