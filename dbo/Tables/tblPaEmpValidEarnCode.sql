CREATE TABLE [dbo].[tblPaEmpValidEarnCode] (
    [EmployeeId] [dbo].[pEmpID] NOT NULL,
    [PaYear]     SMALLINT       NOT NULL,
    [EarnCodeId] [dbo].[pCode]  NOT NULL,
    [RateType]   TINYINT        CONSTRAINT [DF_tblPaEmpValidEarnCode_RateType] DEFAULT ((0)) NOT NULL,
    [Rate]       [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpValidEarnCode_Rate] DEFAULT ((0)) NOT NULL,
    [ts]         ROWVERSION     NULL,
    [CF]         XML            NULL,
    CONSTRAINT [PK_tblPaEmpValidEarnCode] PRIMARY KEY CLUSTERED ([EmployeeId] ASC, [PaYear] ASC, [EarnCodeId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpValidEarnCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpValidEarnCode';

