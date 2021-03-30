CREATE TABLE [dbo].[tblPaDeptDtl] (
    [Id]             INT             NOT NULL,
    [DepartmentId]   [dbo].[pDeptID] NOT NULL,
    [Type]           TINYINT         NOT NULL,
    [TaxAuthorityId] INT             NULL,
    [Code]           [dbo].[pCode]   NOT NULL,
    [Description]    NVARCHAR (40)   NULL,
    [GLAcct]         [dbo].[pGlAcct] NULL,
    [CF]             XML             NULL,
    [ts]             ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaDeptDtl] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaDeptDtl_DepartmentIdTypeTaxAuthCode]
    ON [dbo].[tblPaDeptDtl]([DepartmentId] ASC, [Type] ASC, [TaxAuthorityId] ASC, [Code] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaDeptDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaDeptDtl';

