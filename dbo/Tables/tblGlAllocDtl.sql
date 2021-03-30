CREATE TABLE [dbo].[tblGlAllocDtl] (
    [AcctId]        [dbo].[pGlAcct] NOT NULL,
    [AllocToAcctId] [dbo].[pGlAcct] NOT NULL,
    [AllocPct]      [dbo].[pDec]    CONSTRAINT [DF__tblGlAllo__Alloc__7F25BA41] DEFAULT (0) NULL,
    [ts]            ROWVERSION      NULL,
    [CF]            XML             NULL,
    CONSTRAINT [PK__tblGlAllocDtl__740F363E] PRIMARY KEY CLUSTERED ([AcctId] ASC, [AllocToAcctId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocDtl';

