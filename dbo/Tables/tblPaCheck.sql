CREATE TABLE [dbo].[tblPaCheck] (
    [PaYear]              SMALLINT          NOT NULL,
    [EmployeeId]          [dbo].[pEmpID]    NULL,
    [CheckNumber]         [dbo].[pCheckNum] NULL,
    [VoucherNumber]       NVARCHAR (50)     NULL,
    [CheckDate]           DATETIME          NULL,
    [GrossPay]            [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_GrossPay] DEFAULT ((0)) NOT NULL,
    [NetPay]              [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_NetPay] DEFAULT ((0)) NOT NULL,
    [WeeksWorked]         [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_WeeksWorked] DEFAULT ((0)) NOT NULL,
    [TotalHoursWorked]    [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_TotalHoursWorked] DEFAULT ((0)) NOT NULL,
    [WeeksUnderLimit]     [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_WeeksUnderLimit] DEFAULT ((0)) NOT NULL,
    [Type]                TINYINT           CONSTRAINT [DF_tblPaCheck_Type] DEFAULT ((0)) NOT NULL,
    [FicaTips]            [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_FicaTips] DEFAULT ((0)) NOT NULL,
    [TipsDeemedWages]     [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_TipsDeemedWages] DEFAULT ((0)) NOT NULL,
    [UncollectedOasdi]    [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_UncollectedOasdi] DEFAULT ((0)) NOT NULL,
    [UncollectedMedicare] [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_UncollectedMedicare] DEFAULT ((0)) NOT NULL,
    [CollOnUncolOasdi]    [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_CollOnUncolOasdi] DEFAULT ((0)) NOT NULL,
    [CollOnUncolMed]      [dbo].[pDec]      CONSTRAINT [DF_tblPaCheck_CollOnUncolMed] DEFAULT ((0)) NOT NULL,
    [TransSeqNo]          NVARCHAR (3)      NULL,
    [VoidHistCheckId]     INT               NULL,
    [PdCode]              TINYINT           CONSTRAINT [DF_tblPaCheck_PdCode] DEFAULT ((1)) NOT NULL,
    [CF]                  XML               NULL,
    [ts]                  ROWVERSION        NULL,
    [Id]                  INT               NOT NULL,
    CONSTRAINT [PK_tblPaCheck] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheck_PaYearEmployeeId]
    ON [dbo].[tblPaCheck]([PaYear] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheck';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheck';

