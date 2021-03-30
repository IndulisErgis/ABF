CREATE TABLE [dbo].[tblPaAllocDeptHdr] (
    [Id]      NVARCHAR (10) NOT NULL,
    [Descr]   NVARCHAR (30) NULL,
    [ExpDate] DATETIME      NULL,
    [CF]      XML           NULL,
    [ts]      ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaAllocDeptHdr] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaAllocDeptHdr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaAllocDeptHdr';

