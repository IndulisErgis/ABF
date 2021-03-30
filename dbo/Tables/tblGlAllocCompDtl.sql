CREATE TABLE [dbo].[tblGlAllocCompDtl] (
    [SegType]      VARCHAR (2)     NOT NULL,
    [SegId]        [dbo].[pGlAcct] NOT NULL,
    [ToCompId]     [dbo].[pCompID] NOT NULL,
    [AcctIdCredit] [dbo].[pGlAcct] NOT NULL,
    [AcctIdDebit]  [dbo].[pGlAcct] NOT NULL,
    [ts]           ROWVERSION      NULL,
    [CF]           XML             NULL,
    CONSTRAINT [PK__tblGlAllocCompDtl] PRIMARY KEY CLUSTERED ([SegType] ASC, [SegId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocCompDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocCompDtl';

