CREATE TABLE [dbo].[tblPaEmpBonus] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeId] [dbo].[pEmpID] NULL,
    [Date]       DATETIME       NULL,
    [Reason]     NVARCHAR (255) NULL,
    [Amount]     [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpBonus_Amount] DEFAULT ((0)) NOT NULL,
    [CF]         XML            NULL,
    [ts]         ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpBonus] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmpBonus_EmployeeId]
    ON [dbo].[tblPaEmpBonus]([EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpBonus';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpBonus';

