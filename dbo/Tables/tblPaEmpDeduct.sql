CREATE TABLE [dbo].[tblPaEmpDeduct] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeId]       [dbo].[pEmpID] NOT NULL,
    [PaYear]           SMALLINT       NOT NULL,
    [DeductionCodeId]  INT            NOT NULL,
    [SeqNum]           NCHAR (2)      CONSTRAINT [DF_tblPaEmpDeduct_SeqNum] DEFAULT ('1') NOT NULL,
    [PeriodCode1]      TINYINT        CONSTRAINT [DF_tblPaEmpDeduct_PeriodCode1] DEFAULT ((1)) NOT NULL,
    [PeriodCode2]      TINYINT        CONSTRAINT [DF_tblPaEmpDeduct_PeriodCode2] DEFAULT ((1)) NOT NULL,
    [PeriodCode3]      TINYINT        CONSTRAINT [DF_tblPaEmpDeduct_PeriodCode3] DEFAULT ((1)) NOT NULL,
    [PeriodCode4]      TINYINT        CONSTRAINT [DF_tblPaEmpDeduct_PeriodCode4] DEFAULT ((1)) NOT NULL,
    [PeriodCode5]      TINYINT        CONSTRAINT [DF_tblPaEmpDeduct_PeriodCode5] DEFAULT ((1)) NOT NULL,
    [ScheduledAmount]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_ScheduledAmount] DEFAULT ((0)) NOT NULL,
    [Balance]          [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_Balance] DEFAULT ((0)) NOT NULL,
    [UseFactorFlag]    BIT            CONSTRAINT [DF_tblPaEmpDeduct_UseFactorFlag] DEFAULT ((0)) NOT NULL,
    [OverrideFactor1]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor1] DEFAULT ((0)) NOT NULL,
    [OverrideFactor2]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor2] DEFAULT ((0)) NOT NULL,
    [OverrideFactor3]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor3] DEFAULT ((0)) NOT NULL,
    [OverrideFactor4]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor4] DEFAULT ((0)) NOT NULL,
    [OverrideFactor5]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor5] DEFAULT ((0)) NOT NULL,
    [OverrideFactor6]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor6] DEFAULT ((0)) NOT NULL,
    [CalcOnGross]      BIT            CONSTRAINT [DF_tblPaEmpDeduct_CalcOnGross] DEFAULT ((1)) NOT NULL,
    [FormulaId]        NVARCHAR (12)  NULL,
    [CF]               XML            NULL,
    [ts]               ROWVERSION     NULL,
    [OverrideFactor7]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor7] DEFAULT ((0)) NOT NULL,
    [OverrideFactor8]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor8] DEFAULT ((0)) NOT NULL,
    [OverrideFactor9]  [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor9] DEFAULT ((0)) NOT NULL,
    [OverrideFactor10] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor10] DEFAULT ((0)) NOT NULL,
    [OverrideFactor11] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor11] DEFAULT ((0)) NOT NULL,
    [OverrideFactor12] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor12] DEFAULT ((0)) NOT NULL,
    [OverrideFactor13] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor13] DEFAULT ((0)) NOT NULL,
    [OverrideFactor14] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor14] DEFAULT ((0)) NOT NULL,
    [OverrideFactor15] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor15] DEFAULT ((0)) NOT NULL,
    [OverrideFactor16] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor16] DEFAULT ((0)) NOT NULL,
    [OverrideFactor17] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor17] DEFAULT ((0)) NOT NULL,
    [OverrideFactor18] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor18] DEFAULT ((0)) NOT NULL,
    [OverrideFactor19] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor19] DEFAULT ((0)) NOT NULL,
    [OverrideFactor20] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpDeduct_OverrideFactor20] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblPaEmpDeduct] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaEmpDeduct_EmployeeIdPaYearDeductionCodeId]
    ON [dbo].[tblPaEmpDeduct]([EmployeeId] ASC, [PaYear] ASC, [DeductionCodeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpDeduct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpDeduct';

