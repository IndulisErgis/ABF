CREATE TABLE [dbo].[tblGlAllocCompHdr] (
    [SegType] VARCHAR (2) NOT NULL,
    [ts]      ROWVERSION  NULL,
    [Id]      INT         IDENTITY (1, 1) NOT NULL,
    [CF]      XML         NULL,
    CONSTRAINT [PK_tblGlAllocCompHdr] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocCompHdr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocCompHdr';

