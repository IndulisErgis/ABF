CREATE TABLE [dbo].[tblPaEmpHistEarn] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [EntryDate]   DATETIME       NOT NULL,
    [PaYear]      SMALLINT       NOT NULL,
    [PaMonth]     TINYINT        NOT NULL,
    [EmployeeId]  [dbo].[pEmpID] NOT NULL,
    [EarningCode] [dbo].[pCode]  NOT NULL,
    [Hours]       [dbo].[pDec]   NOT NULL,
    [Amount]      [dbo].[pDec]   NOT NULL,
    [CF]          XML            NULL,
    [ts]          ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpHistEarn] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmpHistEarn_PaYearPaMonthEmployeeId]
    ON [dbo].[tblPaEmpHistEarn]([PaYear] ASC, [PaMonth] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpHistEarn';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpHistEarn';

