CREATE TABLE [dbo].[tblPaRecurEmplrCost] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [EmployeeId]   [dbo].[pEmpID]  NULL,
    [DeductCode]   [dbo].[pCode]   NULL,
    [DepartmentId] [dbo].[pDeptID] NULL,
    [LaborClass]   NVARCHAR (3)    NULL,
    [Hours]        [dbo].[pDec]    CONSTRAINT [DF_tblPaRecurEmplrCost_Hours] DEFAULT ((0)) NOT NULL,
    [Amount]       [dbo].[pDec]    CONSTRAINT [DF_tblPaRecurEmplrCost_Amount] DEFAULT ((0)) NOT NULL,
    [TransDate]    DATETIME        NULL,
    [SeqNo]        NVARCHAR (3)    NULL,
    [Note]         NVARCHAR (255)  NULL,
    [RunCode]      NVARCHAR (2)    NULL,
    [CutoffDate]   DATETIME        NULL,
    [CF]           XML             NULL,
    [ts]           ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaRecurEmplrCost] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaRecurEmplrCost_RunCode]
    ON [dbo].[tblPaRecurEmplrCost]([RunCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaRecurEmplrCost_EmployeeId]
    ON [dbo].[tblPaRecurEmplrCost]([EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaRecurEmplrCost';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaRecurEmplrCost';

