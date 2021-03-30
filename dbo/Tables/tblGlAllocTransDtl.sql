CREATE TABLE [dbo].[tblGlAllocTransDtl] (
    [TransAllocId] VARCHAR (10)    NOT NULL,
    [Counter]      INT             IDENTITY (1, 1) NOT NULL,
    [AllocPct]     [dbo].[pDec]    DEFAULT ((0)) NULL,
    [ts]           ROWVERSION      NULL,
    [Segments]     [dbo].[pGlAcct] NULL,
    [CF]           XML             NULL,
    CONSTRAINT [PK__tblGlAllocTransDtl] PRIMARY KEY CLUSTERED ([TransAllocId] ASC, [Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocTransDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocTransDtl';

