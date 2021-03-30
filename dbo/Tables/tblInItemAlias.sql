CREATE TABLE [dbo].[tblInItemAlias] (
    [AliasID]   VARCHAR (24)    NOT NULL,
    [ItemID]    [dbo].[pItemID] NOT NULL,
    [ts]        ROWVERSION      NULL,
    [AliasType] TINYINT         DEFAULT ((0)) NOT NULL,
    [Id]        INT             IDENTITY (1, 1) NOT NULL,
    [RefID]     VARCHAR (20)    DEFAULT ('*') NOT NULL,
    [CF]        XML             NULL,
    CONSTRAINT [PK_tblInItemAlias] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemAlias] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemAlias';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemAlias';

