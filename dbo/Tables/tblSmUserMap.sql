CREATE TABLE [dbo].[tblSmUserMap] (
    [ID]       BIGINT         NOT NULL,
    [UserID]   INT            NOT NULL,
    [LinkType] SMALLINT       NOT NULL,
    [LinkID]   NVARCHAR (255) NOT NULL,
    [ExtInfo]  XML            NULL,
    [CF]       XML            NULL,
    [ts]       ROWVERSION     NULL,
    CONSTRAINT [PK_tblSmUserMap] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSmUserMap_UserIDLinkType]
    ON [dbo].[tblSmUserMap]([UserID] ASC, [LinkType] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmUserMap';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmUserMap';

