CREATE TABLE [dbo].[tblPaTransEmplrCost] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [PaYear]       SMALLINT         NOT NULL,
    [EmployeeId]   [dbo].[pEmpID]   NULL,
    [DeductCode]   [dbo].[pCode]    NULL,
    [DepartmentId] [dbo].[pDeptID]  NULL,
    [LaborClass]   NVARCHAR (3)     NULL,
    [Hours]        [dbo].[pDec]     CONSTRAINT [DF_tblPaTransEmplrCost_Hours] DEFAULT ((0)) NOT NULL,
    [Amount]       [dbo].[pDec]     CONSTRAINT [DF_tblPaTransEmplrCost_Amount] DEFAULT ((0)) NOT NULL,
    [TransDate]    DATETIME         NOT NULL,
    [SeqNo]        NVARCHAR (3)     NULL,
    [Note]         NVARCHAR (255)   NULL,
    [PostedYn]     BIT              CONSTRAINT [DF_tblPaTransEmplrCost_PostedYn] DEFAULT ((0)) NOT NULL,
    [PostRun]      [dbo].[pPostRun] NULL,
    [CF]           XML              NULL,
    [ts]           ROWVERSION       NULL,
    CONSTRAINT [PK_tblPaTransEmplrCost] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaTransEmplrCost_PaYearEmployeeId]
    ON [dbo].[tblPaTransEmplrCost]([PaYear] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransEmplrCost';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTransEmplrCost';

