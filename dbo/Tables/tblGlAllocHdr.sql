CREATE TABLE [dbo].[tblGlAllocHdr] (
    [AcctId] [dbo].[pGlAcct] NOT NULL,
    [Desc]   VARCHAR (30)    NULL,
    [ts]     ROWVERSION      NULL,
    [CF]     XML             NULL,
    CONSTRAINT [PK__tblGlAllocHdr__75035A77] PRIMARY KEY CLUSTERED ([AcctId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocHdr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocHdr';

