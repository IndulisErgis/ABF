CREATE TABLE [dbo].[tblGlAllocPdCode] (
    [ID]             BIGINT               NOT NULL,
    [Description]    [dbo].[pDescription] NOT NULL,
    [Status]         TINYINT              CONSTRAINT [DF_tblGlAllocPdCode_Status] DEFAULT ((0)) NOT NULL,
    [EffectiveDate]  DATETIME             NULL,
    [ExpirationDate] DATETIME             NULL,
    [SourceType]     TINYINT              NOT NULL,
    [DistType]       TINYINT              NOT NULL,
    [RecipientType]  TINYINT              NOT NULL,
    [AllocBasis]     TINYINT              NOT NULL,
    [CF]             XML                  NULL,
    [ts]             ROWVERSION           NULL,
    CONSTRAINT [PK_tblGlAllocPdCode] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblGlAllocPdCode_Description]
    ON [dbo].[tblGlAllocPdCode]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdCode';

