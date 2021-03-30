CREATE TABLE [dbo].[tblGlAllocPdGroup] (
    [ID]             BIGINT               NOT NULL,
    [Description]    [dbo].[pDescription] NOT NULL,
    [Status]         TINYINT              CONSTRAINT [DF_tblGlAllocPdGroup_Status] DEFAULT ((0)) NOT NULL,
    [EffectiveDate]  DATETIME             NULL,
    [ExpirationDate] DATETIME             NULL,
    [CF]             XML                  NULL,
    [ts]             ROWVERSION           NULL,
    CONSTRAINT [PK_tblGlAllocPdGroup] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblGlAllocPdGroup_Description]
    ON [dbo].[tblGlAllocPdGroup]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdGroup';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdGroup';

