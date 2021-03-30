CREATE TABLE [dbo].[tblPaEmpEducation] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeId] [dbo].[pEmpID] NULL,
    [DegreeCode] NVARCHAR (6)   NULL,
    [Major]      NVARCHAR (25)  NULL,
    [Date]       DATETIME       NULL,
    [CF]         XML            NULL,
    [ts]         ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpEducation] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmpEducation_EmployeeId]
    ON [dbo].[tblPaEmpEducation]([EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpEducation';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpEducation';

