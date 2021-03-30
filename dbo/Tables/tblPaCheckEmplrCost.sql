CREATE TABLE [dbo].[tblPaCheckEmplrCost] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [CheckId]          INT             NOT NULL,
    [DeductionCode]    [dbo].[pCode]   NULL,
    [DepartmentId]     [dbo].[pDeptID] NULL,
    [DeductionHours]   [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEmplrCost_DeductionHours] DEFAULT ((0)) NOT NULL,
    [DeductionAmount]  [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEmplrCost_DeductionAmount] DEFAULT ((0)) NOT NULL,
    [DeductionBalance] [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEmplrCost_DeductionBalance] DEFAULT ((0)) NOT NULL,
    [CF]               XML             NULL,
    [ts]               ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaCheckEmplrCost] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckEmplrCost_CheckId]
    ON [dbo].[tblPaCheckEmplrCost]([CheckId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckEmplrCost';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckEmplrCost';

