CREATE TABLE [dbo].[tblPaRecurDeduct] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeId] [dbo].[pEmpID] NULL,
    [DeductCode] [dbo].[pCode]  NULL,
    [LaborClass] NVARCHAR (3)   NULL,
    [Hours]      [dbo].[pDec]   CONSTRAINT [DF_tblPaRecurDeduct_Hours] DEFAULT ((0)) NOT NULL,
    [Amount]     [dbo].[pDec]   CONSTRAINT [DF_tblPaRecurDeduct_Amount] DEFAULT ((0)) NOT NULL,
    [TransDate]  DATETIME       NULL,
    [SeqNo]      NVARCHAR (3)   NULL,
    [Note]       NVARCHAR (255) NULL,
    [RunCode]    NVARCHAR (2)   NULL,
    [CutoffDate] DATETIME       NULL,
    [CF]         XML            NULL,
    [ts]         ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaRecurDeduct] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaRecurDeduct_RunCode]
    ON [dbo].[tblPaRecurDeduct]([RunCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaRecurDeduct_EmployeeId]
    ON [dbo].[tblPaRecurDeduct]([EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaRecurDeduct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaRecurDeduct';

