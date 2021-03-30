CREATE TABLE [dbo].[tblCmImage] (
    [ContactID]   BIGINT               NOT NULL,
    [Type]        TINYINT              NOT NULL,
    [Image]       VARBINARY (MAX)      NULL,
    [ImageURL]    NVARCHAR (MAX)       NULL,
    [Description] [dbo].[pDescription] NULL,
    [CF]          XML                  NULL,
    [ts]          ROWVERSION           NULL,
    CONSTRAINT [PK_tblCmImage] PRIMARY KEY CLUSTERED ([ContactID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmImage';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmImage';

