CREATE TABLE [dbo].[tblPaAllocDeptDtl] (
    [DeptAllocId]   NVARCHAR (10)   NOT NULL,
    [AllocToDeptId] [dbo].[pDeptID] NOT NULL,
    [AllocPct]      [dbo].[pDec]    CONSTRAINT [DF_tblPaAllocDeptDtl_AllocPct] DEFAULT ((0)) NOT NULL,
    [CF]            XML             NULL,
    [ts]            ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaAllocDeptDtl] PRIMARY KEY CLUSTERED ([DeptAllocId] ASC, [AllocToDeptId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaAllocDeptDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaAllocDeptDtl';

