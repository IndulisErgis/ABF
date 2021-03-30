CREATE TABLE [dbo].[tblPaEmpHistWithhold] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [EntryDate]        DATETIME       NOT NULL,
    [PaYear]           SMALLINT       NOT NULL,
    [PaMonth]          TINYINT        NOT NULL,
    [EmployeeId]       [dbo].[pEmpID] NULL,
    [TaxAuthorityType] TINYINT        NOT NULL,
    [State]            NVARCHAR (2)   NULL,
    [Local]            NVARCHAR (2)   NULL,
    [WithholdingCode]  [dbo].[pCode]  NOT NULL,
    [EmployerPaid]     BIT            NOT NULL,
    [EarningAmount]    [dbo].[pDec]   NOT NULL,
    [TaxableAmount]    [dbo].[pDec]   NOT NULL,
    [WithholdAmount]   [dbo].[pDec]   NOT NULL,
    [CF]               XML            NULL,
    [ts]               ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpHistWithhold] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmpHistWithhold_PaYearPaMonthEmployeeId]
    ON [dbo].[tblPaEmpHistWithhold]([PaYear] ASC, [PaMonth] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpHistWithhold';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpHistWithhold';

