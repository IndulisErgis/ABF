CREATE TABLE [dbo].[tblPaDept] (
    [Id]             [dbo].[pDeptID] NOT NULL,
    [DepartmentName] NVARCHAR (30)   NULL,
    [CF]             XML             NULL,
    [ts]             ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaDept] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaDept';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaDept';

