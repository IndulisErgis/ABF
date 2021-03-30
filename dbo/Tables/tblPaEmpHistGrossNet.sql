CREATE TABLE [dbo].[tblPaEmpHistGrossNet] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [EntryDate]      DATETIME       NOT NULL,
    [PaYear]         SMALLINT       NOT NULL,
    [PaMonth]        TINYINT        NOT NULL,
    [EmployeeId]     [dbo].[pEmpID] NULL,
    [GrossPayAmount] [dbo].[pDec]   NOT NULL,
    [NetPayAmount]   [dbo].[pDec]   NOT NULL,
    [CF]             XML            NULL,
    [ts]             ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpHistGrossNet] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmpHistGrossNet_PaYearPaMonthEmployeeId]
    ON [dbo].[tblPaEmpHistGrossNet]([PaYear] ASC, [PaMonth] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpHistGrossNet';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpHistGrossNet';

