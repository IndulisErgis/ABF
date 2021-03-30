CREATE TABLE [dbo].[tblGlSegment] (
    [Number]      INT          NOT NULL,
    [Id]          VARCHAR (12) NOT NULL,
    [Description] VARCHAR (25) NULL,
    [CF]          XML          NULL,
    [ts]          ROWVERSION   NULL,
    CONSTRAINT [PK_tblGlSegment] PRIMARY KEY CLUSTERED ([Number] ASC, [Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlSegment';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlSegment';

