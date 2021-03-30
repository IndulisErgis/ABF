CREATE TABLE [dbo].[tblGlAllocPdGroupCode] (
    [ID]           BIGINT     NOT NULL,
    [AllocGroupID] BIGINT     NOT NULL,
    [AllocCodeID]  BIGINT     NOT NULL,
    [Sequence]     BIGINT     NOT NULL,
    [UsageType]    TINYINT    CONSTRAINT [DF_tblGlAllocPdGroupCode_UsageType] DEFAULT ((0)) NOT NULL,
    [CF]           XML        NULL,
    [ts]           ROWVERSION NULL,
    CONSTRAINT [PK_tblGlAllocPdGroupCode] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblGlAllocPdGroupCode_AllocGroupIdAllocCodeId]
    ON [dbo].[tblGlAllocPdGroupCode]([AllocGroupID] ASC, [AllocCodeID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdGroupCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdGroupCode';

