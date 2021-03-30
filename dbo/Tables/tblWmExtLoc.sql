CREATE TABLE [dbo].[tblWmExtLoc] (
    [Id]       INT            NOT NULL,
    [Type]     SMALLINT       NOT NULL,
    [LocID]    [dbo].[pLocID] NULL,
    [ExtLocID] NVARCHAR (10)  NOT NULL,
    [Descr]    NVARCHAR (25)  NULL,
    [CF]       XML            NULL,
    [ts]       ROWVERSION     NULL,
    CONSTRAINT [PK_tblWmExtLoc] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblWmExtLoc_LocIdExtLocId]
    ON [dbo].[tblWmExtLoc]([LocID] ASC, [ExtLocID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmExtLoc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmExtLoc';

