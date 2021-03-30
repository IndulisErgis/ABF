CREATE TABLE [dbo].[tblMbECOType] (
    [Descr]    [dbo].[pDescription] NULL,
    [ts]       ROWVERSION           NULL,
    [CF]       XML                  NULL,
    [_TypeRef] INT                  NULL,
    [TypeRef]  INT                  NOT NULL,
    CONSTRAINT [PK_tblMbECOType] PRIMARY KEY CLUSTERED ([TypeRef] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbECOType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbECOType';

